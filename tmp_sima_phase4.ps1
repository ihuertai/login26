function Write-Utf8NoBom([string]$Path, [string]$Content) {
  $dir = Split-Path -Parent $Path
  if ($dir -and -not (Test-Path $dir)) {
    New-Item -ItemType Directory -Path $dir -Force | Out-Null
  }
  $utf8NoBom = New-Object System.Text.UTF8Encoding($false)
  [System.IO.File]::WriteAllText($Path, $Content, $utf8NoBom)
}

Write-Utf8NoBom 'D:\Descargas\sima\src\main\java\mx\ipn\sima\dto\DashboardMetrics.java' @'
package mx.ipn.sima.dto;

import mx.ipn.sima.model.CampanaEnvio;
import mx.ipn.sima.model.InteraccionCliente;

import java.util.List;

public record DashboardMetrics(
        long totalClientes,
        long totalAnuncios,
        long totalCampanas,
        long campanasProgramadas,
        long campanasEjecutadas,
        long totalEnviosExitosos,
        long totalEnviosError,
        long totalInteracciones,
        long solicitudesContacto,
        long solicitudesMasInfo,
        List<CampanaEnvio> recentCampaigns,
        List<InteraccionCliente> recentInteractions
) {
}
'@

Write-Utf8NoBom 'D:\Descargas\sima\src\main\java\mx\ipn\sima\service\DashboardService.java' @'
package mx.ipn.sima.service;

import mx.ipn.sima.dto.DashboardMetrics;
import mx.ipn.sima.model.CampanaEnvio;
import mx.ipn.sima.model.EstadoCampana;
import mx.ipn.sima.model.InteraccionCliente;
import mx.ipn.sima.model.TipoInteraccionCliente;
import mx.ipn.sima.repository.AnuncioRepository;
import mx.ipn.sima.repository.CampanaEnvioRepository;
import mx.ipn.sima.repository.ClienteRepository;
import mx.ipn.sima.repository.InteraccionClienteRepository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
public class DashboardService {

    private final ClienteRepository clienteRepository;
    private final AnuncioRepository anuncioRepository;
    private final CampanaEnvioRepository campanaEnvioRepository;
    private final InteraccionClienteRepository interaccionClienteRepository;

    public DashboardService(ClienteRepository clienteRepository,
                            AnuncioRepository anuncioRepository,
                            CampanaEnvioRepository campanaEnvioRepository,
                            InteraccionClienteRepository interaccionClienteRepository) {
        this.clienteRepository = clienteRepository;
        this.anuncioRepository = anuncioRepository;
        this.campanaEnvioRepository = campanaEnvioRepository;
        this.interaccionClienteRepository = interaccionClienteRepository;
    }

    @Transactional(readOnly = true)
    public DashboardMetrics getMetrics() {
        List<CampanaEnvio> campanas = campanaEnvioRepository.findAllByActiveTrueOrderByCreatedAtDesc();
        List<InteraccionCliente> interacciones = interaccionClienteRepository.findAllByActiveTrueOrderByFechaInteraccionDesc();

        long campanasProgramadas = campanas.stream()
                .filter(campana -> campana.getEstado() == EstadoCampana.PROGRAMADA)
                .count();
        long campanasEjecutadas = campanas.stream()
                .filter(campana -> campana.getEstado() == EstadoCampana.EJECUTADA || campana.getEstado() == EstadoCampana.EJECUTADA_CON_ERRORES)
                .count();
        long totalEnviosExitosos = campanas.stream()
                .map(CampanaEnvio::getEnviosExitosos)
                .filter(value -> value != null)
                .mapToLong(Integer::longValue)
                .sum();
        long totalEnviosError = campanas.stream()
                .map(CampanaEnvio::getEnviosError)
                .filter(value -> value != null)
                .mapToLong(Integer::longValue)
                .sum();
        long solicitudesContacto = interacciones.stream()
                .filter(interaccion -> interaccion.getTipo() == TipoInteraccionCliente.QUIERE_CONTACTO)
                .count();
        long solicitudesMasInfo = interacciones.stream()
                .filter(interaccion -> interaccion.getTipo() == TipoInteraccionCliente.MAS_INFO)
                .count();

        return new DashboardMetrics(
                clienteRepository.findAllByActiveTrue().size(),
                anuncioRepository.findAllByActiveTrueOrderByFechaPublicacionDescIdDesc().size(),
                campanas.size(),
                campanasProgramadas,
                campanasEjecutadas,
                totalEnviosExitosos,
                totalEnviosError,
                interacciones.size(),
                solicitudesContacto,
                solicitudesMasInfo,
                campanas.stream().limit(5).toList(),
                interacciones.stream().limit(5).toList()
        );
    }
}
'@

Write-Utf8NoBom 'D:\Descargas\sima\src\main\java\mx\ipn\sima\controller\LoginController.java' @'
package mx.ipn.sima.controller;

import jakarta.servlet.http.HttpSession;
import mx.ipn.sima.service.DashboardService;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;

@Controller
public class LoginController {

    private final String loginUrl;
    private final DashboardService dashboardService;

    public LoginController(@Value("${app.sso.login-url:http://localhost:5173}") String loginUrl,
                           DashboardService dashboardService) {
        this.loginUrl = loginUrl;
        this.dashboardService = dashboardService;
    }

    @GetMapping("/")
    public String login(HttpSession session) {
        return session.getAttribute("AUTHENTICATED_USER") != null
                ? "redirect:/dashboard"
                : "redirect:" + loginUrl;
    }

    @GetMapping("/dashboard")
    public String dashboard(Model model) {
        model.addAttribute("metrics", dashboardService.getMetrics());
        return "dashboard";
    }

    @GetMapping("/gestion-clientes")
    public String gestionClientes() {
        return "redirect:/clientes/lista";
    }

    @GetMapping("/gestion-anuncios")
    public String gestionAnuncios() {
        return "redirect:/anuncios/lista";
    }
}
'@

Write-Utf8NoBom 'D:\Descargas\sima\src\main\java\mx\ipn\sima\controller\ReporteController.java' @'
package mx.ipn.sima.controller;

import jakarta.servlet.http.HttpSession;
import mx.ipn.sima.dto.AuthenticatedUser;
import mx.ipn.sima.service.CampanaService;
import mx.ipn.sima.service.RoleAccessService;
import mx.ipn.sima.service.WhatsappInteractionService;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;

import java.nio.charset.StandardCharsets;

@Controller
@RequestMapping("/reportes")
public class ReporteController {

    private final RoleAccessService roleAccessService;
    private final CampanaService campanaService;
    private final WhatsappInteractionService whatsappInteractionService;

    public ReporteController(RoleAccessService roleAccessService,
                             CampanaService campanaService,
                             WhatsappInteractionService whatsappInteractionService) {
        this.roleAccessService = roleAccessService;
        this.campanaService = campanaService;
        this.whatsappInteractionService = whatsappInteractionService;
    }

    @GetMapping
    public String verReportes(Model model, HttpSession session) {
        roleAccessService.requireRequestsView(session);
        AuthenticatedUser user = roleAccessService.getCurrentUser(session);
        model.addAttribute("campanas", campanaService.getCampanas());
        model.addAttribute("solicitudes", whatsappInteractionService.getInteractionsForUser(user));
        return "reportes";
    }

    @GetMapping("/campanas.csv")
    public ResponseEntity<byte[]> exportarCampanas(HttpSession session) {
        roleAccessService.requireCampaignManagement(session);
        StringBuilder csv = new StringBuilder();
        csv.append("Campana,Anuncio,Estado,Destinatarios,Exitosos,Errores,Programada\\n");
        campanaService.getCampanas().forEach(campana -> csv
                .append(escape(campana.getNombre())).append(',')
                .append(escape(campana.getAnuncio() != null ? campana.getAnuncio().getTitulo() : "")).append(',')
                .append(campana.getEstado()).append(',')
                .append(campana.getTotalDestinatarios()).append(',')
                .append(campana.getEnviosExitosos()).append(',')
                .append(campana.getEnviosError()).append(',')
                .append(escape(campana.getProgramadaPara() != null ? campana.getProgramadaPara().toString() : ""))
                .append("\\n"));
        return csvResponse("campanas.csv", csv.toString());
    }

    @GetMapping("/solicitudes.csv")
    public ResponseEntity<byte[]> exportarSolicitudes(HttpSession session) {
        roleAccessService.requireRequestsView(session);
        AuthenticatedUser user = roleAccessService.getCurrentUser(session);
        StringBuilder csv = new StringBuilder();
        csv.append("Fecha,Cliente,Telefono,Producto,Tipo,Responsable,Estado,Detalle\\n");
        whatsappInteractionService.getInteractionsForUser(user).forEach(interaccion -> csv
                .append(escape(interaccion.getFechaInteraccion() != null ? interaccion.getFechaInteraccion().toString() : "")).append(',')
                .append(escape(interaccion.getCliente() != null ? interaccion.getCliente().getNombre() : "")).append(',')
                .append(escape(interaccion.getTelefonoCliente())).append(',')
                .append(escape(interaccion.getProductoNombre())).append(',')
                .append(interaccion.getTipo()).append(',')
                .append(escape(interaccion.getJefeResponsable() != null ? interaccion.getJefeResponsable().getNombre() : "")).append(',')
                .append(interaccion.getEstadoSeguimiento()).append(',')
                .append(escape(interaccion.getMensajeCliente()))
                .append("\\n"));
        return csvResponse("solicitudes.csv", csv.toString());
    }

    private ResponseEntity<byte[]> csvResponse(String filename, String body) {
        return ResponseEntity.ok()
                .header(HttpHeaders.CONTENT_DISPOSITION, "attachment; filename=" + filename)
                .contentType(new MediaType("text", "csv", StandardCharsets.UTF_8))
                .body(body.getBytes(StandardCharsets.UTF_8));
    }

    private String escape(String value) {
        String sanitized = value == null ? "" : value.replace("\"", "\"\"");
        return "\"" + sanitized + "\"";
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
    <div class="dashboard-hero shadow-sm mb-4">
        <div>
            <div class="eyebrow">SIMA</div>
            <h1 class="mb-2">Panel operativo</h1>
            <p class="mb-0">Seguimiento de campañas, envíos, respuestas y solicitudes de clientes.</p>
        </div>
        <div class="text-end" th:if="${currentUser != null}">
            <div class="fw-semibold fs-5" th:text="${currentUser.username()}"></div>
            <small th:text="${#strings.listJoin(currentUser.roles(), ', ')}"></small>
        </div>
    </div>

    <div class="row g-3 mb-4">
        <div class="col-md-3">
            <div class="metric-card shadow-sm">
                <span>Clientes</span>
                <strong th:text="${metrics.totalClientes()}">0</strong>
                <small>Clientes activos registrados</small>
            </div>
        </div>
        <div class="col-md-3">
            <div class="metric-card shadow-sm">
                <span>Anuncios</span>
                <strong th:text="${metrics.totalAnuncios()}">0</strong>
                <small>Catalogo disponible para campañas</small>
            </div>
        </div>
        <div class="col-md-3">
            <div class="metric-card shadow-sm">
                <span>Campañas</span>
                <strong th:text="${metrics.totalCampanas()}">0</strong>
                <small th:text="${metrics.campanasProgramadas()} + ' programadas / ' + ${metrics.campanasEjecutadas()} + ' ejecutadas'">0</small>
            </div>
        </div>
        <div class="col-md-3">
            <div class="metric-card shadow-sm">
                <span>Interacciones</span>
                <strong th:text="${metrics.totalInteracciones()}">0</strong>
                <small th:text="${metrics.solicitudesContacto()} + ' contacto / ' + ${metrics.solicitudesMasInfo()} + ' mas info'">0</small>
            </div>
        </div>
    </div>

    <div class="row g-4 mb-4">
        <div class="col-lg-8">
            <div class="card shadow-sm h-100">
                <div class="card-body">
                    <div class="d-flex justify-content-between align-items-center mb-3">
                        <h5 class="mb-0">Actividad reciente de campañas</h5>
                        <a th:if="${canManageCampaigns}" href="/envio/lista" class="btn btn-sm btn-outline-primary">Ver todas</a>
                    </div>
                    <div class="table-responsive">
                        <table class="table table-striped align-middle mb-0">
                            <thead class="table-light">
                            <tr>
                                <th>Campaña</th>
                                <th>Estado</th>
                                <th>Resultado</th>
                                <th>Programada</th>
                            </tr>
                            </thead>
                            <tbody>
                            <tr th:each="campana : ${metrics.recentCampaigns()}">
                                <td>
                                    <div th:text="${campana.nombre}"></div>
                                    <small class="text-muted" th:text="${campana.anuncio != null ? campana.anuncio.titulo : 'Sin anuncio'}"></small>
                                </td>
                                <td th:text="${campana.estado}"></td>
                                <td th:text="${campana.enviosExitosos + ' enviados / ' + campana.enviosError + ' error'}"></td>
                                <td th:text="${campana.programadaPara != null ? #temporals.format(campana.programadaPara, 'yyyy-MM-dd HH:mm') : 'Sin programar'}"></td>
                            </tr>
                            <tr th:if="${#lists.isEmpty(metrics.recentCampaigns())}">
                                <td colspan="4" class="text-center text-muted py-4">Aun no hay campañas registradas.</td>
                            </tr>
                            </tbody>
                        </table>
                    </div>
                </div>
            </div>
        </div>

        <div class="col-lg-4">
            <div class="card shadow-sm h-100">
                <div class="card-body">
                    <h5 class="mb-3">Resumen de entrega</h5>
                    <div class="summary-pill success mb-3">
                        <span>Enviados</span>
                        <strong th:text="${metrics.totalEnviosExitosos()}">0</strong>
                    </div>
                    <div class="summary-pill danger mb-3">
                        <span>Errores</span>
                        <strong th:text="${metrics.totalEnviosError()}">0</strong>
                    </div>
                    <div class="summary-pill neutral">
                        <span>Solicitudes</span>
                        <strong th:text="${metrics.totalInteracciones()}">0</strong>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <div class="row g-4 mb-4">
        <div class="col-md-3">
            <div class="card shadow-sm h-100">
                <div class="card-body">
                    <h5 class="card-title">Clientes</h5>
                    <p class="text-muted small">Alta y consulta de clientes, sucursal y responsable.</p>
                    <a href="/clientes/lista" class="btn btn-primary w-100 mb-2">Ver Clientes</a>
                    <a th:if="${canManageClients}" href="/clientes/nuevo" class="btn btn-primary w-100">Agregar Cliente</a>
                </div>
            </div>
        </div>

        <div class="col-md-3">
            <div class="card shadow-sm h-100">
                <div class="card-body">
                    <h5 class="card-title">Anuncios</h5>
                    <p class="text-muted small">Catalogo de promociones, imagen publica y contenido adicional.</p>
                    <a href="/anuncios/lista" class="btn btn-primary w-100 mb-2">Ver Anuncios</a>
                    <a th:if="${canManageAds}" href="/anuncios/nuevo" class="btn btn-primary w-100">Crear Anuncio</a>
                </div>
            </div>
        </div>

        <div class="col-md-3">
            <div class="card shadow-sm h-100">
                <div class="card-body">
                    <h5 class="card-title">Campañas</h5>
                    <p class="text-muted small">Segmentacion por sucursal, facturacion, tamano, giro y categoria.</p>
                    <a th:if="${canManageCampaigns}" href="/envio/lista" class="btn btn-primary w-100 mb-2">Ver Campañas</a>
                    <a th:if="${canManageCampaigns}" href="/envio" class="btn btn-primary w-100">Nueva Campaña</a>
                </div>
            </div>
        </div>

        <div class="col-md-3">
            <div class="card shadow-sm h-100">
                <div class="card-body">
                    <h5 class="card-title">Solicitudes</h5>
                    <p class="text-muted small">Respuestas recibidas, seguimiento y avisos a jefes responsables.</p>
                    <a th:if="${canViewRequests}" href="/solicitudes" class="btn btn-primary w-100 mb-2">Ver Solicitudes</a>
                    <a th:if="${canViewRequests}" href="/reportes" class="btn btn-outline-primary w-100">Reportes</a>
                </div>
            </div>
        </div>
    </div>

    <div class="card shadow-sm">
        <div class="card-body">
            <div class="d-flex justify-content-between align-items-center mb-3">
                <h5 class="mb-0">Interacciones recientes</h5>
                <a th:if="${canViewRequests}" href="/solicitudes" class="btn btn-sm btn-outline-primary">Ver detalle</a>
            </div>
            <div class="table-responsive">
                <table class="table table-striped align-middle mb-0">
                    <thead class="table-light">
                    <tr>
                        <th>Fecha</th>
                        <th>Cliente</th>
                        <th>Tipo</th>
                        <th>Responsable</th>
                        <th>Detalle</th>
                    </tr>
                    </thead>
                    <tbody>
                    <tr th:each="interaccion : ${metrics.recentInteractions()}">
                        <td th:text="${#temporals.format(interaccion.fechaInteraccion, 'yyyy-MM-dd HH:mm')}"></td>
                        <td>
                            <div th:text="${interaccion.cliente != null ? interaccion.cliente.nombre : interaccion.telefonoCliente}"></div>
                            <small class="text-muted" th:text="${interaccion.productoNombre}"></small>
                        </td>
                        <td th:text="${interaccion.tipo}"></td>
                        <td th:text="${interaccion.jefeResponsable != null ? interaccion.jefeResponsable.nombre : 'Sin asignar'}"></td>
                        <td th:text="${interaccion.mensajeCliente}"></td>
                    </tr>
                    <tr th:if="${#lists.isEmpty(metrics.recentInteractions())}">
                        <td colspan="5" class="text-center text-muted py-4">Aun no hay interacciones registradas.</td>
                    </tr>
                    </tbody>
                </table>
            </div>
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
            <a href="/dashboard" class="btn btn-primary">Menu</a>
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

Write-Utf8NoBom 'D:\Descargas\sima\src\main\resources\static\css\styles.css' @'
.btn-primary{
    background-color:#1e40af;
    border-color:#1e40af;
}

.btn-primary:hover{
    background-color:#1d4ed8;
    border-color:#1d4ed8;
}

.titulo-sima{
    color:#1e3a8a;
    font-weight:700;
}

.dashboard-hero{
    background:linear-gradient(135deg, #1e3a8a 0%, #1d4ed8 50%, #60a5fa 100%);
    color:#fff;
    border-radius:24px;
    padding:2rem;
    display:flex;
    justify-content:space-between;
    align-items:flex-end;
    gap:1rem;
}

.dashboard-hero .eyebrow{
    text-transform:uppercase;
    letter-spacing:.14em;
    font-size:.8rem;
    opacity:.8;
    margin-bottom:.5rem;
}

.metric-card{
    background:#fff;
    border-radius:20px;
    padding:1.25rem;
    border:1px solid rgba(30, 64, 175, 0.08);
    display:flex;
    flex-direction:column;
    gap:.25rem;
    min-height:140px;
}

.metric-card span{
    color:#64748b;
    font-size:.9rem;
    text-transform:uppercase;
    letter-spacing:.08em;
}

.metric-card strong{
    color:#0f172a;
    font-size:2rem;
    line-height:1.1;
}

.metric-card small{
    color:#64748b;
}

.summary-pill{
    border-radius:18px;
    padding:1rem 1.1rem;
    display:flex;
    justify-content:space-between;
    align-items:center;
}

.summary-pill strong{
    font-size:1.4rem;
}

.summary-pill.success{
    background:#dcfce7;
    color:#166534;
}

.summary-pill.danger{
    background:#fee2e2;
    color:#991b1b;
}

.summary-pill.neutral{
    background:#e0f2fe;
    color:#0c4a6e;
}
'@
