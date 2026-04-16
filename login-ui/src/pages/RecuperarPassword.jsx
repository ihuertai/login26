import { useState } from "react";
import { Link } from "react-router-dom";
import { apiFetch } from "../lib/api";

function RecuperarPassword() {
    const [username, setUsername] = useState("");
    const [message, setMessage] = useState("");
    const [error, setError] = useState("");
    const [isSubmitting, setIsSubmitting] = useState(false);

    const recuperar = async (event) => {
        event.preventDefault();
        setMessage("");
        setError("");
        setIsSubmitting(true);

        try {
            await apiFetch("/auth/recuperar-password", {
                method: "POST",
                body: JSON.stringify({ username }),
            });
            setMessage("Se envió una contraseña temporal al correo registrado.");
        } catch (requestError) {
            setError(requestError.message);
        } finally {
            setIsSubmitting(false);
        }
    };

    return (
        <main className="recovery-shell">
            <section className="recovery-card">
                <span className="eyebrow">Recuperación</span>
                <h2>Recuperar contraseña</h2>
                <p>Captura tu usuario y enviaremos una password temporal al correo registrado.</p>

                <form className="auth-form" onSubmit={recuperar}>
                    <label>
                        Usuario
                        <input
                            type="text"
                            placeholder="captura tu usuario"
                            value={username}
                            onChange={(event) => setUsername(event.target.value)}
                        />
                    </label>

                    {message ? <p className="feedback feedback--success">{message}</p> : null}
                    {error ? <p className="feedback feedback--error">{error}</p> : null}

                    <button type="submit" className="button button--primary" disabled={isSubmitting}>
                        {isSubmitting ? "Enviando..." : "Enviar password temporal"}
                    </button>
                </form>

                <Link className="inline-link" to="/">
                    Volver al login
                </Link>
            </section>
        </main>
    );
}

export default RecuperarPassword;
