import { useEffect, useState } from "react";
import { useNavigate } from "react-router-dom";
import { apiFetch } from "../lib/api";

const EMPTY_USER_FORM = {
    username: "",
    password: "",
    email: "",
    telefono: "",
    rolIds: [],
};

const EMPTY_USER_EDIT_FORM = {
    password: "",
    telefono: "",
    rolIds: [],
};

const EMPTY_ROLE_FORM = {
    nombre: "",
    descripcion: "",
};

function AdminDashboard() {
    const navigate = useNavigate();
    const session = JSON.parse(localStorage.getItem("login-session") ?? "null");
    const currentUserId = session?.id;
    const [usuarios, setUsuarios] = useState([]);
    const [roles, setRoles] = useState([]);
    const [selectedUser, setSelectedUser] = useState(null);
    const [editingUserId, setEditingUserId] = useState(null);
    const [editingRoleId, setEditingRoleId] = useState(null);
    const [userForm, setUserForm] = useState(EMPTY_USER_FORM);
    const [userEditForm, setUserEditForm] = useState(EMPTY_USER_EDIT_FORM);
    const [roleForm, setRoleForm] = useState(EMPTY_ROLE_FORM);
    const [message, setMessage] = useState("");
    const [error, setError] = useState("");
    const [isLoading, setIsLoading] = useState(true);

    const loadData = async () => {
        setIsLoading(true);
        setError("");
        try {
            const [usersResponse, rolesResponse] = await Promise.all([
                apiFetch("/usuarios"),
                apiFetch("/roles"),
            ]);
            setUsuarios(usersResponse);
            setRoles(rolesResponse);
            setSelectedUser((current) => {
                if (!usersResponse.length) {
                    return null;
                }
                if (!current) {
                    return usersResponse[0];
                }
                return usersResponse.find((usuario) => usuario.id === current.id) ?? usersResponse[0];
            });
        } catch (requestError) {
            if (requestError.status === 401 || requestError.status === 403) {
                localStorage.removeItem("login-session");
                navigate("/");
                return;
            }
            setError(requestError.message);
        } finally {
            setIsLoading(false);
        }
    };

    useEffect(() => {
        loadData();
        // eslint-disable-next-line react-hooks/exhaustive-deps
    }, []);

    const showMessage = (text) => {
        setMessage(text);
        setError("");
    };

    const handleLogout = async () => {
        await apiFetch("/auth/logout", { method: "POST" });
        localStorage.removeItem("login-session");
        navigate("/");
    };

    const handleCreateUser = async (event) => {
        event.preventDefault();
        setError("");
        try {
            await apiFetch("/usuarios", {
                method: "POST",
                body: JSON.stringify(userForm),
            });
            setUserForm(EMPTY_USER_FORM);
            showMessage("Usuario registrado correctamente.");
            await loadData();
        } catch (requestError) {
            setError(requestError.message);
        }
    };

    const startEditUser = (usuario) => {
        setEditingUserId(usuario.id);
        setUserEditForm({
            password: "",
            telefono: usuario.telefono,
            rolIds: usuario.roles.map((rol) => rol.id),
        });
        setSelectedUser(usuario);
    };

    const handleUpdateUser = async (event) => {
        event.preventDefault();
        setError("");
        try {
            await apiFetch(`/usuarios/${editingUserId}`, {
                method: "PUT",
                body: JSON.stringify(userEditForm),
            });
            setEditingUserId(null);
            setUserEditForm(EMPTY_USER_EDIT_FORM);
            showMessage("Usuario actualizado correctamente.");
            await loadData();
        } catch (requestError) {
            setError(requestError.message);
        }
    };

    const handleDeleteUser = async (usuario) => {
        if (usuario.id === currentUserId) {
            setError("No puedes eliminar tu propio usuario.");
            setMessage("");
            return;
        }

        const confirmed = window.confirm(`Deseas eliminar al usuario ${usuario.username}?`);
        if (!confirmed) {
            return;
        }

        try {
            await apiFetch(`/usuarios/${usuario.id}`, { method: "DELETE" });
            if (selectedUser?.id === usuario.id) {
                setSelectedUser(null);
            }
            showMessage("Usuario eliminado logicamente.");
            await loadData();
        } catch (requestError) {
            setError(requestError.message);
        }
    };

    const handleRoleSubmit = async (event) => {
        event.preventDefault();
        setError("");
        const path = editingRoleId ? `/roles/${editingRoleId}` : "/roles";
        const method = editingRoleId ? "PUT" : "POST";

        try {
            await apiFetch(path, {
                method,
                body: JSON.stringify(roleForm),
            });
            setEditingRoleId(null);
            setRoleForm(EMPTY_ROLE_FORM);
            showMessage(editingRoleId ? "Rol actualizado correctamente." : "Rol creado correctamente.");
            await loadData();
        } catch (requestError) {
            setError(requestError.message);
        }
    };

    const handleDeleteRole = async (rol) => {
        const confirmed = window.confirm(`Deseas eliminar el rol ${rol.nombre}?`);
        if (!confirmed) {
            return;
        }

        try {
            await apiFetch(`/roles/${rol.id}`, { method: "DELETE" });
            showMessage("Rol eliminado logicamente.");
            await loadData();
        } catch (requestError) {
            setError(requestError.message);
        }
    };

    const toggleRoleSelection = (roleId) => {
        const stateValue = editingUserId ? userEditForm : userForm;
        const nextRoleIds = stateValue.rolIds.includes(roleId)
            ? stateValue.rolIds.filter((id) => id !== roleId)
            : [...stateValue.rolIds, roleId];

        if (editingUserId) {
            setUserEditForm({ ...userEditForm, rolIds: nextRoleIds });
            return;
        }

        setUserForm({ ...userForm, rolIds: nextRoleIds });
    };

    return (
        <main className="dashboard-shell">
            <header className="dashboard-header">
                <div>
                    <span className="eyebrow">Administracion</span>
                    <h1>Control de acceso</h1>
                    <p>
                        Usuario activo: <strong>{session?.username ?? "Sin sesión"}</strong>
                    </p>
                </div>
                <button className="button button--ghost" onClick={handleLogout}>
                    Cerrar sesión
                </button>
            </header>

            {message ? <p className="feedback feedback--success">{message}</p> : null}
            {error ? <p className="feedback feedback--error">{error}</p> : null}

            {isLoading ? <p className="feedback">Cargando informacion...</p> : null}

            <section className="dashboard-grid">
                <article className="panel">
                    <div className="panel-header">
                        <div>
                            <span className="eyebrow">Usuarios</span>
                            <h2>{editingUserId ? "Editar usuario" : "Agregar usuario"}</h2>
                        </div>
                        <span className="pill">{usuarios.length}</span>
                    </div>

                    <form className="form-grid" onSubmit={editingUserId ? handleUpdateUser : handleCreateUser}>
                        {!editingUserId ? (
                            <>
                                <label>
                                    Nombre de usuario
                                    <input
                                        value={userForm.username}
                                        onChange={(event) => setUserForm({ ...userForm, username: event.target.value })}
                                    />
                                </label>
                                <label>
                                    Correo electrónico
                                    <input
                                        type="email"
                                        value={userForm.email}
                                        onChange={(event) => setUserForm({ ...userForm, email: event.target.value })}
                                    />
                                </label>
                            </>
                        ) : null}

                        <label>
                            Telefono
                            <input
                                value={editingUserId ? userEditForm.telefono : userForm.telefono}
                                onChange={(event) =>
                                    editingUserId
                                        ? setUserEditForm({ ...userEditForm, telefono: event.target.value })
                                        : setUserForm({ ...userForm, telefono: event.target.value })
                                }
                            />
                        </label>

                        <label>
                            {editingUserId ? "Nueva contraseña" : "Contraseña"}
                            <input
                                type="password"
                                value={editingUserId ? userEditForm.password : userForm.password}
                                onChange={(event) =>
                                    editingUserId
                                        ? setUserEditForm({ ...userEditForm, password: event.target.value })
                                        : setUserForm({ ...userForm, password: event.target.value })
                                }
                            />
                        </label>

                        <div className="checkbox-group">
                            <span>Roles</span>
                            <div className="role-tags">
                                {roles.map((rol) => {
                                    const selected = editingUserId
                                        ? userEditForm.rolIds.includes(rol.id)
                                        : userForm.rolIds.includes(rol.id);

                                    return (
                                        <label key={rol.id} className={`tag ${selected ? "tag--selected" : ""}`}>
                                            <input
                                                type="checkbox"
                                                checked={selected}
                                                onChange={() => toggleRoleSelection(rol.id)}
                                            />
                                            {rol.nombre}
                                        </label>
                                    );
                                })}
                            </div>
                        </div>

                        <div className="actions-row">
                            <button className="button button--primary" type="submit">
                                {editingUserId ? "Guardar cambios" : "Agregar usuario"}
                            </button>
                            {editingUserId ? (
                                <button
                                    className="button button--ghost"
                                    type="button"
                                    onClick={() => {
                                        setEditingUserId(null);
                                        setUserEditForm(EMPTY_USER_EDIT_FORM);
                                    }}
                                >
                                    Cancelar edicion
                                </button>
                            ) : null}
                        </div>
                    </form>

                    <div className="table-list">
                        {usuarios.map((usuario) => (
                            <div key={usuario.id} className="table-card">
                                <div>
                                    <strong>{usuario.username}</strong>
                                    <p>{usuario.email}</p>
                                    <small>{usuario.roles.map((rol) => rol.nombre ?? rol).join(", ")}</small>
                                    {usuario.id === currentUserId ? <small>Usuario actual</small> : null}
                                </div>
                                <div className="table-actions">
                                    <button className="button button--tiny" type="button" onClick={() => setSelectedUser(usuario)}>
                                        Ver
                                    </button>
                                    <button className="button button--tiny" type="button" onClick={() => startEditUser(usuario)}>
                                        Editar
                                    </button>
                                    <button
                                        className="button button--tiny danger"
                                        type="button"
                                        onClick={() => handleDeleteUser(usuario)}
                                        disabled={usuario.id === currentUserId}
                                        title={usuario.id === currentUserId ? "No puedes eliminar tu propio usuario" : ""}
                                    >
                                        Borrar
                                    </button>
                                </div>
                            </div>
                        ))}
                    </div>
                </article>

                <article className="panel">
                    <div className="panel-header">
                        <div>
                            <span className="eyebrow">Roles</span>
                            <h2>Catalogo de roles</h2>
                        </div>
                        <span className="pill">{roles.length}</span>
                    </div>

                    <form className="form-grid" onSubmit={handleRoleSubmit}>
                        <label>
                            Nombre del rol
                            <input
                                value={roleForm.nombre}
                                onChange={(event) => setRoleForm({ ...roleForm, nombre: event.target.value })}
                            />
                        </label>

                        <label>
                            Descripcion
                            <textarea
                                rows="4"
                                value={roleForm.descripcion}
                                onChange={(event) => setRoleForm({ ...roleForm, descripcion: event.target.value })}
                            />
                        </label>

                        <div className="actions-row">
                            <button className="button button--primary" type="submit">
                                {editingRoleId ? "Guardar rol" : "Agregar rol"}
                            </button>
                            {editingRoleId ? (
                                <button
                                    className="button button--ghost"
                                    type="button"
                                    onClick={() => {
                                        setEditingRoleId(null);
                                        setRoleForm(EMPTY_ROLE_FORM);
                                    }}
                                >
                                    Cancelar edicion
                                </button>
                            ) : null}
                        </div>
                    </form>

                    <div className="table-list">
                        {roles.map((rol) => (
                            <div key={rol.id} className="table-card">
                                <div>
                                    <strong>{rol.nombre}</strong>
                                    <p>{rol.descripcion}</p>
                                </div>
                                <div className="table-actions">
                                    <button
                                        className="button button--tiny"
                                        type="button"
                                        onClick={() => {
                                            setEditingRoleId(rol.id);
                                            setRoleForm({ nombre: rol.nombre, descripcion: rol.descripcion });
                                        }}
                                    >
                                        Editar
                                    </button>
                                    <button className="button button--tiny danger" type="button" onClick={() => handleDeleteRole(rol)}>
                                        Borrar
                                    </button>
                                </div>
                            </div>
                        ))}
                    </div>
                </article>
            </section>

            <section className="detail-panel">
                <div className="panel-header">
                    <div>
                        <span className="eyebrow">Consulta</span>
                        <h2>Ver usuario</h2>
                    </div>
                </div>

                {selectedUser ? (
                    <div className="detail-grid">
                        <div><strong>Usuario:</strong> {selectedUser.username}</div>
                        <div><strong>Correo:</strong> {selectedUser.email}</div>
                        <div><strong>Telefono:</strong> {selectedUser.telefono}</div>
                        <div><strong>Activo:</strong> {selectedUser.activo ? "Si" : "No"}</div>
                        <div><strong>Usuario actual:</strong> {selectedUser.id === currentUserId ? "Si" : "No"}</div>
                        <div><strong>Intentos fallidos:</strong> {selectedUser.intentosFallidos}</div>
                        <div><strong>Roles:</strong> {selectedUser.roles.map((rol) => rol.nombre ?? rol).join(", ")}</div>
                        <div><strong>Creado por:</strong> {selectedUser.creadoPor}</div>
                        <div><strong>Actualizado por:</strong> {selectedUser.actualizadoPor}</div>
                        <div><strong>Fecha creacion:</strong> {selectedUser.fechaCreacion}</div>
                        <div><strong>Fecha actualizacion:</strong> {selectedUser.fechaActualizacion}</div>
                    </div>
                ) : (
                    <p>Selecciona un usuario para consultar todos sus datos.</p>
                )}
            </section>
        </main>
    );
}

export default AdminDashboard;
