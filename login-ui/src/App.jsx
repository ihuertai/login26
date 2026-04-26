import { useEffect, useState } from "react";
import { BrowserRouter, Navigate, Route, Routes, useLocation } from "react-router-dom";
import "./App.css";
import AdminDashboard from "./pages/AdminDashboard";
import Login from "./pages/Login";
import RecuperarPassword from "./pages/RecuperarPassword";

function decodeTokenPayload(token) {
    try {
        const payload = token.split(".")[1];
        if (!payload) {
            return null;
        }
        const normalized = payload.replace(/-/g, "+").replace(/_/g, "/");
        const decoded = window.atob(normalized);
        return JSON.parse(decoded);
    } catch {
        return null;
    }
}

function SsoAdminBridge() {
    const location = useLocation();
    const searchParams = new URLSearchParams(location.search);
    const ssoToken = searchParams.get("ssoToken");
    const isBridged = searchParams.get("bridged") === "1";
    const existingSession = localStorage.getItem("login-session");
    const [redirectToAdmin, setRedirectToAdmin] = useState(false);
    const [redirectToLogin, setRedirectToLogin] = useState(false);

    useEffect(() => {
        if (!ssoToken) {
            setRedirectToAdmin(Boolean(existingSession));
            setRedirectToLogin(!existingSession);
            return;
        }

        const payload = decodeTokenPayload(ssoToken);
        if (!payload) {
            localStorage.removeItem("login-session");
            setRedirectToAdmin(false);
            setRedirectToLogin(true);
            return;
        }

        const bridgedSession = {
            id: payload.uid,
            username: payload.sub,
            email: payload.email,
            telefono: "",
            roles: payload.roles ?? [],
            message: "Acceso concedido",
            token: ssoToken,
            redirectUrl: "",
        };
        localStorage.setItem("login-session", JSON.stringify(bridgedSession));

        if (!isBridged) {
            window.location.replace(`http://localhost:8080/auth/admin-bridge?token=${encodeURIComponent(ssoToken)}`);
            return;
        }

        setRedirectToLogin(false);
        setRedirectToAdmin(true);
    }, [existingSession, isBridged, ssoToken]);

    if (redirectToLogin) {
        return <Navigate to="/" replace />;
    }

    if (redirectToAdmin) {
        return <Navigate to="/admin" replace />;
    }

    return (
        <main className="dashboard-shell">
            <p className="feedback">Conectando con la administracion...</p>
        </main>
    );
}

function PrivateRoute({ children }) {
    const session = localStorage.getItem("login-session");
    return session ? children : <Navigate to="/" replace />;
}

function App() {
    return (
        <BrowserRouter>
            <Routes>
                <Route path="/" element={<Login />} />
                <Route path="/recuperar" element={<RecuperarPassword />} />
                <Route path="/admin-bridge" element={<SsoAdminBridge />} />
                <Route
                    path="/admin"
                    element={
                        <PrivateRoute>
                            <AdminDashboard />
                        </PrivateRoute>
                    }
                />
            </Routes>
        </BrowserRouter>
    );
}

export default App;
