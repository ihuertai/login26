function Write-Utf8NoBom([string]$Path, [string]$Content) {
  $dir = Split-Path -Parent $Path
  if ($dir -and -not (Test-Path $dir)) {
    New-Item -ItemType Directory -Path $dir -Force | Out-Null
  }
  $utf8NoBom = New-Object System.Text.UTF8Encoding($false)
  [System.IO.File]::WriteAllText($Path, $Content, $utf8NoBom)
}

Write-Utf8NoBom 'D:\Descargas\sima\src\main\java\mx\ipn\sima\service\SucursalService.java' @'
package mx.ipn.sima.service;

import mx.ipn.sima.model.Sucursal;
import mx.ipn.sima.repository.SucursalRepository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
public class SucursalService {

    private final SucursalRepository sucursalRepository;

    public SucursalService(SucursalRepository sucursalRepository) {
        this.sucursalRepository = sucursalRepository;
    }

    @Transactional(readOnly = true)
    public List<Sucursal> listarSucursales() {
        return sucursalRepository.findAllByActiveTrueOrderByNombreAsc();
    }

    @Transactional(readOnly = true)
    public Sucursal obtenerSucursal(Long id) {
        return sucursalRepository.findById(id)
                .orElseThrow(() -> new IllegalArgumentException("Sucursal no encontrada"));
    }

    @Transactional
    public Sucursal guardarSucursal(Sucursal sucursal) {
        validateUnique(sucursal);
        return sucursalRepository.save(sucursal);
    }

    @Transactional
    public void eliminarSucursal(Long id) {
        Sucursal sucursal = obtenerSucursal(id);
        sucursal.setActive(false);
        sucursalRepository.save(sucursal);
    }

    private void validateUnique(Sucursal sucursal) {
        String clave = sucursal.getClave() != null ? sucursal.getClave().trim().toUpperCase() : "";
        String nombre = sucursal.getNombre() != null ? sucursal.getNombre().trim() : "";

        sucursalRepository.findAllByActiveTrueOrderByNombreAsc().forEach(existing -> {
            if (sucursal.getId() != null && existing.getId().equals(sucursal.getId())) {
                return;
            }
            if (existing.getClave() != null && existing.getClave().equalsIgnoreCase(clave)) {
                throw new IllegalArgumentException("Ya existe una sucursal con esa clave");
            }
            if (existing.getNombre() != null && existing.getNombre().equalsIgnoreCase(nombre)) {
                throw new IllegalArgumentException("Ya existe una sucursal con ese nombre");
            }
        });

        sucursal.setClave(clave);
        sucursal.setNombre(nombre);
        sucursal.setTelefono(sucursal.getTelefono() != null ? sucursal.getTelefono().trim() : null);
        sucursal.setCorreo(sucursal.getCorreo() != null ? sucursal.getCorreo().trim() : null);
        sucursal.setActive(true);
    }
}
'@

Write-Utf8NoBom 'D:\Descargas\sima\src\main\java\mx\ipn\sima\controller\SucursalController.java' @'
package mx.ipn.sima.controller;

import jakarta.servlet.http.HttpSession;
import mx.ipn.sima.model.Sucursal;
import mx.ipn.sima.service.RoleAccessService;
import mx.ipn.sima.service.SucursalService;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.ModelAttribute;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;

@Controller
@RequestMapping("/sucursales")
public class SucursalController {

    private final SucursalService sucursalService;
    private final RoleAccessService roleAccessService;

    public SucursalController(SucursalService sucursalService, RoleAccessService roleAccessService) {
        this.sucursalService = sucursalService;
        this.roleAccessService = roleAccessService;
    }

    @GetMapping
    public String mostrarPantalla(Model model, HttpSession session) {
        roleAccessService.requireCampaignManagement(session);
        model.addAttribute("sucursal", new Sucursal());
        model.addAttribute("sucursales", sucursalService.listarSucursales());
        return "sucursales";
    }

    @GetMapping("/{id}")
    public String editarSucursal(@PathVariable Long id, Model model, HttpSession session) {
        roleAccessService.requireCampaignManagement(session);
        model.addAttribute("sucursal", sucursalService.obtenerSucursal(id));
        model.addAttribute("sucursales", sucursalService.listarSucursales());
        return "sucursales";
    }

    @PostMapping("/guardar")
    public String guardarSucursal(@ModelAttribute Sucursal sucursal, HttpSession session, Model model) {
        roleAccessService.requireCampaignManagement(session);
        try {
            sucursalService.guardarSucursal(sucursal);
            return "redirect:/sucursales";
        } catch (IllegalArgumentException ex) {
            model.addAttribute("error", ex.getMessage());
            model.addAttribute("sucursal", sucursal);
            model.addAttribute("sucursales", sucursalService.listarSucursales());
            return "sucursales";
        }
    }

    @PostMapping("/eliminar/{id}")
    public String eliminarSucursal(@PathVariable Long id, HttpSession session) {
        roleAccessService.requireCampaignManagement(session);
        sucursalService.eliminarSucursal(id);
        return "redirect:/sucursales";
    }
}
'@

Write-Utf8NoBom 'D:\Descargas\sima\src\main\java\mx\ipn\sima\controller\UsuariosExternosController.java' @'
package mx.ipn.sima.controller;

import jakarta.servlet.http.HttpSession;
import mx.ipn.sima.service.RoleAccessService;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;

import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;

@Controller
@RequestMapping("/usuarios")
public class UsuariosExternosController {

    private final RoleAccessService roleAccessService;
    private final String loginAdminUrl;

    public UsuariosExternosController(RoleAccessService roleAccessService,
                                      @Value("${app.sso.login-admin-url:http://localhost:5173/admin}") String loginAdminUrl) {
        this.roleAccessService = roleAccessService;
        this.loginAdminUrl = loginAdminUrl;
    }

    @GetMapping
    public String mostrarPantalla(Model model, HttpSession session) {
        roleAccessService.requireCampaignManagement(session);
        String authToken = (String) session.getAttribute("AUTH_TOKEN");
        String resolvedUrl = authToken != null && !authToken.isBlank()
                ? loginAdminUrl + "?ssoToken=" + URLEncoder.encode(authToken, StandardCharsets.UTF_8)
                : loginAdminUrl;
        model.addAttribute("loginAdminUrl", resolvedUrl);
        return "usuarios-externos";
    }
}
'@

Write-Utf8NoBom 'D:\Descargas\sima\src\main\java\mx\ipn\sima\config\WebMvcConfig.java' @'
package mx.ipn.sima.config;

import org.springframework.context.annotation.Configuration;
import org.springframework.web.servlet.config.annotation.InterceptorRegistry;
import org.springframework.web.servlet.config.annotation.WebMvcConfigurer;

@Configuration
public class WebMvcConfig implements WebMvcConfigurer {

    private final SsoSessionInterceptor ssoSessionInterceptor;

    public WebMvcConfig(SsoSessionInterceptor ssoSessionInterceptor) {
        this.ssoSessionInterceptor = ssoSessionInterceptor;
    }

    @Override
    public void addInterceptors(InterceptorRegistry registry) {
        registry.addInterceptor(ssoSessionInterceptor)
                .addPathPatterns(
                        "/dashboard",
                        "/gestion-clientes",
                        "/gestion-anuncios",
                        "/clientes/**",
                        "/anuncios/**",
                        "/envio/**",
                        "/solicitudes/**",
                        "/sucursales/**",
                        "/usuarios/**",
                        "/reportes/**"
                )
                .excludePathPatterns(
                        "/",
                        "/auth/**",
                        "/webhook/**",
                        "/css/**",
                        "/js/**",
                        "/images/**",
                        "/docs/**",
                        "/favicon.ico",
                        "/error"
                );
    }
}
'@

Write-Utf8NoBom 'D:\Descargas\sima\src\main\resources\templates\sucursales.html' @'
<!DOCTYPE html>
<html xmlns:th="http://www.thymeleaf.org">
<head>
    <title>Sucursales</title>
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
            <a href="/envio/lista" class="btn btn-primary">Campa&ntilde;as</a>
            <a href="/usuarios" class="btn btn-primary">Usuarios</a>
        </div>
    </div>

    <div class="row g-4">
        <div class="col-lg-5">
            <div class="card shadow-sm">
                <div class="card-body">
                    <h3 class="mb-3" th:text="${sucursal.id != null ? 'Editar sucursal' : 'Registrar sucursal'}">Registrar sucursal</h3>
                    <p class="text-muted">Disponible solo para el rol gerente.</p>
                    <div class="alert alert-danger" th:if="${error}" th:text="${error}"></div>
                    <form th:action="@{/sucursales/guardar}" th:object="${sucursal}" method="post">
                        <input type="hidden" th:field="*{id}">
                        <div class="mb-3">
                            <label class="form-label">Clave</label>
                            <input type="text" class="form-control" th:field="*{clave}" required>
                        </div>
                        <div class="mb-3">
                            <label class="form-label">Nombre</label>
                            <input type="text" class="form-control" th:field="*{nombre}" required>
                        </div>
                        <div class="mb-3">
                            <label class="form-label">Tel&eacute;fono</label>
                            <input type="text" class="form-control" th:field="*{telefono}">
                        </div>
                        <div class="mb-3">
                            <label class="form-label">Correo</label>
                            <input type="email" class="form-control" th:field="*{correo}">
                        </div>
                        <div class="d-flex gap-2">
                            <button type="submit" class="btn btn-primary" th:text="${sucursal.id != null ? 'Guardar cambios' : 'Guardar sucursal'}">Guardar sucursal</button>
                            <a href="/sucursales" class="btn btn-secondary" th:if="${sucursal.id != null}">Cancelar</a>
                        </div>
                    </form>
                </div>
            </div>
        </div>

        <div class="col-lg-7">
            <div class="card shadow-sm">
                <div class="card-body table-responsive">
                    <h3 class="mb-3">Sucursales registradas</h3>
                    <table class="table table-striped mb-0">
                        <thead class="table-light">
                        <tr>
                            <th>Clave</th>
                            <th>Nombre</th>
                            <th>Tel&eacute;fono</th>
                            <th>Correo</th>
                            <th>Acciones</th>
                        </tr>
                        </thead>
                        <tbody>
                        <tr th:each="item : ${sucursales}">
                            <td th:text="${item.clave}"></td>
                            <td th:text="${item.nombre}"></td>
                            <td th:text="${item.telefono}"></td>
                            <td th:text="${item.correo}"></td>
                            <td>
                                <div class="d-flex gap-2">
                                    <a th:href="@{'/sucursales/' + ${item.id}}" class="btn btn-sm btn-outline-primary">Editar</a>
                                    <form th:action="@{'/sucursales/eliminar/' + ${item.id}}" method="post">
                                        <button type="submit" class="btn btn-sm btn-outline-danger">Baja</button>
                                    </form>
                                </div>
                            </td>
                        </tr>
                        <tr th:if="${#lists.isEmpty(sucursales)}">
                            <td colspan="5" class="text-center text-muted py-4">A&uacute;n no hay sucursales registradas.</td>
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

Write-Utf8NoBom 'D:\Descargas\sima\src\main\resources\templates\usuarios-externos.html' @'
<!DOCTYPE html>
<html xmlns:th="http://www.thymeleaf.org">
<head>
    <title>Usuarios</title>
    <meta charset="UTF-8">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" th:href="@{/css/styles.css}">
</head>
<body class="bg-light">
<div class="container-fluid py-4">
    <div class="d-flex justify-content-between align-items-center mb-4 px-3">
        <h1 class="titulo-sima mb-0">SIMA</h1>
        <div class="d-flex gap-2">
            <a href="/dashboard" class="btn btn-primary">Men&uacute;</a>
            <a href="/sucursales" class="btn btn-primary">Sucursales</a>
            <a href="/envio/lista" class="btn btn-primary">Campa&ntilde;as</a>
        </div>
    </div>

    <div class="card shadow-sm mx-3">
        <div class="card-body">
            <div class="d-flex justify-content-between align-items-center mb-3">
                <div>
                    <h3 class="mb-1">Usuarios</h3>
                    <p class="text-muted mb-0">Panel del login integrado para administraci&oacute;n de usuarios y roles.</p>
                </div>
                <a class="btn btn-outline-primary" th:href="${loginAdminUrl}" target="_blank" rel="noreferrer">Abrir en nueva pesta&ntilde;a</a>
            </div>
            <div class="ratio" style="--bs-aspect-ratio: 70%;">
                <iframe th:src="${loginAdminUrl}" title="Panel de usuarios" style="border: 0; width: 100%;"></iframe>
            </div>
        </div>
    </div>
</div>
</body>
</html>
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

    <div class="row g-4 mb-4" th:if="${canManageCampaigns}">
        <div class="col-md-6">
            <div class="card shadow-sm h-100">
                <div class="card-body">
                    <h5 class="card-title">Sucursales</h5>
                    <p class="text-muted">Cat&aacute;logo de sucursales disponible para segmentaci&oacute;n y registro de clientes.</p>
                    <a href="/sucursales" class="btn btn-primary w-100">Gestionar Sucursales</a>
                </div>
            </div>
        </div>
        <div class="col-md-6">
            <div class="card shadow-sm h-100">
                <div class="card-body">
                    <h5 class="card-title">Usuarios</h5>
                    <p class="text-muted">Acceso al panel del login para administrar usuarios y roles.</p>
                    <a href="/usuarios" class="btn btn-primary w-100">Gestionar Usuarios</a>
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

Write-Utf8NoBom 'D:\Descargas\sima\src\main\resources\application.properties' @'
server.port=8081
spring.application.name=sima

spring.datasource.url=jdbc:postgresql://localhost:5432/sima_db
spring.datasource.username=postgres
spring.datasource.password=1234
spring.jpa.hibernate.ddl-auto=update
spring.jpa.show-sql=true
spring.jpa.database-platform=org.hibernate.dialect.PostgreSQLDialect

server.servlet.encoding.charset=UTF-8
server.servlet.encoding.enabled=true
server.servlet.encoding.force=true
spring.messages.encoding=UTF-8
spring.thymeleaf.encoding=UTF-8

# Configuracion de WhatsApp Cloud API
whatsapp.api.url=https://graph.facebook.com/v22.0/
whatsapp.api.token=EAASMpfbwQe0BQyS0eIzzMeuIibH7rslgSuwqLrQmkw9TTRb1ylDZAQJZCQhOaLL7xPMdI0Wkyu1sMsnlqZBn6nSbctHvGKbigFiNRVrOG0t0DGgiGaKp6wZAZA9sJ04Q5cwi0gWgsFaVUTAQ7fxgewqU697IimascZAJdmMtQIm7eiwbytMpw4YsbTWqTh8BoZBZA64ZC6CXWHs1DHgKOAzHZAdlKaBC44MmbucP4fZBSUJ
whatsapp.api.phone-number-id=976905375514782
whatsapp.api.waba-id=914819431152540

whatsapp.flow.default.coordinator=526442362547
whatsapp.flow.default.asesor=Asesor SIMA
whatsapp.flow.default.asesor-phone=526442362547
whatsapp.flow.mas-info-text=Este producto incluye detalles tecnicos, beneficios y opciones de precio. Si deseas, un asesor puede ayudarte a elegir la mejor opcion.
whatsapp.flow.mas-info-pdf-url=https://transversall.net/informacion-promocion.pdf
whatsapp.flow.mas-info-pdf-filename=informacion-promocion.pdf
whatsapp.flow.mas-info-pdf-caption=Informacion detallada de la promocion
whatsapp.flow.product-routing=

app.jwt.secret=login-app-secret-change-me-2026
app.jwt.issuer=mx.ipn.cajeme.login
app.sso.login-url=http://localhost:5173
app.sso.login-admin-url=http://localhost:5173/admin
'@
