function Write-Utf8NoBom([string]$Path, [string]$Content) {
  $utf8NoBom = New-Object System.Text.UTF8Encoding($false)
  [System.IO.File]::WriteAllText($Path, $Content, $utf8NoBom)
}

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
                    <small class="text-muted" th:text="${metrics.solicitudesContacto()} + ' contacto / ' + ${metrics.solicitudesMasInfo()} + ' m&aacute;s info'">0</small>
                </div>
            </div>
        </div>
    </div>

    <div class="row g-4 mb-4">
        <div class="col-md-3">
            <div class="card shadow-sm h-100">
                <div class="card-body">
                    <h5 class="card-title">Gesti&oacute;n de Clientes</h5>
                    <a href="/clientes/lista" class="btn btn-primary w-100 mb-2">Ver Clientes</a>
                    <a th:if="${canManageClients}" href="/clientes/nuevo" class="btn btn-primary w-100">Agregar Cliente</a>
                </div>
            </div>
        </div>

        <div class="col-md-3">
            <div class="card shadow-sm h-100">
                <div class="card-body">
                    <h5 class="card-title">Gesti&oacute;n de Anuncios</h5>
                    <a href="/anuncios/lista" class="btn btn-primary w-100 mb-2">Ver Anuncios</a>
                    <a th:if="${canManageAds}" href="/anuncios/nuevo" class="btn btn-primary w-100">Crear Anuncio</a>
                </div>
            </div>
        </div>

        <div class="col-md-3">
            <div class="card shadow-sm h-100">
                <div class="card-body">
                    <h5 class="card-title">Env&iacute;o de Mensajes</h5>
                    <a th:if="${canManageCampaigns}" href="/envio/lista" class="btn btn-primary w-100 mb-2">Ver Campa&ntilde;as</a>
                    <a th:if="${canManageCampaigns}" href="/envio" class="btn btn-primary w-100">Nueva Campa&ntilde;a</a>
                    <div th:if="${!canManageCampaigns}" class="small text-muted mt-2">Solo un gerente puede crear campa&ntilde;as.</div>
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
                            <th>Campa&ntilde;a</th>
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
                            <td colspan="3" class="text-center text-muted py-4">A&uacute;n no hay campa&ntilde;as registradas.</td>
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
                            <td colspan="3" class="text-center text-muted py-4">A&uacute;n no hay interacciones registradas.</td>
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

Write-Utf8NoBom 'D:\Descargas\sima\src\main\resources\templates\envio-form.html' @'
<!DOCTYPE html>
<html xmlns:th="http://www.thymeleaf.org">
<head>
    <title>Nueva Campa&ntilde;a</title>
    <meta charset="UTF-8">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" th:href="@{/css/styles.css}">
</head>
<body class="bg-light">
<div class="container py-5">
    <div class="d-flex justify-content-between align-items-center mb-4">
        <h1 class="titulo-sima mb-0">SIMA</h1>
        <div class="d-flex gap-2">
            <a href="/dashboard" class="btn btn-primary">Men&uacute;</a>
            <a href="/anuncios/lista" class="btn btn-primary">Lista de anuncios</a>
            <a href="/clientes/lista" class="btn btn-primary">Lista de clientes</a>
            <a href="/envio/lista" class="btn btn-primary">Campa&ntilde;as</a>
        </div>
    </div>

    <h3 class="mb-4">Nueva Campa&ntilde;a de Env&iacute;o</h3>

    <div class="card shadow-sm">
        <div class="card-body">
            <form th:action="@{/envio/guardar}" th:object="${campana}" method="post">
                <div class="row g-3">
                    <div class="col-md-6">
                        <label class="form-label">Nombre de la campa&ntilde;a</label>
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
                        <div class="form-text">Si la dejas vac&iacute;a y no eliges env&iacute;o inmediato, la campa&ntilde;a queda en borrador.</div>
                    </div>
                </div>

                <hr class="my-4">
                <h5 class="mb-3">Segmentaci&oacute;n</h5>
                <div class="row g-3">
                    <div class="col-md-4">
                        <label class="form-label">Sucursal</label>
                        <select class="form-select" th:field="*{sucursal.id}">
                            <option value="">Todas</option>
                            <option th:each="sucursal : ${sucursales}" th:value="${sucursal.id}" th:text="${sucursal.nombre}"></option>
                        </select>
                    </div>
                    <div class="col-md-4">
                        <label class="form-label">Facturaci&oacute;n m&iacute;nima</label>
                        <input type="number" step="0.01" class="form-control" th:field="*{facturacionMin}">
                    </div>
                    <div class="col-md-4">
                        <label class="form-label">Facturaci&oacute;n m&aacute;xima</label>
                        <input type="number" step="0.01" class="form-control" th:field="*{facturacionMax}">
                    </div>
                    <div class="col-md-4">
                        <label class="form-label">Tama&ntilde;o de empresa</label>
                        <select class="form-select" th:field="*{tamanoEmpresa}">
                            <option value="">Todos</option>
                            <option th:each="tamano : ${tamanos}" th:value="${tamano}" th:text="${tamano}"></option>
                        </select>
                    </div>
                    <div class="col-md-4">
                        <label class="form-label">Categor&iacute;a de producto</label>
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
                    <button type="submit" class="btn btn-primary">Guardar campa&ntilde;a</button>
                    <a href="/envio/lista" class="btn btn-secondary">Ver campa&ntilde;as</a>
                </div>
            </form>
        </div>
    </div>
</div>
</body>
</html>
'@
