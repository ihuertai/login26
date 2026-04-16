export const API_URL = "http://localhost:8080";

export async function apiFetch(path, options = {}) {
    const response = await fetch(`${API_URL}${path}`, {
        credentials: "include",
        headers: {
            "Content-Type": "application/json",
            ...(options.headers ?? {}),
        },
        ...options,
    });

    if (response.status === 204) {
        return null;
    }

    const contentType = response.headers.get("content-type") ?? "";
    const payload = contentType.includes("application/json")
        ? await response.json()
        : await response.text();

    if (!response.ok) {
        const message = typeof payload === "string"
            ? payload
            : payload?.message || "Ocurrio un error al comunicarse con el servidor";
        const error = new Error(message);
        error.status = response.status;
        throw error;
    }

    return payload;
}
