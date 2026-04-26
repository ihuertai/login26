function Write-Utf8NoBom([string]$Path, [string]$Content) {
  $dir = Split-Path -Parent $Path
  if ($dir -and -not (Test-Path $dir)) {
    New-Item -ItemType Directory -Path $dir -Force | Out-Null
  }
  $utf8NoBom = New-Object System.Text.UTF8Encoding($false)
  [System.IO.File]::WriteAllText($Path, $Content, $utf8NoBom)
}

Write-Utf8NoBom 'D:\Descargas\sima\src\main\java\mx\ipn\sima\service\RoleAccessService.java' @'
package mx.ipn.sima.service;

import jakarta.servlet.http.HttpSession;
import mx.ipn.sima.dto.AuthenticatedUser;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.web.server.ResponseStatusException;

import java.util.List;
import java.util.Locale;

@Service
public class RoleAccessService {

    public AuthenticatedUser getCurrentUser(HttpSession session) {
        Object value = session != null ? session.getAttribute("AUTHENTICATED_USER") : null;
        if (value instanceof AuthenticatedUser user) {
            return user;
        }
        throw new ResponseStatusException(HttpStatus.UNAUTHORIZED, "Sesión no válida");
    }

    public boolean canManageClients(AuthenticatedUser user) {
        return isGerente(user) || isSucursal(user);
    }

    public boolean canManageCampaigns(AuthenticatedUser user) {
        return isGerente(user);
    }

    public boolean canManageAds(AuthenticatedUser user) {
        return isGerente(user);
    }

    public boolean canViewRequests(AuthenticatedUser user) {
        return isGerente(user) || isSucursal(user);
    }

    public boolean isGerente(AuthenticatedUser user) {
        return hasAnyToken(user.roles(), "GERENTE", "ADMIN");
    }

    public boolean isSucursal(AuthenticatedUser user) {
        return hasAnyToken(user.roles(), "SUCURSAL");
    }

    public void requireClientManagement(HttpSession session) {
        AuthenticatedUser user = getCurrentUser(session);
        if (!canManageClients(user)) {
            throw forbidden("No tienes permisos para gestionar clientes");
        }
    }

    public void requireCampaignManagement(HttpSession session) {
        AuthenticatedUser user = getCurrentUser(session);
        if (!canManageCampaigns(user)) {
            throw forbidden("Solo un gerente puede gestionar campañas y envíos");
        }
    }

    public void requireAdsManagement(HttpSession session) {
        AuthenticatedUser user = getCurrentUser(session);
        if (!canManageAds(user)) {
            throw forbidden("Solo un gerente puede gestionar anuncios");
        }
    }

    public void requireRequestsView(HttpSession session) {
        AuthenticatedUser user = getCurrentUser(session);
        if (!canViewRequests(user)) {
            throw forbidden("No tienes permisos para revisar solicitudes");
        }
    }

    private ResponseStatusException forbidden(String message) {
        return new ResponseStatusException(HttpStatus.FORBIDDEN, message);
    }

    private boolean hasAnyToken(List<String> roles, String... tokens) {
        if (roles == null || roles.isEmpty()) {
            return false;
        }
        return roles.stream()
                .filter(role -> role != null && !role.isBlank())
                .map(role -> role.toUpperCase(Locale.ROOT))
                .anyMatch(role -> {
                    for (String token : tokens) {
                        if (role.contains(token)) {
                            return true;
                        }
                    }
                    return false;
                });
    }
}
'@

Write-Utf8NoBom 'D:\Descargas\sima\src\main\resources\templates\dashboard.html' @'
<!DOCTYPE html>
<html xmlns:th="http://www.thymeleaf.org">
<head>
    <title>SIMA Dashboard</title>
    <meta charset="UTF-8">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" th:href="@{/css/styles.css}">
</head>
<body class="bg-light">
<div class="container py-5">
    <div class="d-flex justify-content-between align-items-center mb-4">
        <h1 class="mb-0 titulo-sima">SIMA</h1>
        <div class="text-end" th:if="${currentUser != null}">
            <div class="fw-semibold" th:text="${currentUser.username()}"></div>
            <small class="text-muted" th:text="${#strings.listJoin(currentUser.roles(), ', ')}"></small>
        </div>
    </div>

    <div class="card shadow-sm mb-4">
        <div class="card-body">
            <h4 class="mb-2">Bienvenida</h4>
            <p class="text-muted mb-3">Resumen de entregas, respuestas y actividad reciente del sistema.</p>
            <div class="row g-3">
                <div class="col-md-3">
                    <div class="border rounded p-3 h-100 bg-white">
                        <div class="small text-muted">Clientes</div>
                        <div class="fs-4 fw-semibold" th:text="${metrics.totalClientes()}">0</div>
                    </div>
                </div>
                <div class="col-md-3">
                    <div class="border rounded p-3 h-100 bg-white">
                        <div class="small text-muted">Anuncios</div>
                        <div class="fs-4 fw-semibold" th:text="${metrics.totalAnuncios()}">0</div>
                    </div>
                </div>
                <div class="col-md-3">
                    <div class="small text-muted">Entregas</div>
                    <div class="fs-4 fw-semibold" th:text="${metrics.totalEnviosExitosos()}">0</div>
                    <small class="text-muted" th:text="${metrics.totalEnviosError()} + ' con error'">0</small>
                </div>
                <div class="col-md-3">
                    <div class="small text-muted">Solicitudes</div>
                    <div class="fs-4 fw-semibold" th:text="${metrics.totalInteracciones()}">0</div>
                    <small class="text-muted" th:text="${metrics.solicitudesContacto()} + ' contacto / ' + ${metrics.solicitudesMasInfo()} + ' más info'">0</small>
                </div>
            </div>
        </div>
    </div>

    <div class="row g-4 mb-4">
        <div class="col-md-3">
            <div class="card shadow-sm h-100">
                <div class="card-body">
                    <h5 class="card-title">Gestión de Clientes</h5>
                    <a href="/clientes/lista" class="btn btn-primary w-100 mb-2">Ver Clientes</a>
                    <a th:if="${canManageClients}" href="/clientes/nuevo" class="btn btn-primary w-100">Agregar Cliente</a>
                </div>
            </div>
        </div>

        <div class="col-md-3">
            <div class="card shadow-sm h-100">
                <div class="card-body">
                    <h5 class="card-title">Gestión de Anuncios</h5>
                    <a href="/anuncios/lista" class="btn btn-primary w-100 mb-2">Ver Anuncios</a>
                    <a th:if="${canManageAds}" href="/anuncios/nuevo" class="btn btn-primary w-100">Crear Anuncio</a>
                </div>
            </div>
        </div>

        <div class="col-md-3">
            <div class="card shadow-sm h-100">
                <div class="card-body">
                    <h5 class="card-title">Envío de Mensajes</h5>
                    <a th:if="${canManageCampaigns}" href="/envio/lista" class="btn btn-primary w-100 mb-2">Ver Campañas</a>
                    <a th:if="${canManageCampaigns}" href="/envio" class="btn btn-primary w-100">Nueva Campaña</a>
                    <div th:if="${!canManageCampaigns}" class="small text-muted mt-2">Solo un gerente puede crear campañas.</div>
                </div>
            </div>
        </div>

        <div class="col-md-3">
            <div class="card shadow-sm h-100">
                <div class="card-body">
                    <h5 class="card-title">Solicitudes</h5>
                    <a th:if="${canViewRequests}" href="/solicitudes" class="btn btn-primary w-100 mb-2">Ver Solicitudes</a>
                    <a th:if="${canViewRequests}" href="/reportes" class="btn btn-primary w-100">Ver Reportes</a>
                </div>
            </div>
        </div>
    </div>

    <div class="row g-4">
        <div class="col-lg-6">
            <div class="card shadow-sm h-100">
                <div class="card-body">
                    <h5 class="mb-3">Resumen de entregas</h5>
                    <table class="table table-striped mb-0">
                        <thead class="table-light">
                        <tr>
                            <th>Campaña</th>
                            <th>Estado</th>
                            <th>Resultado</th>
                        </tr>
                        </thead>
                        <tbody>
                        <tr th:each="campana : ${metrics.recentCampaigns()}">
                            <td th:text="${campana.nombre}"></td>
                            <td th:text="${campana.estado}"></td>
                            <td th:text="${campana.enviosExitosos + ' enviados / ' + campana.enviosError + ' error'}"></td>
                        </tr>
                        <tr th:if="${#lists.isEmpty(metrics.recentCampaigns())}">
                            <td colspan="3" class="text-center text-muted py-4">Aún no hay campañas registradas.</td>
                        </tr>
                        </tbody>
                    </table>
                </div>
            </div>
        </div>

        <div class="col-lg-6">
            <div class="card shadow-sm h-100">
                <div class="card-body">
                    <h5 class="mb-3">Actividad reciente</h5>
                    <table class="table table-striped mb-0">
                        <thead class="table-light">
                        <tr>
                            <th>Cliente</th>
                            <th>Tipo</th>
                            <th>Responsable</th>
                        </tr>
                        </thead>
                        <tbody>
                        <tr th:each="interaccion : ${metrics.recentInteractions()}">
                            <td>
                                <div th:text="${interaccion.cliente != null ? interaccion.cliente.nombre : interaccion.telefonoCliente}"></div>
                                <small class="text-muted" th:text="${interaccion.productoNombre}"></small>
                            </td>
                            <td th:text="${interaccion.tipo}"></td>
                            <td th:text="${interaccion.jefeResponsable != null ? interaccion.jefeResponsable.nombre : 'Sin asignar'}"></td>
                        </tr>
                        <tr th:if="${#lists.isEmpty(metrics.recentInteractions())}">
                            <td colspan="3" class="text-center text-muted py-4">Aún no hay interacciones registradas.</td>
                        </tr>
                        </tbody>
                    </table>
                </div>
            </div>
        </div>
    </div>
</div>
</body>
</html>
'@

Write-Utf8NoBom 'D:\Descargas\sima\src\main\resources\templates\cliente-form.html' @'
<!DOCTYPE html>
<html xmlns:th="http://www.thymeleaf.org">
<head>
    <title>Registro de Cliente</title>
    <meta charset="UTF-8">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" th:href="@{/css/styles.css}">
</head>
<body class="bg-light">
<div class="container py-5">
    <div class="d-flex justify-content-between align-items-center mb-4">
        <h1 class="titulo-sima mb-0">SIMA</h1>
        <div class="d-flex gap-2">
            <a href="/dashboard" class="btn btn-primary">Menú</a>
            <a href="/clientes/lista" class="btn btn-primary">Lista de clientes</a>
            <a th:if="${canManageAds}" href="/anuncios/nuevo" class="btn btn-primary">Anuncios</a>
            <a th:if="${canManageCampaigns}" href="/envio/lista" class="btn btn-primary">Campañas</a>
        </div>
    </div>

    <h3 class="mb-4">Registrar Cliente</h3>

    <div class="card shadow-sm">
        <div class="card-body">
            <form th:action="@{/clientes/guardar}" th:object="${cliente}" method="post">
                <div class="row g-3">
                    <div class="col-md-6">
                        <label class="form-label">Nombre</label>
                        <input type="text" class="form-control" th:field="*{nombre}" required>
                    </div>
                    <div class="col-md-6">
                        <label class="form-label">Razón social</label>
                        <input type="text" class="form-control" th:field="*{razonSocial}">
                    </div>
                    <div class="col-md-6">
                        <label class="form-label">Correo</label>
                        <input type="email" class="form-control" th:field="*{correo}">
                    </div>
                    <div class="col-md-6">
                        <label class="form-label">Teléfono</label>
                        <input type="text" class="form-control" th:field="*{telefono}" required>
                    </div>
                    <div class="col-md-6">
                        <label class="form-label">Sucursal</label>
                        <select class="form-select" th:field="*{sucursal.id}">
                            <option value="">Selecciona</option>
                            <option th:each="sucursal : ${sucursales}" th:value="${sucursal.id}" th:text="${sucursal.nombre}"></option>
                        </select>
                    </div>
                    <div class="col-md-6">
                        <label class="form-label">Responsable de sucursal</label>
                        <select class="form-select" th:field="*{jefeSucursal.id}">
                            <option value="">Selecciona</option>
                            <option th:each="jefe : ${jefesSucursal}" th:value="${jefe.id}" th:text="${jefe.nombre}"></option>
                        </select>
                    </div>
                    <div class="col-md-4">
                        <label class="form-label">Facturación mensual</label>
                        <input type="number" step="0.01" class="form-control" th:field="*{facturacionMensual}">
                    </div>
                    <div class="col-md-4">
                        <label class="form-label">Tamaño de empresa</label>
                        <select class="form-select" th:field="*{tamanoEmpresa}">
                            <option value="">Selecciona</option>
                            <option th:each="tamano : ${tamanos}" th:value="${tamano}" th:text="${tamano}"></option>
                        </select>
                    </div>
                    <div class="col-md-4">
                        <label class="form-label">Categoría de producto</label>
                        <input type="text" class="form-control" th:field="*{categoriaProducto}">
                    </div>
                    <div class="col-12">
                        <label class="form-label">Giro</label>
                        <input type="text" class="form-control" th:field="*{giro}">
                    </div>
                </div>
                <button type="submit" class="btn btn-primary mt-4">Guardar</button>
            </form>
        </div>
    </div>
</div>
</body>
</html>
'@

Write-Utf8NoBom 'D:\Descargas\sima\src\main\resources\templates\cliente-lista.html' @'
<!DOCTYPE html>
<html xmlns:th="http://www.thymeleaf.org">
<head>
    <title>Lista de Clientes</title>
    <meta charset="UTF-8">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" th:href="@{/css/styles.css}">
</head>
<body class="bg-light">
<div class="container py-5">
    <div class="d-flex justify-content-between align-items-center mb-4">
        <h1 class="titulo-sima mb-0">SIMA</h1>
        <div class="d-flex gap-2">
            <a href="/dashboard" class="btn btn-primary">Menú</a>
            <a th:if="${canManageAds}" href="/anuncios/lista" class="btn btn-primary">Lista de anuncios</a>
            <a th:if="${canManageCampaigns}" href="/envio/lista" class="btn btn-primary">Campañas</a>
        </div>
    </div>

    <div class="d-flex justify-content-between align-items-center mb-3">
        <h3 class="mb-0">Lista de Clientes</h3>
        <a th:if="${canManageClients}" href="/clientes/nuevo" class="btn btn-primary">Agregar Cliente</a>
    </div>

    <div class="card shadow-sm">
        <div class="card-body table-responsive">
            <table class="table table-striped table-hover mb-0">
                <thead class="table-light">
                <tr>
                    <th>Nombre</th>
                    <th>Sucursal</th>
                    <th>Teléfono</th>
                    <th>Facturación</th>
                    <th>Tamaño</th>
                    <th>Categoría</th>
                </tr>
                </thead>
                <tbody>
                <tr th:each="cliente : ${clientes}">
                    <td>
                        <div th:text="${cliente.nombre}"></div>
                        <small th:text="${cliente.correo}"></small>
                    </td>
                    <td th:text="${cliente.sucursal != null ? cliente.sucursal.nombre : 'Sin sucursal'}"></td>
                    <td th:text="${cliente.telefono}"></td>
                    <td th:text="${cliente.facturacionMensual}"></td>
                    <td th:text="${cliente.tamanoEmpresa}"></td>
                    <td th:text="${cliente.categoriaProducto}"></td>
                </tr>
                </tbody>
            </table>
        </div>
    </div>
</div>
</body>
</html>
'@

Write-Utf8NoBom 'D:\Descargas\sima\src\main\resources\templates\anuncio-form.html' @'
<!DOCTYPE html>
<html xmlns:th="http://www.thymeleaf.org">
<head>
    <title>Registro de Anuncio</title>
    <meta charset="UTF-8">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" th:href="@{/css/styles.css}">
</head>
<body class="bg-light">
<div class="container py-5">
    <div class="d-flex justify-content-between align-items-center mb-4">
        <h1 class="titulo-sima mb-0">SIMA</h1>
        <div class="d-flex gap-2">
            <a href="/dashboard" class="btn btn-primary">Menú</a>
            <a href="/clientes/lista" class="btn btn-primary">Lista de clientes</a>
            <a href="/anuncios/lista" class="btn btn-primary">Lista de anuncios</a>
            <a href="/envio/lista" class="btn btn-primary">Campañas</a>
        </div>
    </div>

    <h3 class="mb-4">Registrar Anuncio</h3>

    <div class="card shadow-sm">
        <div class="card-body">
            <form th:action="@{/anuncios/guardar}" th:object="${anuncio}" method="post">
                <div class="row g-3">
                    <div class="col-md-6">
                        <label class="form-label">Título</label>
                        <input type="text" class="form-control" th:field="*{titulo}" required>
                    </div>
                    <div class="col-md-6">
                        <label class="form-label">Gerente responsable</label>
                        <select class="form-select" th:field="*{creadoPor.id}" required>
                            <option value="">Selecciona</option>
                            <option th:each="gerente : ${gerentes}" th:value="${gerente.id}" th:text="${gerente.nombre}"></option>
                        </select>
                    </div>
                    <div class="col-12">
                        <label class="form-label">Texto del anuncio</label>
                        <textarea class="form-control" rows="4" th:field="*{texto}" required></textarea>
                    </div>
                    <div class="col-md-6">
                        <label class="form-label">Imagen (URL pública)</label>
                        <input type="text" class="form-control" th:field="*{imagen}" required>
                    </div>
                    <div class="col-md-6">
                        <label class="form-label">Fecha de publicación</label>
                        <input type="date" class="form-control" th:field="*{fechaPublicacion}">
                    </div>
                    <div class="col-md-4">
                        <label class="form-label">Tipo de información extra</label>
                        <select class="form-select" th:field="*{informacionExtraTipo}">
                            <option value="">Selecciona</option>
                            <option th:each="tipo : ${tiposExtra}" th:value="${tipo}" th:text="${tipo}"></option>
                        </select>
                    </div>
                    <div class="col-md-8">
                        <label class="form-label">Valor de información extra</label>
                        <input type="text" class="form-control" th:field="*{informacionExtraValor}" placeholder="URL, texto o recurso adicional">
                    </div>
                </div>
                <button type="submit" class="btn btn-primary mt-4">Guardar</button>
                <a href="/anuncios/lista" class="btn btn-secondary ms-2 mt-4">Cancelar</a>
            </form>
        </div>
    </div>
</div>
</body>
</html>
'@

Write-Utf8NoBom 'D:\Descargas\sima\src\main\resources\templates\anuncio-lista.html' @'
<!DOCTYPE html>
<html xmlns:th="http://www.thymeleaf.org">
<head>
    <title>Lista de Anuncios</title>
    <meta charset="UTF-8">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" th:href="@{/css/styles.css}">
</head>
<body class="bg-light">
<div class="container py-5">
    <div class="d-flex justify-content-between align-items-center mb-4">
        <h1 class="titulo-sima mb-0">SIMA</h1>
        <div class="d-flex gap-2">
            <a href="/dashboard" class="btn btn-primary">Menú</a>
            <a href="/clientes/lista" class="btn btn-primary">Lista de clientes</a>
            <a th:if="${canManageCampaigns}" href="/envio/lista" class="btn btn-primary">Campañas</a>
        </div>
    </div>

    <div class="d-flex justify-content-between align-items-center mb-3">
        <h3 class="mb-0">Lista de Anuncios</h3>
        <a th:if="${canManageAds}" href="/anuncios/nuevo" class="btn btn-primary">Crear Anuncio</a>
    </div>

    <div class="card shadow-sm">
        <div class="card-body table-responsive">
            <table class="table table-striped table-hover mb-0">
                <thead class="table-light">
                <tr>
                    <th>Título</th>
                    <th>Texto</th>
                    <th>Fecha</th>
                    <th>Responsable</th>
                    <th>Info extra</th>
                </tr>
                </thead>
                <tbody>
                <tr th:each="a : ${anuncios}">
                    <td>
                        <div th:text="${a.titulo}"></div>
                        <small th:text="${a.imagen}"></small>
                    </td>
                    <td th:text="${a.texto}"></td>
                    <td th:text="${a.fechaPublicacion}"></td>
                    <td th:text="${a.creadoPor != null ? a.creadoPor.nombre : 'Sin asignar'}"></td>
                    <td th:text="${a.informacionExtraTipo + ' - ' + a.informacionExtraValor}"></td>
                </tr>
                </tbody>
            </table>
        </div>
    </div>
</div>
</body>
</html>
'@

Write-Utf8NoBom 'D:\Descargas\sima\src\main\resources\templates\envio-form.html' @'
<!DOCTYPE html>
<html xmlns:th="http://www.thymeleaf.org">
<head>
    <title>Nueva Campaña</title>
    <meta charset="UTF-8">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" th:href="@{/css/styles.css}">
</head>
<body class="bg-light">
<div class="container py-5">
    <div class="d-flex justify-content-between align-items-center mb-4">
        <h1 class="titulo-sima mb-0">SIMA</h1>
        <div class="d-flex gap-2">
            <a href="/dashboard" class="btn btn-primary">Menú</a>
            <a href="/anuncios/lista" class="btn btn-primary">Lista de anuncios</a>
            <a href="/clientes/lista" class="btn btn-primary">Lista de clientes</a>
            <a href="/envio/lista" class="btn btn-primary">Campañas</a>
        </div>
    </div>

    <h3 class="mb-4">Nueva Campaña de Envío</h3>

    <div class="card shadow-sm">
        <div class="card-body">
            <form th:action="@{/envio/guardar}" th:object="${campana}" method="post">
                <div class="row g-3">
                    <div class="col-md-6">
                        <label class="form-label">Nombre de la campaña</label>
                        <input type="text" class="form-control" th:field="*{nombre}" required>
                    </div>
                    <div class="col-md-6">
                        <label class="form-label">Anuncio</label>
                        <select class="form-select" th:field="*{anuncio.id}" required>
                            <option value="">Selecciona</option>
                            <option th:each="anuncio : ${anuncios}" th:value="${anuncio.id}" th:text="${anuncio.titulo}"></option>
                        </select>
                    </div>
                    <div class="col-md-6">
                        <label class="form-label">Gerente responsable</label>
                        <select class="form-select" th:field="*{creadoPor.id}" required>
                            <option value="">Selecciona</option>
                            <option th:each="gerente : ${gerentes}" th:value="${gerente.id}" th:text="${gerente.nombre}"></option>
                        </select>
                    </div>
                    <div class="col-md-6">
                        <label class="form-label">Programada para</label>
                        <input type="datetime-local" class="form-control" th:field="*{programadaPara}">
                        <div class="form-text">Si la dejas vacía y no eliges envío inmediato, la campaña queda en borrador.</div>
                    </div>
                </div>

                <hr class="my-4">
                <h5 class="mb-3">Segmentación</h5>
                <div class="row g-3">
                    <div class="col-md-4">
                        <label class="form-label">Sucursal</label>
                        <select class="form-select" th:field="*{sucursal.id}">
                            <option value="">Todas</option>
                            <option th:each="sucursal : ${sucursales}" th:value="${sucursal.id}" th:text="${sucursal.nombre}"></option>
                        </select>
                    </div>
                    <div class="col-md-4">
                        <label class="form-label">Facturación mínima</label>
                        <input type="number" step="0.01" class="form-control" th:field="*{facturacionMin}">
                    </div>
                    <div class="col-md-4">
                        <label class="form-label">Facturación máxima</label>
                        <input type="number" step="0.01" class="form-control" th:field="*{facturacionMax}">
                    </div>
                    <div class="col-md-4">
                        <label class="form-label">Tamaño de empresa</label>
                        <select class="form-select" th:field="*{tamanoEmpresa}">
                            <option value="">Todos</option>
                            <option th:each="tamano : ${tamanos}" th:value="${tamano}" th:text="${tamano}"></option>
                        </select>
                    </div>
                    <div class="col-md-4">
                        <label class="form-label">Categoría de producto</label>
                        <input type="text" class="form-control" th:field="*{categoriaProducto}">
                    </div>
                    <div class="col-md-4">
                        <label class="form-label">Giro</label>
                        <input type="text" class="form-control" th:field="*{giro}">
                    </div>
                </div>

                <div class="form-check form-switch mt-4">
                    <input class="form-check-input" type="checkbox" th:field="*{enviarAhora}">
                    <label class="form-check-label" for="enviarAhora">Enviar ahora</label>
                </div>

                <div class="d-flex gap-2 mt-4">
                    <button type="submit" class="btn btn-primary">Guardar campaña</button>
                    <a href="/envio/lista" class="btn btn-secondary">Ver campañas</a>
                </div>
            </form>
        </div>
    </div>
</div>
</body>
</html>
'@

Write-Utf8NoBom 'D:\Descargas\sima\src\main\resources\templates\campana-lista.html' @'
<!DOCTYPE html>
<html xmlns:th="http://www.thymeleaf.org">
<head>
    <title>Campañas de Envío</title>
    <meta charset="UTF-8">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" th:href="@{/css/styles.css}">
</head>
<body class="bg-light">
<div class="container py-5">
    <div class="d-flex justify-content-between align-items-center mb-4">
        <h1 class="titulo-sima mb-0">SIMA</h1>
        <div class="d-flex gap-2">
            <a href="/dashboard" class="btn btn-primary">Menú</a>
            <a href="/anuncios/lista" class="btn btn-primary">Anuncios</a>
            <a href="/clientes/lista" class="btn btn-primary">Clientes</a>
        </div>
    </div>

    <div class="d-flex justify-content-between align-items-center mb-3">
        <div>
            <h3 class="mb-0">Campañas de Envío</h3>
            <small class="text-muted">Programadas o listas para envío segmentado.</small>
        </div>
        <a href="/envio" class="btn btn-primary">Nueva campaña</a>
    </div>

    <div class="card shadow-sm">
        <div class="card-body table-responsive">
            <table class="table table-striped align-middle mb-0">
                <thead class="table-light">
                <tr>
                    <th>Campaña</th>
                    <th>Anuncio</th>
                    <th>Programada</th>
                    <th>Estado</th>
                    <th>Destinatarios</th>
                    <th>Resultado</th>
                    <th>Acciones</th>
                </tr>
                </thead>
                <tbody>
                <tr th:each="campana : ${campanas}">
                    <td>
                        <div th:text="${campana.nombre}"></div>
                        <small class="text-muted" th:text="${campana.sucursal != null ? campana.sucursal.nombre : 'Todas las sucursales'}"></small>
                    </td>
                    <td th:text="${campana.anuncio != null ? campana.anuncio.titulo : 'Sin anuncio'}"></td>
                    <td th:text="${campana.programadaPara != null ? #temporals.format(campana.programadaPara, 'yyyy-MM-dd HH:mm') : 'Sin programar'}"></td>
                    <td><span class="badge text-bg-secondary" th:text="${campana.estado}"></span></td>
                    <td th:text="${campana.totalDestinatarios}"></td>
                    <td th:text="${campana.enviosExitosos + ' ok / ' + campana.enviosError + ' error'}"></td>
                    <td>
                        <div class="d-flex gap-2">
                            <a th:href="@{'/envio/resultado/' + ${campana.id}}" class="btn btn-sm btn-outline-primary">Detalle</a>
                            <form th:if="${campana.estado.name() == 'BORRADOR' or campana.estado.name() == 'PROGRAMADA'}" th:action="@{'/envio/ejecutar/' + ${campana.id}}" method="post">
                                <button type="submit" class="btn btn-sm btn-primary">Ejecutar ahora</button>
                            </form>
                        </div>
                    </td>
                </tr>
                <tr th:if="${#lists.isEmpty(campanas)}">
                    <td colspan="7" class="text-center text-muted py-4">Aún no hay campañas registradas.</td>
                </tr>
                </tbody>
            </table>
        </div>
    </div>
</div>
</body>
</html>
'@

Write-Utf8NoBom 'D:\Descargas\sima\src\main\resources\templates\envio-resultado.html' @'
<!DOCTYPE html>
<html xmlns:th="http://www.thymeleaf.org">
<head>
    <title>Resultado de la Campaña</title>
    <meta charset="UTF-8">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" th:href="@{/css/styles.css}">
</head>
<body class="bg-light">
<div class="container py-5">
    <div class="d-flex justify-content-between align-items-center mb-4">
        <h1 class="titulo-sima mb-0">SIMA</h1>
        <div class="d-flex gap-2">
            <a href="/dashboard" class="btn btn-primary">Menú</a>
            <a href="/envio" class="btn btn-primary">Nueva campaña</a>
            <a href="/envio/lista" class="btn btn-primary">Campañas</a>
        </div>
    </div>

    <div class="card shadow-sm mb-4">
        <div class="card-body">
            <h3 class="mb-3" th:text="${resultado}"></h3>
            <div class="row g-3 small">
                <div class="col-md-3"><strong>Campaña:</strong> <span th:text="${campana.nombre}"></span></div>
                <div class="col-md-3"><strong>Estado:</strong> <span th:text="${campana.estado}"></span></div>
                <div class="col-md-3"><strong>Destinatarios:</strong> <span th:text="${campana.totalDestinatarios}"></span></div>
                <div class="col-md-3"><strong>Resultado:</strong> <span th:text="${campana.enviosExitosos + ' enviados / ' + campana.enviosError + ' con error'}"></span></div>
            </div>
        </div>
    </div>

    <div class="card shadow-sm">
        <div class="card-body table-responsive">
            <table class="table table-striped mb-0">
                <thead class="table-light">
                <tr>
                    <th>Cliente</th>
                    <th>Teléfono</th>
                    <th>Estado</th>
                    <th>Fecha de intento</th>
                    <th>Detalle</th>
                </tr>
                </thead>
                <tbody>
                <tr th:each="destinatario : ${destinatarios}">
                    <td th:text="${destinatario.cliente.nombre}"></td>
                    <td th:text="${destinatario.cliente.telefono}"></td>
                    <td th:text="${destinatario.estado}"></td>
                    <td th:text="${destinatario.fechaIntento != null ? #temporals.format(destinatario.fechaIntento, 'yyyy-MM-dd HH:mm') : 'Pendiente'}"></td>
                    <td th:text="${destinatario.detalleError != null ? destinatario.detalleError : 'Sin incidencias'}"></td>
                </tr>
                <tr th:if="${#lists.isEmpty(destinatarios)}">
                    <td colspan="5" class="text-center text-muted py-4">La campaña no tiene destinatarios con los filtros actuales.</td>
                </tr>
                </tbody>
            </table>
        </div>
    </div>
</div>
</body>
</html>
'@

Write-Utf8NoBom 'D:\Descargas\sima\src\main\resources\templates\solicitudes-lista.html' @'
<!DOCTYPE html>
<html xmlns:th="http://www.thymeleaf.org">
<head>
    <title>Solicitudes de Clientes</title>
    <meta charset="UTF-8">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" th:href="@{/css/styles.css}">
</head>
<body class="bg-light">
<div class="container py-5">
    <div class="d-flex justify-content-between align-items-center mb-4">
        <h1 class="titulo-sima mb-0">SIMA</h1>
        <div class="d-flex gap-2">
            <a href="/dashboard" class="btn btn-primary">Menú</a>
            <a th:if="${canManageCampaigns}" href="/envio/lista" class="btn btn-primary">Campañas</a>
            <a href="/clientes/lista" class="btn btn-primary">Clientes</a>
        </div>
    </div>

    <div class="d-flex justify-content-between align-items-center mb-3">
        <div>
            <h3 class="mb-0">Solicitudes e Interacciones</h3>
            <small class="text-muted">El rol de sucursal ve las solicitudes asignadas cuando su empleado está enlazado con el login central.</small>
        </div>
    </div>

    <div class="card shadow-sm">
        <div class="card-body table-responsive">
            <table class="table table-striped align-middle mb-0">
                <thead class="table-light">
                <tr>
                    <th>Fecha</th>
                    <th>Cliente</th>
                    <th>Producto</th>
                    <th>Tipo</th>
                    <th>Responsable</th>
                    <th>Estado</th>
                    <th>Detalle</th>
                </tr>
                </thead>
                <tbody>
                <tr th:each="solicitud : ${solicitudes}">
                    <td th:text="${#temporals.format(solicitud.fechaInteraccion, 'yyyy-MM-dd HH:mm')}"></td>
                    <td>
                        <div th:text="${solicitud.cliente != null ? solicitud.cliente.nombre : solicitud.telefonoCliente}"></div>
                        <small th:text="${solicitud.telefonoCliente}"></small>
                    </td>
                    <td th:text="${solicitud.productoNombre != null ? solicitud.productoNombre : 'Sin producto'}"></td>
                    <td th:text="${solicitud.tipo}"></td>
                    <td th:text="${solicitud.jefeResponsable != null ? solicitud.jefeResponsable.nombre : 'Sin asignar'}"></td>
                    <td th:text="${solicitud.estadoSeguimiento}"></td>
                    <td>
                        <div th:text="${solicitud.mensajeCliente}"></div>
                        <small class="text-muted" th:text="${solicitud.notificacionInterna}"></small>
                    </td>
                </tr>
                <tr th:if="${#lists.isEmpty(solicitudes)}">
                    <td colspan="7" class="text-center text-muted py-4">Aún no hay respuestas registradas para mostrar.</td>
                </tr>
                </tbody>
            </table>
        </div>
    </div>
</div>
</body>
</html>
'@

Write-Utf8NoBom 'D:\Descargas\sima\src\main\resources\templates\reportes.html' @'
<!DOCTYPE html>
<html xmlns:th="http://www.thymeleaf.org">
<head>
    <title>Reportes</title>
    <meta charset="UTF-8">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" th:href="@{/css/styles.css}">
</head>
<body class="bg-light">
<div class="container py-5">
    <div class="d-flex justify-content-between align-items-center mb-4">
        <h1 class="titulo-sima mb-0">SIMA</h1>
        <div class="d-flex gap-2">
            <a href="/dashboard" class="btn btn-primary">Menú</a>
            <a href="/solicitudes" class="btn btn-primary">Solicitudes</a>
            <a th:if="${canManageCampaigns}" href="/envio/lista" class="btn btn-primary">Campañas</a>
        </div>
    </div>

    <div class="row g-4">
        <div class="col-lg-6">
            <div class="card shadow-sm h-100">
                <div class="card-body">
                    <div class="d-flex justify-content-between align-items-center mb-3">
                        <h4 class="mb-0">Campañas</h4>
                        <a th:if="${canManageCampaigns}" href="/reportes/campanas.csv" class="btn btn-sm btn-outline-primary">Exportar CSV</a>
                    </div>
                    <div class="table-responsive">
                        <table class="table table-striped mb-0">
                            <thead class="table-light">
                            <tr>
                                <th>Campaña</th>
                                <th>Estado</th>
                                <th>Resultado</th>
                            </tr>
                            </thead>
                            <tbody>
                            <tr th:each="campana : ${campanas}">
                                <td th:text="${campana.nombre}"></td>
                                <td th:text="${campana.estado}"></td>
                                <td th:text="${campana.enviosExitosos + ' enviados / ' + campana.enviosError + ' error'}"></td>
                            </tr>
                            <tr th:if="${#lists.isEmpty(campanas)}">
                                <td colspan="3" class="text-center text-muted py-4">Sin campañas registradas.</td>
                            </tr>
                            </tbody>
                        </table>
                    </div>
                </div>
            </div>
        </div>

        <div class="col-lg-6">
            <div class="card shadow-sm h-100">
                <div class="card-body">
                    <div class="d-flex justify-content-between align-items-center mb-3">
                        <h4 class="mb-0">Solicitudes</h4>
                        <a href="/reportes/solicitudes.csv" class="btn btn-sm btn-outline-primary">Exportar CSV</a>
                    </div>
                    <div class="table-responsive">
                        <table class="table table-striped mb-0">
                            <thead class="table-light">
                            <tr>
                                <th>Cliente</th>
                                <th>Tipo</th>
                                <th>Responsable</th>
                            </tr>
                            </thead>
                            <tbody>
                            <tr th:each="solicitud : ${solicitudes}">
                                <td th:text="${solicitud.cliente != null ? solicitud.cliente.nombre : solicitud.telefonoCliente}"></td>
                                <td th:text="${solicitud.tipo}"></td>
                                <td th:text="${solicitud.jefeResponsable != null ? solicitud.jefeResponsable.nombre : 'Sin asignar'}"></td>
                            </tr>
                            <tr th:if="${#lists.isEmpty(solicitudes)}">
                                <td colspan="3" class="text-center text-muted py-4">Sin solicitudes registradas.</td>
                            </tr>
                            </tbody>
                        </table>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>
</body>
</html>
'@
