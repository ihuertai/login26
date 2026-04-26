import { useEffect, useState } from "react";
import { useNavigate } from "react-router-dom";
import { apiFetch } from "../lib/api";

function Login() {
    const [username, setUsername] = useState("");
    const [password, setPassword] = useState("");
    const [error, setError] = useState("");
    const [registerError, setRegisterError] = useState("");
    const [registerMessage, setRegisterMessage] = useState("");
    const [isSubmitting, setIsSubmitting] = useState(false);
    const [isRegistering, setIsRegistering] = useState(false);
    const [roles, setRoles] = useState([]);
    const [registerForm, setRegisterForm] = useState({
        username: "",
        password: "",
        email: "",
        telefono: "",
        rolIds: [],
    });
    const navigate = useNavigate();

    useEffect(() => {
        const loadRoles = async () => {
            try {
                const response = await apiFetch("/roles");
                setRoles(response);
                if (response.length === 1) {
                    setRegisterForm((current) => ({ ...current, rolIds: [response[0].id] }));
                }
            } catch {
                setRoles([]);
            }
        };

        loadRoles();
    }, []);

    const login = async (event) => {
        event.preventDefault();
        setError("");
        setIsSubmitting(true);

        try {
            const response = await apiFetch("/auth/login", {
                method: "POST",
                body: JSON.stringify({ username, password }),
            });

            localStorage.setItem("login-session", JSON.stringify(response));
            if (response.redirectUrl) {
                window.location.replace(response.redirectUrl);
                return;
            }
            navigate("/admin", { replace: true });
        } catch (requestError) {
            setError(requestError.message);
        } finally {
            setIsSubmitting(false);
        }
    };

    const handleRegister = async (event) => {
        event.preventDefault();
        setRegisterError("");
        setRegisterMessage("");
        setIsRegistering(true);

        try {
            await apiFetch("/auth/registro", {
                method: "POST",
                body: JSON.stringify(registerForm),
            });
            setRegisterMessage("Usuario creado correctamente. Ya puedes iniciar sesión.");
            setRegisterForm({
                username: "",
                password: "",
                email: "",
                telefono: "",
                rolIds: roles.length === 1 ? [roles[0].id] : [],
            });
        } catch (requestError) {
            setRegisterError(requestError.message);
        } finally {
            setIsRegistering(false);
        }
    };

    const selectedRoleId = registerForm.rolIds[0] ?? "";

    return (
        <main className="auth-shell">
            <section className="auth-panel auth-panel--hero">
                <span className="eyebrow">Empresa</span>
                <h1>Login</h1>
                <p>Inicio de sesión del sistema.</p>
                <ul className="feature-list">
                    <li>3 intentos fallidos y bloqueo temporal de la conexión al cuarto intento</li>
                    <li>Recuperación por correo con contraseña temporal</li>
                    <li>Gestión de usuarios, roles, auditoría y borrado lógico</li>
                </ul>
            </section>

            <section className="auth-panel auth-panel--form">
                <form className="auth-form" onSubmit={login}>
                    <div>
                        <span className="eyebrow">Acceso</span>
                        <h2>Iniciar sesión</h2>
                    </div>

                    <label>
                        Usuario
                        <input
                            type="text"
                            placeholder="captura tu usuario"
                            value={username}
                            onChange={(event) => setUsername(event.target.value)}
                        />
                    </label>

                    <label>
                        Contraseña
                        <input
                            type="password"
                            placeholder="captura tu contraseña"
                            value={password}
                            onChange={(event) => setPassword(event.target.value)}
                        />
                    </label>

                    {error ? <p className="feedback feedback--error">{error}</p> : null}

                    <button type="submit" className="button button--primary" disabled={isSubmitting}>
                        {isSubmitting ? "Validando..." : "Ingresar"}
                    </button>

                    <button
                        type="button"
                        className="button button--ghost"
                        onClick={() => navigate("/recuperar")}
                    >
                        Recuperar contraseña
                    </button>
                </form>

                <div className="divider" />

                <form className="auth-form" onSubmit={handleRegister}>
                    <div>
                        <span className="eyebrow">Alta rápida</span>
                        <h2>Crear usuario</h2>
                    </div>

                    <label>
                        Nombre de usuario
                        <input
                            type="text"
                            placeholder="nuevo usuario"
                            value={registerForm.username}
                            onChange={(event) => setRegisterForm({ ...registerForm, username: event.target.value })}
                        />
                    </label>

                    <label>
                        Correo electrónico
                        <input
                            type="email"
                            placeholder="correo@dominio.com"
                            value={registerForm.email}
                            onChange={(event) => setRegisterForm({ ...registerForm, email: event.target.value })}
                        />
                    </label>

                    <label>
                        Telefono
                        <input
                            type="text"
                            placeholder="telefono"
                            value={registerForm.telefono}
                            onChange={(event) => setRegisterForm({ ...registerForm, telefono: event.target.value })}
                        />
                    </label>

                    <label>
                        Contraseña
                        <input
                            type="password"
                            placeholder="mínimo 8 caracteres"
                            value={registerForm.password}
                            onChange={(event) => setRegisterForm({ ...registerForm, password: event.target.value })}
                        />
                    </label>

                    <label>
                        Rol
                        <select
                            value={selectedRoleId}
                            onChange={(event) => setRegisterForm({
                                ...registerForm,
                                rolIds: event.target.value ? [Number(event.target.value)] : [],
                            })}
                        >
                            <option value="">Selecciona un rol</option>
                            {roles.map((role) => (
                                <option key={role.id} value={role.id}>
                                    {role.nombre}
                                </option>
                            ))}
                        </select>
                    </label>

                    {!roles.length ? <p className="feedback">Primero necesitas crear al menos un rol en la base.</p> : null}
                    {registerMessage ? <p className="feedback feedback--success">{registerMessage}</p> : null}
                    {registerError ? <p className="feedback feedback--error">{registerError}</p> : null}

                    <button
                        type="submit"
                        className="button button--primary"
                        disabled={isRegistering || !roles.length}
                    >
                        {isRegistering ? "Creando..." : "Dar de alta usuario"}
                    </button>
                </form>
            </section>
        </main>
    );
}

export default Login;
