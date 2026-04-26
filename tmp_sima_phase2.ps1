function Write-Utf8NoBom([string]$Path, [string]$Content) {
  $dir = Split-Path -Parent $Path
  if ($dir -and -not (Test-Path $dir)) {
    New-Item -ItemType Directory -Path $dir -Force | Out-Null
  }
  $utf8NoBom = New-Object System.Text.UTF8Encoding($false)
  [System.IO.File]::WriteAllText($Path, $Content, $utf8NoBom)
}

Write-Utf8NoBom 'D:\Descargas\sima\src\main\java\mx\ipn\sima\SimaApplication.java' @'
package mx.ipn.sima;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.scheduling.annotation.EnableAsync;
import org.springframework.scheduling.annotation.EnableScheduling;

@SpringBootApplication
@EnableAsync
@EnableScheduling
public class SimaApplication {

    public static void main(String[] args) {
        SpringApplication.run(SimaApplication.class, args);
    }
}
'@

Write-Utf8NoBom 'D:\Descargas\sima\src\main\java\mx\ipn\sima\model\EstadoCampana.java' @'
package mx.ipn.sima.model;

public enum EstadoCampana {
    BORRADOR,
    PROGRAMADA,
    EN_PROCESO,
    EJECUTADA,
    EJECUTADA_CON_ERRORES
}
'@

Write-Utf8NoBom 'D:\Descargas\sima\src\main\java\mx\ipn\sima\model\EstadoDestinatario.java' @'
package mx.ipn.sima.model;

public enum EstadoDestinatario {
    PENDIENTE,
    ENVIADO,
    ERROR
}
'@

Write-Utf8NoBom 'D:\Descargas\sima\src\main\java\mx\ipn\sima\model\CampanaEnvio.java' @'
package mx.ipn.sima.model;

import jakarta.persistence.*;

import java.math.BigDecimal;
import java.time.LocalDateTime;

@Entity
@Table(name = "campanas_envio")
public class CampanaEnvio extends AuditableEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false, length = 140)
    private String nombre;

    @ManyToOne(fetch = FetchType.EAGER)
    @JoinColumn(name = "anuncio_id", nullable = false)
    private Anuncio anuncio;

    @ManyToOne(fetch = FetchType.EAGER)
    @JoinColumn(name = "creado_por_empleado_id")
    private Empleado creadoPor;

    @ManyToOne(fetch = FetchType.EAGER)
    @JoinColumn(name = "sucursal_id")
    private Sucursal sucursal;

    @Column(name = "facturacion_min", precision = 14, scale = 2)
    private BigDecimal facturacionMin;

    @Column(name = "facturacion_max", precision = 14, scale = 2)
    private BigDecimal facturacionMax;

    @Enumerated(EnumType.STRING)
    @Column(name = "tamano_empresa", length = 20)
    private TamanoEmpresa tamanoEmpresa;

    @Column(name = "categoria_producto", length = 120)
    private String categoriaProducto;

    @Column(length = 120)
    private String giro;

    @Column(name = "programada_para")
    private LocalDateTime programadaPara;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false, length = 30)
    private EstadoCampana estado = EstadoCampana.BORRADOR;

    @Column(name = "enviar_ahora", nullable = false)
    private Boolean enviarAhora = Boolean.FALSE;

    @Column(name = "total_destinatarios", nullable = false)
    private Integer totalDestinatarios = 0;

    @Column(name = "envios_exitosos", nullable = false)
    private Integer enviosExitosos = 0;

    @Column(name = "envios_error", nullable = false)
    private Integer enviosError = 0;

    @Column(name = "ultimo_envio_at")
    private LocalDateTime ultimoEnvioAt;

    public Long getId() { return id; }
    public String getNombre() { return nombre; }
    public void setNombre(String nombre) { this.nombre = nombre; }
    public Anuncio getAnuncio() { return anuncio; }
    public void setAnuncio(Anuncio anuncio) { this.anuncio = anuncio; }
    public Empleado getCreadoPor() { return creadoPor; }
    public void setCreadoPor(Empleado creadoPor) { this.creadoPor = creadoPor; }
    public Sucursal getSucursal() { return sucursal; }
    public void setSucursal(Sucursal sucursal) { this.sucursal = sucursal; }
    public BigDecimal getFacturacionMin() { return facturacionMin; }
    public void setFacturacionMin(BigDecimal facturacionMin) { this.facturacionMin = facturacionMin; }
    public BigDecimal getFacturacionMax() { return facturacionMax; }
    public void setFacturacionMax(BigDecimal facturacionMax) { this.facturacionMax = facturacionMax; }
    public TamanoEmpresa getTamanoEmpresa() { return tamanoEmpresa; }
    public void setTamanoEmpresa(TamanoEmpresa tamanoEmpresa) { this.tamanoEmpresa = tamanoEmpresa; }
    public String getCategoriaProducto() { return categoriaProducto; }
    public void setCategoriaProducto(String categoriaProducto) { this.categoriaProducto = categoriaProducto; }
    public String getGiro() { return giro; }
    public void setGiro(String giro) { this.giro = giro; }
    public LocalDateTime getProgramadaPara() { return programadaPara; }
    public void setProgramadaPara(LocalDateTime programadaPara) { this.programadaPara = programadaPara; }
    public EstadoCampana getEstado() { return estado; }
    public void setEstado(EstadoCampana estado) { this.estado = estado; }
    public Boolean getEnviarAhora() { return enviarAhora; }
    public void setEnviarAhora(Boolean enviarAhora) { this.enviarAhora = enviarAhora; }
    public Integer getTotalDestinatarios() { return totalDestinatarios; }
    public void setTotalDestinatarios(Integer totalDestinatarios) { this.totalDestinatarios = totalDestinatarios; }
    public Integer getEnviosExitosos() { return enviosExitosos; }
    public void setEnviosExitosos(Integer enviosExitosos) { this.enviosExitosos = enviosExitosos; }
    public Integer getEnviosError() { return enviosError; }
    public void setEnviosError(Integer enviosError) { this.enviosError = enviosError; }
    public LocalDateTime getUltimoEnvioAt() { return ultimoEnvioAt; }
    public void setUltimoEnvioAt(LocalDateTime ultimoEnvioAt) { this.ultimoEnvioAt = ultimoEnvioAt; }
}
'@

Write-Utf8NoBom 'D:\Descargas\sima\src\main\java\mx\ipn\sima\model\CampanaDestinatario.java' @'
package mx.ipn.sima.model;

import jakarta.persistence.*;

import java.time.LocalDateTime;

@Entity
@Table(name = "campana_destinatarios")
public class CampanaDestinatario extends AuditableEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "campana_id", nullable = false)
    private CampanaEnvio campana;

    @ManyToOne(fetch = FetchType.EAGER)
    @JoinColumn(name = "cliente_id", nullable = false)
    private Cliente cliente;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false, length = 20)
    private EstadoDestinatario estado = EstadoDestinatario.PENDIENTE;

    @Column(name = "fecha_intento")
    private LocalDateTime fechaIntento;

    @Column(name = "detalle_error", length = 500)
    private String detalleError;

    public Long getId() { return id; }
    public CampanaEnvio getCampana() { return campana; }
    public void setCampana(CampanaEnvio campana) { this.campana = campana; }
    public Cliente getCliente() { return cliente; }
    public void setCliente(Cliente cliente) { this.cliente = cliente; }
    public EstadoDestinatario getEstado() { return estado; }
    public void setEstado(EstadoDestinatario estado) { this.estado = estado; }
    public LocalDateTime getFechaIntento() { return fechaIntento; }
    public void setFechaIntento(LocalDateTime fechaIntento) { this.fechaIntento = fechaIntento; }
    public String getDetalleError() { return detalleError; }
    public void setDetalleError(String detalleError) { this.detalleError = detalleError; }
}
'@

Write-Utf8NoBom 'D:\Descargas\sima\src\main\java\mx\ipn\sima\repository\CampanaEnvioRepository.java' @'
package mx.ipn.sima.repository;

import mx.ipn.sima.model.CampanaEnvio;
import mx.ipn.sima.model.EstadoCampana;
import org.springframework.data.jpa.repository.JpaRepository;

import java.time.LocalDateTime;
import java.util.List;

public interface CampanaEnvioRepository extends JpaRepository<CampanaEnvio, Long> {
    List<CampanaEnvio> findAllByActiveTrueOrderByCreatedAtDesc();
    List<CampanaEnvio> findAllByActiveTrueAndEstadoAndProgramadaParaLessThanEqual(EstadoCampana estado, LocalDateTime dateTime);
}
'@

Write-Utf8NoBom 'D:\Descargas\sima\src\main\java\mx\ipn\sima\repository\CampanaDestinatarioRepository.java' @'
package mx.ipn.sima.repository;

import mx.ipn.sima.model.CampanaDestinatario;
import mx.ipn.sima.model.CampanaEnvio;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface CampanaDestinatarioRepository extends JpaRepository<CampanaDestinatario, Long> {
    List<CampanaDestinatario> findAllByCampanaOrderByClienteNombreAsc(CampanaEnvio campana);
    void deleteAllByCampana(CampanaEnvio campana);
}
'@

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
        throw new ResponseStatusException(HttpStatus.UNAUTHORIZED, "Sesion no valida");
    }

    public boolean canManageClients(AuthenticatedUser user) {
        return isGerente(user) || isJefeSucursal(user);
    }

    public boolean canManageCampaigns(AuthenticatedUser user) {
        return isGerente(user);
    }

    public boolean canManageAds(AuthenticatedUser user) {
        return isGerente(user);
    }

    public boolean isGerente(AuthenticatedUser user) {
        return hasAnyToken(user.roles(), "GERENTE", "ADMIN");
    }

    public boolean isJefeSucursal(AuthenticatedUser user) {
        return hasAnyToken(user.roles(), "JEFE", "SUCURSAL");
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
            throw forbidden("Solo un gerente puede gestionar campanas y envios");
        }
    }

    public void requireAdsManagement(HttpSession session) {
        AuthenticatedUser user = getCurrentUser(session);
        if (!canManageAds(user)) {
            throw forbidden("Solo un gerente puede gestionar anuncios");
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

Write-Utf8NoBom 'D:\Descargas\sima\src\main\java\mx\ipn\sima\controller\CurrentUserViewAdvice.java' @'
package mx.ipn.sima.controller;

import jakarta.servlet.http.HttpSession;
import mx.ipn.sima.dto.AuthenticatedUser;
import mx.ipn.sima.service.RoleAccessService;
import org.springframework.web.bind.annotation.ControllerAdvice;
import org.springframework.web.bind.annotation.ModelAttribute;

@ControllerAdvice
public class CurrentUserViewAdvice {

    private final RoleAccessService roleAccessService;

    public CurrentUserViewAdvice(RoleAccessService roleAccessService) {
        this.roleAccessService = roleAccessService;
    }

    @ModelAttribute("currentUser")
    public AuthenticatedUser currentUser(HttpSession session) {
        Object value = session != null ? session.getAttribute("AUTHENTICATED_USER") : null;
        return value instanceof AuthenticatedUser user ? user : null;
    }

    @ModelAttribute("canManageClients")
    public boolean canManageClients(HttpSession session) {
        AuthenticatedUser user = currentUser(session);
        return user != null && roleAccessService.canManageClients(user);
    }

    @ModelAttribute("canManageAds")
    public boolean canManageAds(HttpSession session) {
        AuthenticatedUser user = currentUser(session);
        return user != null && roleAccessService.canManageAds(user);
    }

    @ModelAttribute("canManageCampaigns")
    public boolean canManageCampaigns(HttpSession session) {
        AuthenticatedUser user = currentUser(session);
        return user != null && roleAccessService.canManageCampaigns(user);
    }
}
'@

Write-Utf8NoBom 'D:\Descargas\sima\src\main\java\mx\ipn\sima\service\CampanaService.java' @'
package mx.ipn.sima.service;

import mx.ipn.sima.model.*;
import mx.ipn.sima.repository.CampanaDestinatarioRepository;
import mx.ipn.sima.repository.CampanaEnvioRepository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;
import java.util.Locale;
import java.util.Objects;

@Service
public class CampanaService {

    private final CampanaEnvioRepository campanaEnvioRepository;
    private final CampanaDestinatarioRepository campanaDestinatarioRepository;
    private final AlmacenService almacenService;
    private final WhatsappService whatsappService;
    private final WhatsappConversationContextService conversationContextService;

    public CampanaService(CampanaEnvioRepository campanaEnvioRepository,
                          CampanaDestinatarioRepository campanaDestinatarioRepository,
                          AlmacenService almacenService,
                          WhatsappService whatsappService,
                          WhatsappConversationContextService conversationContextService) {
        this.campanaEnvioRepository = campanaEnvioRepository;
        this.campanaDestinatarioRepository = campanaDestinatarioRepository;
        this.almacenService = almacenService;
        this.whatsappService = whatsappService;
        this.conversationContextService = conversationContextService;
    }

    @Transactional
    public CampanaEnvio crearCampana(CampanaEnvio campana) {
        campana.setAnuncio(almacenService.getAnuncio(campana.getAnuncio().getId()));
        campana.setCreadoPor(campana.getCreadoPor() != null && campana.getCreadoPor().getId() != null
                ? almacenService.getEmpleado(campana.getCreadoPor().getId())
                : null);
        campana.setSucursal(campana.getSucursal() != null && campana.getSucursal().getId() != null
                ? almacenService.getSucursal(campana.getSucursal().getId())
                : null);
        normalizeFilters(campana);

        if (Boolean.TRUE.equals(campana.getEnviarAhora())) {
            campana.setEstado(EstadoCampana.EN_PROCESO);
            campana.setProgramadaPara(LocalDateTime.now());
        } else if (campana.getProgramadaPara() != null) {
            campana.setEstado(EstadoCampana.PROGRAMADA);
        } else {
            campana.setEstado(EstadoCampana.BORRADOR);
        }

        CampanaEnvio saved = campanaEnvioRepository.save(campana);
        recalculateRecipients(saved);
        if (Boolean.TRUE.equals(saved.getEnviarAhora())) {
            executeCampaign(saved.getId());
            return campanaEnvioRepository.findById(saved.getId()).orElse(saved);
        }
        return saved;
    }

    @Transactional
    public void executeCampaign(Long campanaId) {
        CampanaEnvio campana = getCampana(campanaId);
        List<CampanaDestinatario> destinatarios = campanaDestinatarioRepository.findAllByCampanaOrderByClienteNombreAsc(campana);
        if (destinatarios.isEmpty()) {
            recalculateRecipients(campana);
            destinatarios = campanaDestinatarioRepository.findAllByCampanaOrderByClienteNombreAsc(campana);
        }

        campana.setEstado(EstadoCampana.EN_PROCESO);
        campanaEnvioRepository.save(campana);

        int enviados = 0;
        int errores = 0;
        for (CampanaDestinatario destinatario : destinatarios) {
            Cliente cliente = destinatario.getCliente();
            Anuncio anuncio = campana.getAnuncio();
            boolean ok = whatsappService.sendTemplateWithImage(
                    cliente.getTelefono(),
                    anuncio.getImagen(),
                    List.of(anuncio.getTexto())
            );

            destinatario.setFechaIntento(LocalDateTime.now());
            if (ok) {
                destinatario.setEstado(EstadoDestinatario.ENVIADO);
                destinatario.setDetalleError(null);
                enviados++;
                conversationContextService.registerLastSentProduct(cliente.getTelefono(), anuncio.getTitulo());
            } else {
                destinatario.setEstado(EstadoDestinatario.ERROR);
                destinatario.setDetalleError("Meta no acepto el envio o no fue posible enviarlo.");
                errores++;
            }
        }

        campana.setEnviarAhora(Boolean.FALSE);
        campana.setUltimoEnvioAt(LocalDateTime.now());
        campana.setEnviosExitosos(enviados);
        campana.setEnviosError(errores);
        campana.setEstado(errores > 0 ? EstadoCampana.EJECUTADA_CON_ERRORES : EstadoCampana.EJECUTADA);
        campanaEnvioRepository.save(campana);
    }

    @Transactional
    public int recalculateRecipients(Long campanaId) {
        CampanaEnvio campana = getCampana(campanaId);
        return recalculateRecipients(campana);
    }

    @Transactional
    public int recalculateRecipients(CampanaEnvio campana) {
        List<Cliente> clientes = almacenService.getClientes();
        List<Cliente> seleccionados = clientes.stream()
                .filter(cliente -> matches(campana, cliente))
                .toList();

        campanaDestinatarioRepository.deleteAllByCampana(campana);

        List<CampanaDestinatario> nuevos = new ArrayList<>();
        for (Cliente cliente : seleccionados) {
            CampanaDestinatario destinatario = new CampanaDestinatario();
            destinatario.setCampana(campana);
            destinatario.setCliente(cliente);
            nuevos.add(destinatario);
        }
        campanaDestinatarioRepository.saveAll(nuevos);

        campana.setTotalDestinatarios(seleccionados.size());
        campana.setEnviosExitosos(0);
        campana.setEnviosError(0);
        campanaEnvioRepository.save(campana);
        return seleccionados.size();
    }

    @Transactional(readOnly = true)
    public List<CampanaEnvio> getCampanas() {
        return campanaEnvioRepository.findAllByActiveTrueOrderByCreatedAtDesc();
    }

    @Transactional(readOnly = true)
    public CampanaEnvio getCampana(Long id) {
        return campanaEnvioRepository.findById(id)
                .orElseThrow(() -> new IllegalArgumentException("Campana no encontrada"));
    }

    @Transactional(readOnly = true)
    public List<CampanaDestinatario> getDestinatarios(Long campanaId) {
        return campanaDestinatarioRepository.findAllByCampanaOrderByClienteNombreAsc(getCampana(campanaId));
    }

    @Transactional(readOnly = true)
    public List<CampanaEnvio> getDueCampaigns() {
        return campanaEnvioRepository.findAllByActiveTrueAndEstadoAndProgramadaParaLessThanEqual(
                EstadoCampana.PROGRAMADA,
                LocalDateTime.now()
        );
    }

    private boolean matches(CampanaEnvio campana, Cliente cliente) {
        if (campana.getSucursal() != null) {
            Long campanaSucursalId = campana.getSucursal().getId();
            Long clienteSucursalId = cliente.getSucursal() != null ? cliente.getSucursal().getId() : null;
            if (!Objects.equals(campanaSucursalId, clienteSucursalId)) {
                return false;
            }
        }

        BigDecimal facturacion = cliente.getFacturacionMensual() != null ? cliente.getFacturacionMensual() : BigDecimal.ZERO;
        if (campana.getFacturacionMin() != null && facturacion.compareTo(campana.getFacturacionMin()) < 0) {
            return false;
        }
        if (campana.getFacturacionMax() != null && facturacion.compareTo(campana.getFacturacionMax()) > 0) {
            return false;
        }

        if (campana.getTamanoEmpresa() != null && campana.getTamanoEmpresa() != cliente.getTamanoEmpresa()) {
            return false;
        }

        if (hasText(campana.getCategoriaProducto()) && !containsIgnoreCase(cliente.getCategoriaProducto(), campana.getCategoriaProducto())) {
            return false;
        }

        if (hasText(campana.getGiro()) && !containsIgnoreCase(cliente.getGiro(), campana.getGiro())) {
            return false;
        }

        return true;
    }

    private void normalizeFilters(CampanaEnvio campana) {
        if (campana.getCategoriaProducto() != null) {
            campana.setCategoriaProducto(blankToNull(campana.getCategoriaProducto()));
        }
        if (campana.getGiro() != null) {
            campana.setGiro(blankToNull(campana.getGiro()));
        }
        if (campana.getFacturacionMin() != null && campana.getFacturacionMax() != null
                && campana.getFacturacionMin().compareTo(campana.getFacturacionMax()) > 0) {
            BigDecimal tmp = campana.getFacturacionMin();
            campana.setFacturacionMin(campana.getFacturacionMax());
            campana.setFacturacionMax(tmp);
        }
    }

    private boolean hasText(String value) {
        return value != null && !value.isBlank();
    }

    private String blankToNull(String value) {
        String trimmed = value != null ? value.trim() : null;
        return trimmed == null || trimmed.isBlank() ? null : trimmed;
    }

    private boolean containsIgnoreCase(String source, String token) {
        return source != null && source.toLowerCase(Locale.ROOT).contains(token.toLowerCase(Locale.ROOT));
    }
}
'@

Write-Utf8NoBom 'D:\Descargas\sima\src\main\java\mx\ipn\sima\service\CampanaSchedulerService.java' @'
package mx.ipn.sima.service;

import mx.ipn.sima.model.CampanaEnvio;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Service;

@Service
public class CampanaSchedulerService {

    private final CampanaService campanaService;

    public CampanaSchedulerService(CampanaService campanaService) {
        this.campanaService = campanaService;
    }

    @Scheduled(fixedDelay = 60000)
    public void executeDueCampaigns() {
        for (CampanaEnvio campana : campanaService.getDueCampaigns()) {
            campanaService.executeCampaign(campana.getId());
        }
    }
}
'@

Write-Utf8NoBom 'D:\Descargas\sima\src\main\java\mx\ipn\sima\service\AlmacenService.java' @'
package mx.ipn.sima.service;

import jakarta.annotation.PostConstruct;
import mx.ipn.sima.model.*;
import mx.ipn.sima.repository.AnuncioRepository;
import mx.ipn.sima.repository.ClienteRepository;
import mx.ipn.sima.repository.EmpleadoRepository;
import mx.ipn.sima.repository.SucursalRepository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.List;

@Service
public class AlmacenService {

    private final ClienteRepository clienteRepository;
    private final AnuncioRepository anuncioRepository;
    private final SucursalRepository sucursalRepository;
    private final EmpleadoRepository empleadoRepository;

    public AlmacenService(ClienteRepository clienteRepository,
                          AnuncioRepository anuncioRepository,
                          SucursalRepository sucursalRepository,
                          EmpleadoRepository empleadoRepository) {
        this.clienteRepository = clienteRepository;
        this.anuncioRepository = anuncioRepository;
        this.sucursalRepository = sucursalRepository;
        this.empleadoRepository = empleadoRepository;
    }

    @PostConstruct
    @Transactional
    public void initData() {
        if (sucursalRepository.count() == 0) {
            Sucursal matriz = new Sucursal();
            matriz.setClave("MAT");
            matriz.setNombre("Matriz");
            matriz.setTelefono("6440000000");
            matriz.setCorreo("matriz@sima.local");
            sucursalRepository.save(matriz);

            Empleado gerente = new Empleado();
            gerente.setNombre("Gerente General");
            gerente.setCorreo("gerencia@sima.local");
            gerente.setTelefono("6441111111");
            gerente.setPuesto("Gerente de anuncios");
            gerente.setRolOperativo(RolOperativo.GERENTE);
            gerente.setSucursal(matriz);
            empleadoRepository.save(gerente);

            Empleado jefe = new Empleado();
            jefe.setNombre("Jefe de Sucursal Matriz");
            jefe.setCorreo("jefe.matriz@sima.local");
            jefe.setTelefono("6442222222");
            jefe.setPuesto("Jefe de sucursal");
            jefe.setRolOperativo(RolOperativo.JEFE_SUCURSAL);
            jefe.setSucursal(matriz);
            empleadoRepository.save(jefe);
        }

        if (anuncioRepository.count() == 0) {
            Empleado gerente = getGerentes().stream().findFirst().orElse(null);
            if (gerente != null) {
                Anuncio anuncio = new Anuncio();
                anuncio.setTitulo("Promocion de bienvenida");
                anuncio.setTexto("Conoce nuestros productos destacados de la temporada.");
                anuncio.setImagen("https://example.com/promocion.jpg");
                anuncio.setFechaPublicacion(LocalDate.now());
                anuncio.setInformacionExtraTipo(InformacionExtraTipo.URL);
                anuncio.setInformacionExtraValor("https://example.com/detalle-promocion");
                anuncio.setCreadoPor(gerente);
                anuncioRepository.save(anuncio);
            }
        }
    }

    @Transactional
    public void guardarCliente(Cliente cliente) {
        if (cliente.getFacturacionMensual() == null) {
            cliente.setFacturacionMensual(BigDecimal.ZERO);
        }
        cliente.setSucursal(resolveSucursal(cliente.getSucursal()));
        cliente.setJefeSucursal(resolveEmpleado(cliente.getJefeSucursal()));
        clienteRepository.save(cliente);
    }

    @Transactional
    public void guardarAnuncio(Anuncio anuncio) {
        if (anuncio.getFechaPublicacion() == null) {
            anuncio.setFechaPublicacion(LocalDate.now());
        }
        if (anuncio.getInformacionExtraTipo() == null) {
            anuncio.setInformacionExtraTipo(InformacionExtraTipo.TEXTO);
        }
        anuncio.setCreadoPor(resolveEmpleado(anuncio.getCreadoPor()));
        anuncioRepository.save(anuncio);
    }

    @Transactional(readOnly = true)
    public List<Cliente> getClientes() {
        return clienteRepository.findAllByActiveTrueOrderByNombreAsc();
    }

    @Transactional(readOnly = true)
    public List<Anuncio> getAnuncios() {
        return anuncioRepository.findAllByActiveTrueOrderByFechaPublicacionDescIdDesc();
    }

    @Transactional(readOnly = true)
    public Cliente getCliente(Long id) {
        return clienteRepository.findById(id).orElseThrow(() -> new IllegalArgumentException("Cliente no encontrado"));
    }

    @Transactional(readOnly = true)
    public Anuncio getAnuncio(Long id) {
        return anuncioRepository.findById(id).orElseThrow(() -> new IllegalArgumentException("Anuncio no encontrado"));
    }

    @Transactional(readOnly = true)
    public Sucursal getSucursal(Long id) {
        return sucursalRepository.findById(id).orElseThrow(() -> new IllegalArgumentException("Sucursal no encontrada"));
    }

    @Transactional(readOnly = true)
    public Empleado getEmpleado(Long id) {
        return empleadoRepository.findById(id).orElseThrow(() -> new IllegalArgumentException("Empleado no encontrado"));
    }

    @Transactional(readOnly = true)
    public List<Sucursal> getSucursales() {
        return sucursalRepository.findAllByActiveTrueOrderByNombreAsc();
    }

    @Transactional(readOnly = true)
    public List<Empleado> getJefesSucursal() {
        return empleadoRepository.findAllByActiveTrueAndRolOperativoOrderByNombreAsc(RolOperativo.JEFE_SUCURSAL);
    }

    @Transactional(readOnly = true)
    public List<Empleado> getGerentes() {
        return empleadoRepository.findAllByActiveTrueAndRolOperativoOrderByNombreAsc(RolOperativo.GERENTE);
    }

    private Sucursal resolveSucursal(Sucursal sucursal) {
        if (sucursal == null || sucursal.getId() == null) {
            return null;
        }
        return sucursalRepository.findById(sucursal.getId())
                .orElseThrow(() -> new IllegalArgumentException("Sucursal no encontrada"));
    }

    private Empleado resolveEmpleado(Empleado empleado) {
        if (empleado == null || empleado.getId() == null) {
            return null;
        }
        return empleadoRepository.findById(empleado.getId())
                .orElseThrow(() -> new IllegalArgumentException("Empleado no encontrado"));
    }
}
'@

Write-Utf8NoBom 'D:\Descargas\sima\src\main\java\mx\ipn\sima\controller\ClienteController.java' @'
package mx.ipn.sima.controller;

import jakarta.servlet.http.HttpSession;
import mx.ipn.sima.model.Cliente;
import mx.ipn.sima.model.Empleado;
import mx.ipn.sima.model.Sucursal;
import mx.ipn.sima.model.TamanoEmpresa;
import mx.ipn.sima.service.AlmacenService;
import mx.ipn.sima.service.RoleAccessService;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.ModelAttribute;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;

@Controller
@RequestMapping("/clientes")
public class ClienteController {

    private final AlmacenService almacenService;
    private final RoleAccessService roleAccessService;

    public ClienteController(AlmacenService almacenService, RoleAccessService roleAccessService) {
        this.almacenService = almacenService;
        this.roleAccessService = roleAccessService;
    }

    @GetMapping("/nuevo")
    public String mostrarFormulario(Model model, HttpSession session) {
        roleAccessService.requireClientManagement(session);
        Cliente cliente = new Cliente();
        cliente.setSucursal(new Sucursal());
        cliente.setJefeSucursal(new Empleado());
        model.addAttribute("cliente", cliente);
        model.addAttribute("sucursales", almacenService.getSucursales());
        model.addAttribute("jefesSucursal", almacenService.getJefesSucursal());
        model.addAttribute("tamanos", TamanoEmpresa.values());
        return "cliente-form";
    }

    @GetMapping("/lista")
    public String listarClientes(Model model) {
        model.addAttribute("clientes", almacenService.getClientes());
        return "cliente-lista";
    }

    @PostMapping("/guardar")
    public String guardarCliente(@ModelAttribute Cliente cliente, HttpSession session) {
        roleAccessService.requireClientManagement(session);
        almacenService.guardarCliente(cliente);
        return "redirect:/clientes/lista";
    }
}
'@

Write-Utf8NoBom 'D:\Descargas\sima\src\main\java\mx\ipn\sima\controller\AnuncioController.java' @'
package mx.ipn.sima.controller;

import jakarta.servlet.http.HttpSession;
import mx.ipn.sima.model.Anuncio;
import mx.ipn.sima.model.Empleado;
import mx.ipn.sima.model.InformacionExtraTipo;
import mx.ipn.sima.service.AlmacenService;
import mx.ipn.sima.service.RoleAccessService;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.ModelAttribute;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;

@Controller
@RequestMapping("/anuncios")
public class AnuncioController {

    private final AlmacenService almacenService;
    private final RoleAccessService roleAccessService;

    public AnuncioController(AlmacenService almacenService, RoleAccessService roleAccessService) {
        this.almacenService = almacenService;
        this.roleAccessService = roleAccessService;
    }

    @GetMapping("/nuevo")
    public String mostrarFormulario(Model model, HttpSession session) {
        roleAccessService.requireAdsManagement(session);
        Anuncio anuncio = new Anuncio();
        anuncio.setCreadoPor(new Empleado());
        model.addAttribute("anuncio", anuncio);
        model.addAttribute("gerentes", almacenService.getGerentes());
        model.addAttribute("tiposExtra", InformacionExtraTipo.values());
        return "anuncio-form";
    }

    @PostMapping("/guardar")
    public String guardarAnuncio(@ModelAttribute Anuncio anuncio, HttpSession session) {
        roleAccessService.requireAdsManagement(session);
        almacenService.guardarAnuncio(anuncio);
        return "redirect:/anuncios/lista";
    }

    @GetMapping("/lista")
    public String listarAnuncios(Model model) {
        model.addAttribute("anuncios", almacenService.getAnuncios());
        return "anuncio-lista";
    }
}
'@

Write-Utf8NoBom 'D:\Descargas\sima\src\main\java\mx\ipn\sima\controller\EnvioController.java' @'
package mx.ipn.sima.controller;

import jakarta.servlet.http.HttpSession;
import mx.ipn.sima.model.*;
import mx.ipn.sima.service.AlmacenService;
import mx.ipn.sima.service.CampanaService;
import mx.ipn.sima.service.RoleAccessService;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;

@Controller
@RequestMapping("/envio")
public class EnvioController {

    private final AlmacenService almacenService;
    private final CampanaService campanaService;
    private final RoleAccessService roleAccessService;

    public EnvioController(AlmacenService almacenService,
                           CampanaService campanaService,
                           RoleAccessService roleAccessService) {
        this.almacenService = almacenService;
        this.campanaService = campanaService;
        this.roleAccessService = roleAccessService;
    }

    @GetMapping
    public String mostrarPantalla(Model model, HttpSession session) {
        roleAccessService.requireCampaignManagement(session);
        CampanaEnvio campana = new CampanaEnvio();
        campana.setAnuncio(new Anuncio());
        campana.setCreadoPor(new Empleado());
        campana.setSucursal(new Sucursal());
        model.addAttribute("campana", campana);
        model.addAttribute("anuncios", almacenService.getAnuncios());
        model.addAttribute("gerentes", almacenService.getGerentes());
        model.addAttribute("sucursales", almacenService.getSucursales());
        model.addAttribute("tamanos", TamanoEmpresa.values());
        return "envio-form";
    }

    @PostMapping("/guardar")
    public String guardarCampana(@ModelAttribute CampanaEnvio campana, HttpSession session) {
        roleAccessService.requireCampaignManagement(session);
        CampanaEnvio saved = campanaService.crearCampana(campana);
        return "redirect:/envio/resultado/" + saved.getId();
    }

    @GetMapping("/lista")
    public String listarCampanas(Model model, HttpSession session) {
        roleAccessService.requireCampaignManagement(session);
        model.addAttribute("campanas", campanaService.getCampanas());
        return "campana-lista";
    }

    @PostMapping("/ejecutar/{id}")
    public String ejecutarCampana(@PathVariable Long id, HttpSession session) {
        roleAccessService.requireCampaignManagement(session);
        campanaService.executeCampaign(id);
        return "redirect:/envio/resultado/" + id;
    }

    @GetMapping("/resultado/{id}")
    public String resultado(@PathVariable Long id, Model model, HttpSession session) {
        roleAccessService.requireCampaignManagement(session);
        CampanaEnvio campana = campanaService.getCampana(id);
        model.addAttribute("campana", campana);
        model.addAttribute("destinatarios", campanaService.getDestinatarios(id));
        model.addAttribute("resultado", buildResultMessage(campana));
        return "envio-resultado";
    }

    private String buildResultMessage(CampanaEnvio campana) {
        return switch (campana.getEstado()) {
            case PROGRAMADA -> "Campana programada correctamente.";
            case EJECUTADA -> "Campana ejecutada correctamente.";
            case EJECUTADA_CON_ERRORES -> "Campana ejecutada con incidencias. Revisa el detalle por destinatario.";
            case BORRADOR -> "Campana guardada en borrador.";
            case EN_PROCESO -> "Campana en proceso de envio.";
        };
    }
}
'@

Write-Utf8NoBom 'D:\Descargas\sima\src\main\java\mx\ipn\sima\controller\LoginController.java' @'
package mx.ipn.sima.controller;

import jakarta.servlet.http.HttpSession;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;

@Controller
public class LoginController {

    private final String loginUrl;

    public LoginController(@Value("${app.sso.login-url:http://localhost:5173}") String loginUrl) {
        this.loginUrl = loginUrl;
    }

    @GetMapping("/")
    public String login(HttpSession session) {
        return session.getAttribute("AUTHENTICATED_USER") != null
                ? "redirect:/dashboard"
                : "redirect:" + loginUrl;
    }

    @GetMapping("/dashboard")
    public String dashboard() {
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

    <div class="row g-4">
        <div class="col-md-4">
            <div class="card shadow-sm h-100">
                <div class="card-body">
                    <h5 class="card-title">Gestion de Clientes</h5>
                    <p class="text-muted small">Alta y consulta de clientes, sucursal y responsable.</p>
                    <a href="/clientes/lista" class="btn btn-primary w-100 mb-2">Ver Clientes</a>
                    <a th:if="${canManageClients}" href="/clientes/nuevo" class="btn btn-primary w-100">Agregar Cliente</a>
                </div>
            </div>
        </div>

        <div class="col-md-4">
            <div class="card shadow-sm h-100">
                <div class="card-body">
                    <h5 class="card-title">Gestion de Anuncios</h5>
                    <p class="text-muted small">Catalogo de promociones, imagen publica y contenido adicional.</p>
                    <a href="/anuncios/lista" class="btn btn-primary w-100 mb-2">Ver Anuncios</a>
                    <a th:if="${canManageAds}" href="/anuncios/nuevo" class="btn btn-primary w-100">Crear Anuncio</a>
                </div>
            </div>
        </div>

        <div class="col-md-4">
            <div class="card shadow-sm h-100">
                <div class="card-body">
                    <h5 class="card-title">Campanas y Envios</h5>
                    <p class="text-muted small">Segmentacion por sucursal, facturacion, tamano, giro y categoria.</p>
                    <a th:if="${canManageCampaigns}" href="/envio/lista" class="btn btn-primary w-100 mb-2">Ver Campanas</a>
                    <a th:if="${canManageCampaigns}" href="/envio" class="btn btn-primary w-100">Nueva Campana</a>
                    <div th:if="${!canManageCampaigns}" class="alert alert-light border mt-3 mb-0 small">
                        Solo un gerente puede crear campanas y programar envios.
                    </div>
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
            <a href="/dashboard" class="btn btn-primary">Menu</a>
            <a href="/clientes/lista" class="btn btn-primary">Lista de clientes</a>
            <a th:if="${canManageAds}" href="/anuncios/nuevo" class="btn btn-primary">Anuncios</a>
            <a th:if="${canManageCampaigns}" href="/envio/lista" class="btn btn-primary">Campanas</a>
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
                        <label class="form-label">Razon social</label>
                        <input type="text" class="form-control" th:field="*{razonSocial}">
                    </div>
                    <div class="col-md-6">
                        <label class="form-label">Correo</label>
                        <input type="email" class="form-control" th:field="*{correo}">
                    </div>
                    <div class="col-md-6">
                        <label class="form-label">Telefono</label>
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
                        <label class="form-label">Jefe de sucursal</label>
                        <select class="form-select" th:field="*{jefeSucursal.id}">
                            <option value="">Selecciona</option>
                            <option th:each="jefe : ${jefesSucursal}" th:value="${jefe.id}" th:text="${jefe.nombre}"></option>
                        </select>
                    </div>
                    <div class="col-md-4">
                        <label class="form-label">Facturacion mensual</label>
                        <input type="number" step="0.01" class="form-control" th:field="*{facturacionMensual}">
                    </div>
                    <div class="col-md-4">
                        <label class="form-label">Tamano de empresa</label>
                        <select class="form-select" th:field="*{tamanoEmpresa}">
                            <option value="">Selecciona</option>
                            <option th:each="tamano : ${tamanos}" th:value="${tamano}" th:text="${tamano}"></option>
                        </select>
                    </div>
                    <div class="col-md-4">
                        <label class="form-label">Categoria de producto</label>
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
            <a href="/dashboard" class="btn btn-primary">Menu</a>
            <a th:if="${canManageAds}" href="/anuncios/lista" class="btn btn-primary">Lista de anuncio</a>
            <a th:if="${canManageCampaigns}" href="/envio/lista" class="btn btn-primary">Campanas</a>
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
                    <th>Telefono</th>
                    <th>Facturacion</th>
                    <th>Tamano</th>
                    <th>Categoria</th>
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
            <a href="/dashboard" class="btn btn-primary">Menu</a>
            <a href="/clientes/lista" class="btn btn-primary">Lista de clientes</a>
            <a href="/anuncios/lista" class="btn btn-primary">Lista de anuncio</a>
            <a href="/envio/lista" class="btn btn-primary">Campanas</a>
        </div>
    </div>

    <h3 class="mb-4">Registrar Anuncio</h3>

    <div class="card shadow-sm">
        <div class="card-body">
            <form th:action="@{/anuncios/guardar}" th:object="${anuncio}" method="post">
                <div class="row g-3">
                    <div class="col-md-6">
                        <label class="form-label">Titulo</label>
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
                        <label class="form-label">Imagen (URL publica)</label>
                        <input type="text" class="form-control" th:field="*{imagen}" required>
                    </div>
                    <div class="col-md-6">
                        <label class="form-label">Fecha de publicacion</label>
                        <input type="date" class="form-control" th:field="*{fechaPublicacion}">
                    </div>
                    <div class="col-md-4">
                        <label class="form-label">Tipo de informacion extra</label>
                        <select class="form-select" th:field="*{informacionExtraTipo}">
                            <option value="">Selecciona</option>
                            <option th:each="tipo : ${tiposExtra}" th:value="${tipo}" th:text="${tipo}"></option>
                        </select>
                    </div>
                    <div class="col-md-8">
                        <label class="form-label">Valor de informacion extra</label>
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
            <a href="/dashboard" class="btn btn-primary">Menu</a>
            <a href="/clientes/lista" class="btn btn-primary">Lista de clientes</a>
            <a th:if="${canManageCampaigns}" href="/envio/lista" class="btn btn-primary">Campanas</a>
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
                    <th>Titulo</th>
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
    <title>Nueva Campana</title>
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
            <a href="/anuncios/lista" class="btn btn-primary">Lista de anuncio</a>
            <a href="/clientes/lista" class="btn btn-primary">Lista de clientes</a>
            <a href="/envio/lista" class="btn btn-primary">Campanas</a>
        </div>
    </div>

    <h3 class="mb-4">Nueva Campana de Envio</h3>

    <div class="card shadow-sm">
        <div class="card-body">
            <form th:action="@{/envio/guardar}" th:object="${campana}" method="post">
                <div class="row g-3">
                    <div class="col-md-6">
                        <label class="form-label">Nombre de la campana</label>
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
                        <div class="form-text">Si la dejas vacia y no eliges envio inmediato, la campana queda en borrador.</div>
                    </div>
                </div>

                <hr class="my-4">
                <h5 class="mb-3">Segmentacion</h5>
                <div class="row g-3">
                    <div class="col-md-4">
                        <label class="form-label">Sucursal</label>
                        <select class="form-select" th:field="*{sucursal.id}">
                            <option value="">Todas</option>
                            <option th:each="sucursal : ${sucursales}" th:value="${sucursal.id}" th:text="${sucursal.nombre}"></option>
                        </select>
                    </div>
                    <div class="col-md-4">
                        <label class="form-label">Facturacion minima</label>
                        <input type="number" step="0.01" class="form-control" th:field="*{facturacionMin}">
                    </div>
                    <div class="col-md-4">
                        <label class="form-label">Facturacion maxima</label>
                        <input type="number" step="0.01" class="form-control" th:field="*{facturacionMax}">
                    </div>
                    <div class="col-md-4">
                        <label class="form-label">Tamano de empresa</label>
                        <select class="form-select" th:field="*{tamanoEmpresa}">
                            <option value="">Todos</option>
                            <option th:each="tamano : ${tamanos}" th:value="${tamano}" th:text="${tamano}"></option>
                        </select>
                    </div>
                    <div class="col-md-4">
                        <label class="form-label">Categoria de producto</label>
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
                    <button type="submit" class="btn btn-primary">Guardar campana</button>
                    <a href="/envio/lista" class="btn btn-secondary">Ver campanas</a>
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
    <title>Campanas de Envio</title>
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
            <a href="/anuncios/lista" class="btn btn-primary">Anuncios</a>
            <a href="/clientes/lista" class="btn btn-primary">Clientes</a>
        </div>
    </div>

    <div class="d-flex justify-content-between align-items-center mb-3">
        <div>
            <h3 class="mb-0">Campanas de Envio</h3>
            <small class="text-muted">Programadas o listas para envio segmentado.</small>
        </div>
        <a href="/envio" class="btn btn-primary">Nueva campana</a>
    </div>

    <div class="card shadow-sm">
        <div class="card-body table-responsive">
            <table class="table table-striped align-middle mb-0">
                <thead class="table-light">
                <tr>
                    <th>Campana</th>
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
                    <td colspan="7" class="text-center text-muted py-4">Aun no hay campanas registradas.</td>
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
    <title>Resultado de la Campana</title>
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
            <a href="/envio" class="btn btn-primary">Nueva campana</a>
            <a href="/envio/lista" class="btn btn-primary">Campanas</a>
        </div>
    </div>

    <div class="card shadow-sm mb-4">
        <div class="card-body">
            <h3 class="mb-3" th:text="${resultado}"></h3>
            <div class="row g-3 small">
                <div class="col-md-3"><strong>Campana:</strong> <span th:text="${campana.nombre}"></span></div>
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
                    <th>Telefono</th>
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
                    <td colspan="5" class="text-center text-muted py-4">La campana no tiene destinatarios con los filtros actuales.</td>
                </tr>
                </tbody>
            </table>
        </div>
    </div>
</div>
</body>
</html>
'@
