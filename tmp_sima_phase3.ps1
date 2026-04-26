function Write-Utf8NoBom([string]$Path, [string]$Content) {
  $dir = Split-Path -Parent $Path
  if ($dir -and -not (Test-Path $dir)) {
    New-Item -ItemType Directory -Path $dir -Force | Out-Null
  }
  $utf8NoBom = New-Object System.Text.UTF8Encoding($false)
  [System.IO.File]::WriteAllText($Path, $Content, $utf8NoBom)
}

Write-Utf8NoBom 'D:\Descargas\sima\src\main\java\mx\ipn\sima\model\TipoInteraccionCliente.java' @'
package mx.ipn.sima.model;

public enum TipoInteraccionCliente {
    MAS_INFO,
    QUIERE_CONTACTO,
    MENSAJE_LIBRE
}
'@

Write-Utf8NoBom 'D:\Descargas\sima\src\main\java\mx\ipn\sima\model\EstadoSeguimiento.java' @'
package mx.ipn.sima.model;

public enum EstadoSeguimiento {
    PENDIENTE,
    NOTIFICADO,
    ATENDIDO
}
'@

Write-Utf8NoBom 'D:\Descargas\sima\src\main\java\mx\ipn\sima\model\WhatsappConversationContext.java' @'
package mx.ipn.sima.model;

import jakarta.persistence.*;

@Entity
@Table(name = "whatsapp_conversation_context")
public class WhatsappConversationContext extends AuditableEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "phone_number", nullable = false, unique = true, length = 30)
    private String phoneNumber;

    @ManyToOne(fetch = FetchType.EAGER)
    @JoinColumn(name = "campana_id")
    private CampanaEnvio campana;

    @ManyToOne(fetch = FetchType.EAGER)
    @JoinColumn(name = "anuncio_id")
    private Anuncio anuncio;

    @ManyToOne(fetch = FetchType.EAGER)
    @JoinColumn(name = "cliente_id")
    private Cliente cliente;

    @ManyToOne(fetch = FetchType.EAGER)
    @JoinColumn(name = "jefe_responsable_id")
    private Empleado jefeResponsable;

    @Column(name = "producto_nombre", length = 140)
    private String productoNombre;

    public Long getId() { return id; }
    public String getPhoneNumber() { return phoneNumber; }
    public void setPhoneNumber(String phoneNumber) { this.phoneNumber = phoneNumber; }
    public CampanaEnvio getCampana() { return campana; }
    public void setCampana(CampanaEnvio campana) { this.campana = campana; }
    public Anuncio getAnuncio() { return anuncio; }
    public void setAnuncio(Anuncio anuncio) { this.anuncio = anuncio; }
    public Cliente getCliente() { return cliente; }
    public void setCliente(Cliente cliente) { this.cliente = cliente; }
    public Empleado getJefeResponsable() { return jefeResponsable; }
    public void setJefeResponsable(Empleado jefeResponsable) { this.jefeResponsable = jefeResponsable; }
    public String getProductoNombre() { return productoNombre; }
    public void setProductoNombre(String productoNombre) { this.productoNombre = productoNombre; }
}
'@

Write-Utf8NoBom 'D:\Descargas\sima\src\main\java\mx\ipn\sima\model\InteraccionCliente.java' @'
package mx.ipn.sima.model;

import jakarta.persistence.*;

import java.time.LocalDateTime;

@Entity
@Table(name = "interacciones_cliente")
public class InteraccionCliente extends AuditableEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.EAGER)
    @JoinColumn(name = "cliente_id")
    private Cliente cliente;

    @ManyToOne(fetch = FetchType.EAGER)
    @JoinColumn(name = "campana_id")
    private CampanaEnvio campana;

    @ManyToOne(fetch = FetchType.EAGER)
    @JoinColumn(name = "anuncio_id")
    private Anuncio anuncio;

    @ManyToOne(fetch = FetchType.EAGER)
    @JoinColumn(name = "jefe_responsable_id")
    private Empleado jefeResponsable;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false, length = 30)
    private TipoInteraccionCliente tipo;

    @Enumerated(EnumType.STRING)
    @Column(name = "estado_seguimiento", nullable = false, length = 20)
    private EstadoSeguimiento estadoSeguimiento = EstadoSeguimiento.PENDIENTE;

    @Column(name = "telefono_cliente", nullable = false, length = 30)
    private String telefonoCliente;

    @Column(name = "producto_nombre", length = 140)
    private String productoNombre;

    @Column(name = "mensaje_cliente", length = 1000)
    private String mensajeCliente;

    @Column(name = "notificacion_interna", length = 1000)
    private String notificacionInterna;

    @Column(name = "fecha_interaccion", nullable = false)
    private LocalDateTime fechaInteraccion;

    public Long getId() { return id; }
    public Cliente getCliente() { return cliente; }
    public void setCliente(Cliente cliente) { this.cliente = cliente; }
    public CampanaEnvio getCampana() { return campana; }
    public void setCampana(CampanaEnvio campana) { this.campana = campana; }
    public Anuncio getAnuncio() { return anuncio; }
    public void setAnuncio(Anuncio anuncio) { this.anuncio = anuncio; }
    public Empleado getJefeResponsable() { return jefeResponsable; }
    public void setJefeResponsable(Empleado jefeResponsable) { this.jefeResponsable = jefeResponsable; }
    public TipoInteraccionCliente getTipo() { return tipo; }
    public void setTipo(TipoInteraccionCliente tipo) { this.tipo = tipo; }
    public EstadoSeguimiento getEstadoSeguimiento() { return estadoSeguimiento; }
    public void setEstadoSeguimiento(EstadoSeguimiento estadoSeguimiento) { this.estadoSeguimiento = estadoSeguimiento; }
    public String getTelefonoCliente() { return telefonoCliente; }
    public void setTelefonoCliente(String telefonoCliente) { this.telefonoCliente = telefonoCliente; }
    public String getProductoNombre() { return productoNombre; }
    public void setProductoNombre(String productoNombre) { this.productoNombre = productoNombre; }
    public String getMensajeCliente() { return mensajeCliente; }
    public void setMensajeCliente(String mensajeCliente) { this.mensajeCliente = mensajeCliente; }
    public String getNotificacionInterna() { return notificacionInterna; }
    public void setNotificacionInterna(String notificacionInterna) { this.notificacionInterna = notificacionInterna; }
    public LocalDateTime getFechaInteraccion() { return fechaInteraccion; }
    public void setFechaInteraccion(LocalDateTime fechaInteraccion) { this.fechaInteraccion = fechaInteraccion; }
}
'@

Write-Utf8NoBom 'D:\Descargas\sima\src\main\java\mx\ipn\sima\repository\WhatsappConversationContextRepository.java' @'
package mx.ipn.sima.repository;

import mx.ipn.sima.model.WhatsappConversationContext;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;

public interface WhatsappConversationContextRepository extends JpaRepository<WhatsappConversationContext, Long> {
    Optional<WhatsappConversationContext> findByPhoneNumber(String phoneNumber);
}
'@

Write-Utf8NoBom 'D:\Descargas\sima\src\main\java\mx\ipn\sima\repository\InteraccionClienteRepository.java' @'
package mx.ipn.sima.repository;

import mx.ipn.sima.model.Empleado;
import mx.ipn.sima.model.InteraccionCliente;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface InteraccionClienteRepository extends JpaRepository<InteraccionCliente, Long> {
    List<InteraccionCliente> findAllByActiveTrueOrderByFechaInteraccionDesc();
    List<InteraccionCliente> findAllByActiveTrueAndJefeResponsableOrderByFechaInteraccionDesc(Empleado jefeResponsable);
}
'@

Write-Utf8NoBom 'D:\Descargas\sima\src\main\java\mx\ipn\sima\repository\ClienteRepository.java' @'
package mx.ipn.sima.repository;

import mx.ipn.sima.model.Cliente;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface ClienteRepository extends JpaRepository<Cliente, Long> {
    List<Cliente> findAllByActiveTrueOrderByNombreAsc();
    List<Cliente> findAllByActiveTrue();
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
    public Cliente findClienteByTelefono(String telefono) {
        String normalized = normalizePhone(telefono);
        return clienteRepository.findAllByActiveTrue().stream()
                .filter(cliente -> normalizePhone(cliente.getTelefono()).equals(normalized))
                .findFirst()
                .orElse(null);
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
    public Empleado findEmpleadoResponsableDeCliente(Cliente cliente) {
        if (cliente == null) {
            return null;
        }
        if (cliente.getJefeSucursal() != null) {
            return cliente.getJefeSucursal();
        }
        return getJefesSucursal().stream()
                .filter(jefe -> jefe.getSucursal() != null && cliente.getSucursal() != null
                        && jefe.getSucursal().getId().equals(cliente.getSucursal().getId()))
                .findFirst()
                .orElse(null);
    }

    @Transactional(readOnly = true)
    public Empleado findEmpleadoByLoginContext(Long userId, String email) {
        return empleadoRepository.findAllByActiveTrueAndRolOperativoOrderByNombreAsc(RolOperativo.JEFE_SUCURSAL).stream()
                .filter(empleado -> (userId != null && empleado.getLoginUserId() != null && empleado.getLoginUserId().equals(userId))
                        || (email != null && !email.isBlank() && email.equalsIgnoreCase(empleado.getCorreo())))
                .findFirst()
                .orElse(null);
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

    private String normalizePhone(String phone) {
        return phone == null ? "" : phone.replaceAll("\\D", "");
    }
}
'@

Write-Utf8NoBom 'D:\Descargas\sima\src\main\java\mx\ipn\sima\service\WhatsappConversationContextService.java' @'
package mx.ipn.sima.service;

import mx.ipn.sima.model.CampanaEnvio;
import mx.ipn.sima.model.Cliente;
import mx.ipn.sima.model.WhatsappConversationContext;
import mx.ipn.sima.repository.WhatsappConversationContextRepository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
public class WhatsappConversationContextService {

    private final WhatsappConversationContextRepository repository;

    public WhatsappConversationContextService(WhatsappConversationContextRepository repository) {
        this.repository = repository;
    }

    @Transactional
    public void registerLastSentContext(Cliente cliente, CampanaEnvio campana) {
        if (cliente == null || campana == null || cliente.getTelefono() == null || cliente.getTelefono().isBlank()) {
            return;
        }

        String normalizedPhone = normalizePhone(cliente.getTelefono());
        WhatsappConversationContext context = repository.findByPhoneNumber(normalizedPhone)
                .orElseGet(WhatsappConversationContext::new);
        context.setPhoneNumber(normalizedPhone);
        context.setCliente(cliente);
        context.setCampana(campana);
        context.setAnuncio(campana.getAnuncio());
        context.setJefeResponsable(cliente.getJefeSucursal());
        context.setProductoNombre(campana.getAnuncio() != null ? campana.getAnuncio().getTitulo() : null);
        repository.save(context);
    }

    @Transactional(readOnly = true)
    public ConversationContextData getLastContext(String phone) {
        if (phone == null || phone.isBlank()) {
            return null;
        }

        return repository.findByPhoneNumber(normalizePhone(phone))
                .map(context -> new ConversationContextData(
                        context.getCliente(),
                        context.getCampana(),
                        context.getAnuncio(),
                        context.getJefeResponsable(),
                        context.getProductoNombre()
                ))
                .orElse(null);
    }

    private String normalizePhone(String phone) {
        return phone.replaceAll("\\D", "");
    }

    public record ConversationContextData(
            Cliente cliente,
            CampanaEnvio campana,
            mx.ipn.sima.model.Anuncio anuncio,
            mx.ipn.sima.model.Empleado jefeResponsable,
            String productoNombre
    ) {
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
                conversationContextService.registerLastSentContext(cliente, campana);
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

    public boolean canViewRequests(AuthenticatedUser user) {
        return isGerente(user) || isJefeSucursal(user);
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

Write-Utf8NoBom 'D:\Descargas\sima\src\main\java\mx\ipn\sima\service\WhatsappInteractionService.java' @'
package mx.ipn.sima.service;

import mx.ipn.sima.dto.AuthenticatedUser;
import mx.ipn.sima.dto.WhatsappResponse;
import mx.ipn.sima.model.*;
import mx.ipn.sima.repository.InteraccionClienteRepository;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.text.Normalizer;
import java.time.LocalDateTime;
import java.util.HashMap;
import java.util.List;
import java.util.Locale;
import java.util.Map;

@Service
public class WhatsappInteractionService {

    private static final String ACTION_MAS_INFO = "MAS_INFO";
    private static final String ACTION_HABLAR_ASESOR = "HABLAR_ASESOR";

    private final WhatsappService whatsappService;
    private final WhatsappConversationContextService contextService;
    private final InteraccionClienteRepository interaccionClienteRepository;
    private final AlmacenService almacenService;
    private final String defaultCoordinatorPhone;
    private final String defaultAdvisorName;
    private final String defaultAdvisorPhone;
    private final String defaultMasInfoText;
    private final String masInfoPdfUrl;
    private final String masInfoPdfFilename;
    private final String masInfoPdfCaption;
    private final Map<String, Assignment> assignmentsByProduct;

    public WhatsappInteractionService(
            WhatsappService whatsappService,
            WhatsappConversationContextService contextService,
            InteraccionClienteRepository interaccionClienteRepository,
            AlmacenService almacenService,
            @Value("${whatsapp.flow.default.coordinator:526441177362}") String defaultCoordinatorPhone,
            @Value("${whatsapp.flow.default.asesor:Asesor SIMA}") String defaultAdvisorName,
            @Value("${whatsapp.flow.default.asesor-phone:}") String defaultAdvisorPhone,
            @Value("${whatsapp.flow.mas-info-text:Gracias por tu interes. En breve te compartimos informacion detallada del producto.}") String defaultMasInfoText,
            @Value("${whatsapp.flow.mas-info-pdf-url:}") String masInfoPdfUrl,
            @Value("${whatsapp.flow.mas-info-pdf-filename:informacion.pdf}") String masInfoPdfFilename,
            @Value("${whatsapp.flow.mas-info-pdf-caption:Informacion de la promocion}") String masInfoPdfCaption,
            @Value("${whatsapp.flow.product-routing:}") String productRoutingConfig
    ) {
        this.whatsappService = whatsappService;
        this.contextService = contextService;
        this.interaccionClienteRepository = interaccionClienteRepository;
        this.almacenService = almacenService;
        this.defaultCoordinatorPhone = defaultCoordinatorPhone;
        this.defaultAdvisorName = defaultAdvisorName;
        this.defaultAdvisorPhone = defaultAdvisorPhone;
        this.defaultMasInfoText = defaultMasInfoText;
        this.masInfoPdfUrl = masInfoPdfUrl;
        this.masInfoPdfFilename = masInfoPdfFilename;
        this.masInfoPdfCaption = masInfoPdfCaption;
        this.assignmentsByProduct = parseAssignments(productRoutingConfig);
    }

    @Transactional
    public boolean handleInteractiveReply(WhatsappResponse.Message message) {
        String action = resolveAction(message);
        if (action == null) {
            return false;
        }

        String clientPhone = message.from;
        WhatsappConversationContextService.ConversationContextData contextData = contextService.getLastContext(clientPhone);
        Cliente cliente = contextData != null && contextData.cliente() != null
                ? contextData.cliente()
                : almacenService.findClienteByTelefono(clientPhone);
        CampanaEnvio campana = contextData != null ? contextData.campana() : null;
        Anuncio anuncio = contextData != null ? contextData.anuncio() : null;
        String productName = resolveProductName(message, contextData);
        Empleado jefeResponsable = resolveResponsibleLead(contextData, cliente, productName);

        if (ACTION_MAS_INFO.equals(action)) {
            String detailText = buildMasInfoText(productName, anuncio);
            whatsappService.sendMessage(clientPhone, detailText);

            DocumentPayload payload = resolveDocumentPayload(anuncio);
            if (payload != null) {
                whatsappService.sendDocumentMessage(clientPhone, payload.url(), payload.fileName(), payload.caption());
            }

            InteraccionCliente interaccion = buildInteraction(
                    cliente, campana, anuncio, jefeResponsable,
                    TipoInteraccionCliente.MAS_INFO, clientPhone,
                    getButtonText(message), "Contenido adicional enviado automaticamente."
            );
            interaccion.setEstadoSeguimiento(EstadoSeguimiento.NOTIFICADO);
            interaccionClienteRepository.save(interaccion);
            return true;
        }

        if (ACTION_HABLAR_ASESOR.equals(action)) {
            String advisorName = jefeResponsable != null && jefeResponsable.getNombre() != null && !jefeResponsable.getNombre().isBlank()
                    ? jefeResponsable.getNombre()
                    : resolveAdvisorName(productName);
            String advisorPhone = jefeResponsable != null && jefeResponsable.getTelefono() != null && !jefeResponsable.getTelefono().isBlank()
                    ? jefeResponsable.getTelefono()
                    : resolveAdvisorPhone(productName);

            String clientNotice = "Te contactara el asesor " + advisorName;
            whatsappService.sendMessage(clientPhone, clientNotice);

            String advisorNotice = "El cliente " + clientPhone
                    + " se intereso en la promocion y quiere que lo contacten."
                    + "\nProducto: " + productName
                    + (cliente != null && cliente.getSucursal() != null ? "\nSucursal: " + cliente.getSucursal().getNombre() : "");
            whatsappService.sendMessage(advisorPhone, advisorNotice);

            String coordinatorNotice = "*SIMA - Seguimiento*\n"
                    + "Producto: " + productName + "\n"
                    + "Cliente: " + clientPhone + "\n"
                    + "Responsable: " + advisorName;
            whatsappService.sendMessage(defaultCoordinatorPhone, coordinatorNotice);

            InteraccionCliente interaccion = buildInteraction(
                    cliente, campana, anuncio, jefeResponsable,
                    TipoInteraccionCliente.QUIERE_CONTACTO, clientPhone,
                    getButtonText(message), advisorNotice
            );
            interaccion.setEstadoSeguimiento(EstadoSeguimiento.NOTIFICADO);
            interaccionClienteRepository.save(interaccion);
            return true;
        }

        return false;
    }

    @Transactional
    public void registerFreeTextReply(String clientPhone, String text) {
        WhatsappConversationContextService.ConversationContextData contextData = contextService.getLastContext(clientPhone);
        Cliente cliente = contextData != null && contextData.cliente() != null
                ? contextData.cliente()
                : almacenService.findClienteByTelefono(clientPhone);
        CampanaEnvio campana = contextData != null ? contextData.campana() : null;
        Anuncio anuncio = contextData != null ? contextData.anuncio() : null;
        String productName = contextData != null && contextData.productoNombre() != null
                ? contextData.productoNombre()
                : "Producto sin especificar";
        Empleado jefeResponsable = resolveResponsibleLead(contextData, cliente, productName);

        InteraccionCliente interaccion = buildInteraction(
                cliente, campana, anuncio, jefeResponsable,
                TipoInteraccionCliente.MENSAJE_LIBRE, clientPhone,
                text, "Mensaje libre reenviado al coordinador."
        );
        interaccionClienteRepository.save(interaccion);
    }

    public String getDefaultCoordinatorPhone() {
        return defaultCoordinatorPhone;
    }

    public List<InteraccionCliente> getInteractionsForUser(AuthenticatedUser user) {
        if (user == null) {
            return List.of();
        }
        if (hasAnyToken(user.roles(), "GERENTE", "ADMIN")) {
            return interaccionClienteRepository.findAllByActiveTrueOrderByFechaInteraccionDesc();
        }
        Empleado empleado = almacenService.findEmpleadoByLoginContext(user.userId(), user.email());
        if (empleado == null) {
            return List.of();
        }
        return interaccionClienteRepository.findAllByActiveTrueAndJefeResponsableOrderByFechaInteraccionDesc(empleado);
    }

    private InteraccionCliente buildInteraction(Cliente cliente,
                                                CampanaEnvio campana,
                                                Anuncio anuncio,
                                                Empleado jefeResponsable,
                                                TipoInteraccionCliente tipo,
                                                String clientPhone,
                                                String incomingMessage,
                                                String internalNotification) {
        InteraccionCliente interaccion = new InteraccionCliente();
        interaccion.setCliente(cliente);
        interaccion.setCampana(campana);
        interaccion.setAnuncio(anuncio);
        interaccion.setJefeResponsable(jefeResponsable);
        interaccion.setTipo(tipo);
        interaccion.setTelefonoCliente(clientPhone);
        interaccion.setProductoNombre(anuncio != null ? anuncio.getTitulo() : null);
        interaccion.setMensajeCliente(incomingMessage);
        interaccion.setNotificacionInterna(internalNotification);
        interaccion.setFechaInteraccion(LocalDateTime.now());
        return interaccion;
    }

    private String resolveAction(WhatsappResponse.Message message) {
        String selectedAction = getSelectedAction(message);
        if (selectedAction != null) {
            String actionFromPayload = resolveActionFromRaw(selectedAction);
            if (actionFromPayload != null) {
                return actionFromPayload;
            }
        }

        String buttonText = getButtonText(message);
        if (buttonText == null) {
            return null;
        }

        return resolveActionFromRaw(buttonText);
    }

    private String resolveActionFromRaw(String rawAction) {
        if (rawAction == null || rawAction.isBlank()) {
            return null;
        }

        String normalizedRaw = normalizeText(rawAction);
        if (normalizedRaw.contains(":")) {
            String action = normalizeAction(rawAction);
            if (ACTION_MAS_INFO.equals(action) || ACTION_HABLAR_ASESOR.equals(action)) {
                return action;
            }
        }

        if (normalizedRaw.contains("mas informacion") || normalizedRaw.contains("recibir mas informacion")) {
            return ACTION_MAS_INFO;
        }
        if (normalizedRaw.contains("llamada de un asesor") || normalizedRaw.contains("hablar con un asesor")) {
            return ACTION_HABLAR_ASESOR;
        }
        return null;
    }

    private String resolveProductName(WhatsappResponse.Message message, WhatsappConversationContextService.ConversationContextData contextData) {
        String selectedAction = getSelectedAction(message);
        if (selectedAction != null && selectedAction.contains(":")) {
            return extractProductName(selectedAction);
        }
        if (contextData != null && contextData.productoNombre() != null && !contextData.productoNombre().isBlank()) {
            return contextData.productoNombre();
        }
        return "Producto sin especificar";
    }

    private Empleado resolveResponsibleLead(WhatsappConversationContextService.ConversationContextData contextData,
                                            Cliente cliente,
                                            String productName) {
        if (contextData != null && contextData.jefeResponsable() != null) {
            return contextData.jefeResponsable();
        }
        Empleado clienteOwner = almacenService.findEmpleadoResponsableDeCliente(cliente);
        if (clienteOwner != null) {
            return clienteOwner;
        }

        String configuredAdvisorPhone = resolveAdvisorPhone(productName);
        return almacenService.getJefesSucursal().stream()
                .filter(empleado -> empleado.getTelefono() != null && empleado.getTelefono().replaceAll("\\D", "").equals(configuredAdvisorPhone.replaceAll("\\D", "")))
                .findFirst()
                .orElse(null);
    }

    private DocumentPayload resolveDocumentPayload(Anuncio anuncio) {
        if (anuncio == null || anuncio.getInformacionExtraValor() == null || anuncio.getInformacionExtraValor().isBlank()) {
            if (masInfoPdfUrl == null || masInfoPdfUrl.isBlank()) {
                return null;
            }
            return new DocumentPayload(masInfoPdfUrl, masInfoPdfFilename, masInfoPdfCaption);
        }

        if (anuncio.getInformacionExtraTipo() == InformacionExtraTipo.PDF) {
            return new DocumentPayload(
                    anuncio.getInformacionExtraValor(),
                    masInfoPdfFilename,
                    "Informacion detallada de " + anuncio.getTitulo()
            );
        }

        if (masInfoPdfUrl == null || masInfoPdfUrl.isBlank()) {
            return null;
        }
        return new DocumentPayload(masInfoPdfUrl, masInfoPdfFilename, masInfoPdfCaption);
    }

    private String getSelectedAction(WhatsappResponse.Message message) {
        if (message == null) {
            return null;
        }

        if (message.interactive != null
            && message.interactive.buttonReply != null
            && message.interactive.buttonReply.id != null
            && !message.interactive.buttonReply.id.isBlank()) {
            return message.interactive.buttonReply.id;
        }

        if (message.button != null && message.button.payload != null && !message.button.payload.isBlank()) {
            return message.button.payload;
        }

        return null;
    }

    private String getButtonText(WhatsappResponse.Message message) {
        if (message == null) {
            return null;
        }

        if (message.interactive != null
                && message.interactive.buttonReply != null
                && message.interactive.buttonReply.title != null
                && !message.interactive.buttonReply.title.isBlank()) {
            return message.interactive.buttonReply.title;
        }

        if (message.button != null && message.button.text != null && !message.button.text.isBlank()) {
            return message.button.text;
        }

        if (message.text != null && message.text.body != null && !message.text.body.isBlank()) {
            return message.text.body;
        }

        return null;
    }

    private String normalizeAction(String rawAction) {
        int separatorIndex = rawAction.indexOf(':');
        if (separatorIndex > -1) {
            return rawAction.substring(0, separatorIndex).trim().toUpperCase();
        }
        return rawAction.trim().toUpperCase();
    }

    private String normalizeText(String text) {
        String normalized = Normalizer.normalize(text, Normalizer.Form.NFD)
                .replaceAll("\\p{M}", "");
        return normalized.trim().toLowerCase(Locale.ROOT);
    }

    private String extractProductName(String rawAction) {
        int separatorIndex = rawAction.indexOf(':');
        if (separatorIndex > -1 && separatorIndex + 1 < rawAction.length()) {
            return rawAction.substring(separatorIndex + 1).trim();
        }
        return "Producto sin especificar";
    }

    private String buildMasInfoText(String productName, Anuncio anuncio) {
        if (anuncio != null && anuncio.getInformacionExtraTipo() == InformacionExtraTipo.TEXTO
                && anuncio.getInformacionExtraValor() != null && !anuncio.getInformacionExtraValor().isBlank()) {
            return "Informacion adicional de " + productName + ":\n" + anuncio.getInformacionExtraValor();
        }
        return "Informacion adicional de " + productName + ":\n" + defaultMasInfoText;
    }

    private String resolveAdvisorName(String productName) {
        Assignment assignment = getAssignmentForProduct(productName);
        return assignment != null ? assignment.advisorName() : defaultAdvisorName;
    }

    private String resolveAdvisorPhone(String productName) {
        Assignment assignment = getAssignmentForProduct(productName);
        String phone = assignment != null ? assignment.advisorPhone() : defaultAdvisorPhone;
        if (phone == null || phone.isBlank()) {
            return defaultCoordinatorPhone;
        }
        return phone;
    }

    private Assignment getAssignmentForProduct(String productName) {
        if (productName == null) {
            return null;
        }
        String key = productName.trim().toLowerCase(Locale.ROOT);
        return assignmentsByProduct.get(key);
    }

    private Map<String, Assignment> parseAssignments(String config) {
        Map<String, Assignment> result = new HashMap<>();
        if (config == null || config.isBlank()) {
            return result;
        }

        String[] entries = config.split(";");
        for (String entry : entries) {
            String[] parts = entry.split("\\|");
            if (parts.length != 3) {
                continue;
            }

            String productKey = parts[0].trim().toLowerCase(Locale.ROOT);
            String advisor = parts[1].trim();
            String advisorPhone = parts[2].trim();
            if (!productKey.isBlank() && !advisor.isBlank() && !advisorPhone.isBlank()) {
                result.put(productKey, new Assignment(advisor, advisorPhone));
            }
        }
        return result;
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

    private record Assignment(String advisorName, String advisorPhone) {
    }

    private record DocumentPayload(String url, String fileName, String caption) {
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

    @ModelAttribute("canViewRequests")
    public boolean canViewRequests(HttpSession session) {
        AuthenticatedUser user = currentUser(session);
        return user != null && roleAccessService.canViewRequests(user);
    }
}
'@

Write-Utf8NoBom 'D:\Descargas\sima\src\main\java\mx\ipn\sima\controller\SolicitudController.java' @'
package mx.ipn.sima.controller;

import jakarta.servlet.http.HttpSession;
import mx.ipn.sima.dto.AuthenticatedUser;
import mx.ipn.sima.service.RoleAccessService;
import mx.ipn.sima.service.WhatsappInteractionService;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;

@Controller
@RequestMapping("/solicitudes")
public class SolicitudController {

    private final RoleAccessService roleAccessService;
    private final WhatsappInteractionService whatsappInteractionService;

    public SolicitudController(RoleAccessService roleAccessService,
                               WhatsappInteractionService whatsappInteractionService) {
        this.roleAccessService = roleAccessService;
        this.whatsappInteractionService = whatsappInteractionService;
    }

    @GetMapping
    public String listarSolicitudes(Model model, HttpSession session) {
        roleAccessService.requireRequestsView(session);
        AuthenticatedUser user = roleAccessService.getCurrentUser(session);
        model.addAttribute("solicitudes", whatsappInteractionService.getInteractionsForUser(user));
        return "solicitudes-lista";
    }
}
'@

Write-Utf8NoBom 'D:\Descargas\sima\src\main\java\mx\ipn\sima\controller\WhatsappWebhookController.java' @'
package mx.ipn.sima.controller;

import mx.ipn.sima.dto.WhatsappResponse;
import mx.ipn.sima.service.WhatsappInteractionService;
import mx.ipn.sima.service.WhatsappService;
import org.springframework.http.ResponseEntity;
import org.springframework.scheduling.annotation.Async;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/webhook")
public class WhatsappWebhookController {

    private final WhatsappService whatsappService;
    private final WhatsappInteractionService interactionService;

    public WhatsappWebhookController(WhatsappService whatsappService,
                                     WhatsappInteractionService interactionService) {
        this.whatsappService = whatsappService;
        this.interactionService = interactionService;
    }

    @GetMapping
    public ResponseEntity<String> verifyWebhook(
            @RequestParam("hub.mode") String mode,
            @RequestParam("hub.verify_token") String token,
            @RequestParam("hub.challenge") String challenge) {
        if ("subscribe".equals(mode) && "SIMA_EDUCACION_UNIVERSO_7821".equals(token)) {
            return ResponseEntity.ok(challenge);
        }
        return ResponseEntity.status(403).build();
    }

    @PostMapping
    public ResponseEntity<Void> handleIncomingMessage(@RequestBody WhatsappResponse payload) {
        processAsync(payload);
        return ResponseEntity.ok().build();
    }

    @Async
    protected void processAsync(WhatsappResponse payload) {
        try {
            if (payload.entry != null && !payload.entry.isEmpty()
                    && payload.entry.get(0).changes != null && !payload.entry.get(0).changes.isEmpty()) {
                var value = payload.entry.get(0).changes.get(0).value;

                if (value.messages != null && !value.messages.isEmpty()) {
                    var message = value.messages.get(0);
                    String cliente = message.from;
                    String texto = (message.text != null && message.text.body != null && !message.text.body.isBlank())
                            ? message.text.body
                            : "(Mensaje sin texto)";

                    if (interactionService.handleInteractiveReply(message)) {
                        return;
                    }

                    interactionService.registerFreeTextReply(cliente, texto);

                    String coordinador = interactionService.getDefaultCoordinatorPhone();
                    String aviso = "*SIMA - Nuevo Mensaje*\nDe: " + cliente + "\nDice: " + texto;
                    whatsappService.sendMessage(coordinador, aviso);
                }
            }
        } catch (Exception e) {
            System.err.println("Error procesando DTO: " + e.getMessage());
        }
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
        <div class="col-md-3">
            <div class="card shadow-sm h-100">
                <div class="card-body">
                    <h5 class="card-title">Gestion de Clientes</h5>
                    <p class="text-muted small">Alta y consulta de clientes, sucursal y responsable.</p>
                    <a href="/clientes/lista" class="btn btn-primary w-100 mb-2">Ver Clientes</a>
                    <a th:if="${canManageClients}" href="/clientes/nuevo" class="btn btn-primary w-100">Agregar Cliente</a>
                </div>
            </div>
        </div>

        <div class="col-md-3">
            <div class="card shadow-sm h-100">
                <div class="card-body">
                    <h5 class="card-title">Gestion de Anuncios</h5>
                    <p class="text-muted small">Catalogo de promociones, imagen publica y contenido adicional.</p>
                    <a href="/anuncios/lista" class="btn btn-primary w-100 mb-2">Ver Anuncios</a>
                    <a th:if="${canManageAds}" href="/anuncios/nuevo" class="btn btn-primary w-100">Crear Anuncio</a>
                </div>
            </div>
        </div>

        <div class="col-md-3">
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

        <div class="col-md-3">
            <div class="card shadow-sm h-100">
                <div class="card-body">
                    <h5 class="card-title">Solicitudes</h5>
                    <p class="text-muted small">Respuestas recibidas, seguimiento y avisos a jefes responsables.</p>
                    <a th:if="${canViewRequests}" href="/solicitudes" class="btn btn-primary w-100">Ver Solicitudes</a>
                </div>
            </div>
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
            <a href="/dashboard" class="btn btn-primary">Menu</a>
            <a th:if="${canManageCampaigns}" href="/envio/lista" class="btn btn-primary">Campanas</a>
            <a href="/clientes/lista" class="btn btn-primary">Clientes</a>
        </div>
    </div>

    <div class="d-flex justify-content-between align-items-center mb-3">
        <div>
            <h3 class="mb-0">Solicitudes e Interacciones</h3>
            <small class="text-muted">El jefe ve las solicitudes asignadas cuando su empleado esta enlazado con el login central.</small>
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
                    <td colspan="7" class="text-center text-muted py-4">Aun no hay respuestas registradas para mostrar.</td>
                </tr>
                </tbody>
            </table>
        </div>
    </div>
</div>
</body>
</html>
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
                        "/solicitudes/**"
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
