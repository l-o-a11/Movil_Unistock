# Propuestas de Mejora de Documentación (Doc Comments)

Documento con propuestas de cambios de documentación para archivos Dart en las carpetas: `produccion`, `terceros` y `proveedores`.

---

## 📂 MÓDULO PRODUCCIÓN

### 1. app_dependencies.dart

**Ruta:** `lib/domain/produccion/app_dependencies.dart`

#### Mejora 1: Documentar clase AppDependencies

**Línea:** 10 (antes de `class AppDependencies`)

```dart
/// Inyección de dependencias del módulo Producción.
///
/// Organiza la creación de repositorios, usecases y providers para:
/// - [ProduccionProvider]: gestión de órdenes de producción
/// - [OrdenDetailProvider]: detalle de una orden específica
/// - Delegación de dependencias de [TercerosDependencies]
///
/// No instantiar directamente; usar métodos estáticos [createProduccionProvider]
/// y [createOrdenDetailProvider] para crear providers.
```

#### Mejora 2: Documentar método \_buildOrdenRepository

**Línea:** 15 (antes del método)

```dart
/// Construye la implementación del repositorio de órdenes.
///
/// Retorna [OrdenRepositoryImpl] configurado con [OrdenLocalDataSourceImpl]
/// como fuente de datos local (mock/caché).
static OrdenRepositoryImpl _buildOrdenRepository() =>
```

---

### 2. app_shell.dart

**Ruta:** `lib/domain/produccion/app_shell.dart`

#### Mejora 1: Documentar clase AppShell

**Línea:** 9 (antes de `class AppShell`)

```dart
/// Shell de Producción que renderiza [ProduccionPage] directamente.
///
/// No contiene Navigator interno para evitar pantalla negra al navegar.
/// Utiliza el Navigator del menú principal para gestionar la navegación.
///
/// Parámetros:
/// - [openTerceros]: si `true`, inicia en la tab de Terceros automáticamente.
class AppShell extends StatefulWidget {
```

#### Mejora 2: Documentar inicialización en initState

**Línea:** 19 (antes del método initState)

```dart
/// Inicializa el shell y opcionalmente cambia a la tab de Terceros.
///
/// Si [openTerceros] es `true`, dispara un post-frame callback para cambiar
/// la tab activa a [ProduccionTab.terceros] mediante [ProduccionProvider].
@override
void initState() {
```

---

### 3. produccion.dart

**Ruta:** `lib/domain/produccion/produccion.dart`

#### Mejora 1: Documentar clase ProduccionApp

**Línea:** 12 (antes de `class ProduccionApp`)

```dart
/// Punto de entrada del módulo Producción.
///
/// Configura los providers mediante [MultiProvider]:
/// - [ProduccionProvider]: gestión de órdenes y filtros
/// - [TercerosProvider]: lista y detalles de terceros
///
/// Aplica [AppTheme.light] a todo el árbol de widgets.
/// **Nota:** No crea un MaterialApp propio; usa el del menú principal.
///
/// Parámetros:
/// - [openTerceros]: si `true`, inicia mostrando la tab de Terceros.
class ProduccionApp extends StatelessWidget {
```

---

### 4. core/theme/app_theme.dart

**Ruta:** `lib/domain/produccion/core/theme/app_theme.dart`

#### Mejora 1: Documentar clase AppTheme

**Línea:** 4 (antes de `class AppTheme`)

```dart
/// Definición centralizada del tema visual de Producción.
///
/// Proporciona el [ThemeData] light (Material 3) con:
/// - Colores semánticos desde [AppColors]
/// - Tipografía estándar (Roboto)
/// - Estilos para AppBar, Card, InputDecoration
/// - Border radius consistente (12-16px)
///
/// Uso: `Theme(data: AppTheme.light, child: ...)`
class AppTheme {
```

#### Mejora 2: Documentar método light

**Línea:** 7 (antes del getter)

```dart
/// Retorna el [ThemeData] ligero (modo claro) para la aplicación.
///
/// Incluye:
/// - Color scheme basado en [AppColors.primary] (rosa)
/// - Estilos para AppBar sin elevation
/// - Tarjetas con borde sutil ([AppColors.cardBorder])
/// - Campo de búsqueda con radius 12px y relleno [AppColors.searchBackground]
/// - Hints grises ([AppColors.textHint])
static ThemeData get light => ThemeData(
```

---

### 5. core/constants/app_colors.dart

**Ruta:** `lib/domain/produccion/core/constants/app_colors.dart`

#### Mejora 1: Documentar clase AppColors

**Línea:** 2 (antes de `class AppColors`)

```dart
/// Paleta de colores centralizada para el módulo Producción.
///
/// Mantiene consistencia visual con grupos semánticos:
/// - **Primary (rosa):** color principal y acciones
/// - **Estados:** pending (gris), alertas
/// - **Superficies:** background, surface, bordes
/// - **Texto:** primario, secundario, hints
/// - **Componentes:** nav bar, chips, search
///
/// Ejemplo: `Container(color: AppColors.primary)`
class AppColors {
```

#### Mejora 2: Documentar grupos de colores (opcional, pero útil)

**Línea 5** (mantener como está con comentarios):

```dart
// Ya tiene comentarios, pero se pueden mejorar delimitadores:

/// Primary color (rosa) - color principal de la app
/// - [primary]: rosa intenso (#E91E8C) para botones y acciones
/// - [primaryLight]: rosa muy clara para fondos segundarios
/// - [primarySoft]: rosa ultra clara para bordes suaves
/// - [primaryBorder]: alias semántico para bordes primarios
static const Color primary = Color(0xFFE91E8C);
```

---

### 6. features/presentation/providers/produccion_provider.dart

**Ruta:** `lib/domain/produccion/features/presentation/providers/produccion_provider.dart`

#### Mejora 1: Documentar clase ProduccionProvider

**Línea:** 6 (antes de `class ProduccionProvider`)

```dart
/// Provider que gestiona el estado de órdenes de producción.
///
/// Responsabilidades:
/// - Cargar órdenes filtradas (por estado, tipo, búsqueda)
/// - Cambiar entre tabs (Producción / Terceros)
/// - Aplicar filtros de estado
/// - Gestionar expansión de tarjetas (una abierta a la vez)
///
/// Se inicializa automáticamente con [loadOrdenes].
///
/// Métodos principales:
/// - [loadOrdenes]: recarga la lista (llama [GetOrdenesUseCase])
/// - [changeTab]: cambia a [ProduccionTab.produccion] o [ProduccionTab.terceros]
/// - [setFiltroEstado]: filtra por [OrdenEstado]
/// - [setSearch]: filtra por query de búsqueda
class ProduccionProvider extends ChangeNotifier {
```

#### Mejora 2: Documentar método loadOrdenes

**Línea:** 17 (antes del método)

```dart
/// Carga la lista de órdenes según filtros actuales.
///
/// Consulta [GetOrdenesUseCase] con:
/// - [OrdenEstado] del filtro actual (si existe)
/// - [OrdenTipo]: 'terceros' si tab activo es Terceros, 'produccion' en otro caso
/// - Query de búsqueda (si no está vacía)
///
/// Actualiza [_state] con [isLoading], datos cargados o error.
Future<void> loadOrdenes() async {
```

#### Mejora 3: Documentar método changeTab

**Línea:** 32 (antes del método)

```dart
/// Cambia la tab activa ([activeTab]) y recarga órdenes.
///
/// Parámetros:
/// - [tab]: [ProduccionTab.produccion] o [ProduccionTab.terceros]
///
/// Al cambiar tab, limpia ids expandidos ([expandedIds]) para resetear UI.
void changeTab(ProduccionTab tab) {
```

#### Mejora 4: Documentar método toggleExpanded

**Línea:** 39 (antes del método)

```dart
/// Alterna la expansión de una tarjeta de orden.
///
/// Solo permite una tarjeta abierta a la vez:
/// - Si [id] ya está expandida, la cierra
/// - Si otra estaba abierta, la cierra y abre esta
///
/// Parámetros:
/// - [id]: identificador único de la tarjeta a toggle
void toggleExpanded(String id) {
```

---

### 7. features/presentation/state/produccion_state.dart

**Ruta:** `lib/domain/produccion/features/presentation/state/produccion_state.dart`

#### Mejora: Documentar clase ProduccionState

**Línea 1** (inicio del archivo):

```dart
/// Estado inmutable que representa el estado de la pantalla de Producción.
///
/// Propiedades principales:
/// - [ordenes]: lista de órdenes cargadas ([OrdenEntity])
/// - [activeTab]: tab activo ([ProduccionTab.produccion] o [.terceros])
/// - [isLoading]: indicador de carga
/// - [error]: mensaje de error (nulo si no hay error)
/// - [filtroEstado]: filtro opcional de [OrdenEstado]
/// - [searchQuery]: texto de búsqueda actual
/// - [expandedIds]: conjunto de ids de órdenes expandidas (máximo 1)
///
/// Uso: actualizar vía [copyWith] para crear nuevas instancias inmutables.
class ProduccionState {
```

---

## 📂 MÓDULO TERCEROS

### 1. features/domain/entities/tercero_entity.dart

**Ruta:** `lib/domain/terceros/features/domain/entities/tercero_entity.dart`

#### Mejora 1: Documentar enum TerceroEstado

**Línea:** 1 (antes del enum)

```dart
/// Estados posibles de un tercero (proveedor o subcontratista).
///
/// - [activo]: tercero disponible para asignación de órdenes
/// - [inactivo]: tercero desactivado, no disponible
enum TerceroEstado { activo, inactivo }
```

#### Mejora 2: Documentar clase TerceroEntity

**Línea:** 3 (antes de `class TerceroEntity`)

```dart
/// Entidad base que representa un tercero (proveedor o subcontratista externo).
///
/// Contiene información de identificación y contacto.
///
/// Propiedades:
/// - [id]: identificador único
/// - [codigo]: código interno de la empresa
/// - [nombre]: razón social del tercero
/// - [contacto]: persona contacto principal
/// - [nit]: número de identificación tributaria
/// - [direccion]: domicilio comercial
/// - [telefono]: número de teléfono de contacto
/// - [estado]: [TerceroEstado.activo] o [.inactivo]
///
/// Getters útiles:
/// - [isActivo]: alias para `estado == TerceroEstado.activo`
/// - [estadoLabel]: label legible ('Activo' / 'Inactivo')
class TerceroEntity {
```

---

### 2. features/domain/entities/tercero_detail_entity.dart

**Ruta:** `lib/domain/terceros/features/domain/entities/tercero_detail_entity.dart`

#### Mejora: Documentar clase TerceroDetailEntity

**Línea:** 3 (antes de `class TerceroDetailEntity`)

```dart
/// Extensión de [TerceroEntity] que incluye lista de producciones asociadas.
///
/// Utilizado en pantalla de detalle para mostrar:
/// - Información general del tercero (heredada de [TerceroEntity])
/// - Historial de cortes/producciones completadas ([producciones])
///
/// Parámetros adicionales:
/// - [producciones]: lista de [TerceroProduccionEntity] (cortes asignados)
class TerceroDetailEntity extends TerceroEntity {
```

---

### 3. features/domain/entities/tercero_produccion_entity.dart

**Ruta:** `lib/domain/terceros/features/domain/entities/tercero_produccion_entity.dart`

#### Mejora: Documentar clase TerceroProduccionEntity

**Línea:** 1 (antes de `class TerceroProduccionEntity`)

```dart
/// Registro de un corte/producción asignada a un tercero.
///
/// Propiedades:
/// - [corte]: número o identificador del corte (ej: "CT-2024-001")
/// - [fecha]: fecha en que se asignó el corte
/// - [ordenId]: referencia a la orden de producción ([OrdenEntity])
///
/// Típicamente aparece dentro de [TerceroDetailEntity.producciones].
class TerceroProduccionEntity {
```

---

### 4. features/domain/repositories/tercero_repository.dart

**Ruta:** `lib/domain/terceros/features/domain/repositories/tercero_repository.dart`

#### Mejora: Documentar clase TerceroRepository

**Línea:** 3 (antes de `abstract class TerceroRepository`)

```dart
/// Contrato (interfaz) para acceso a datos de terceros.
///
/// Implementación: [TerceroRepositoryImpl]
///
/// Métodos principales:
/// - [getTerceros]: obtiene lista filtrada de terceros
/// - [getTerceroDetail]: obtiene detalle completo de un tercero
abstract class TerceroRepository {
```

#### Mejora 2: Documentar métodos en el repositorio

**Línea:** 4 y 5 (antes de cada método)

```dart
// Reemplazar:
  Future<List<TerceroEntity>> getTerceros({String? query});
  Future<TerceroDetailEntity?> getTerceroDetail(String id);

// Por:
  /// Obtiene lista completa o filtrada de terceros.
  ///
  /// Parámetros:
  /// - [query]: campo de búsqueda opcional (busca en nombre, código, NIT, contacto)
  ///
  /// Retorna lista de [TerceroEntity] o lista vacía si no hay resultados.
  Future<List<TerceroEntity>> getTerceros({String? query});

  /// Obtiene el detalle completo de un tercero específico.
  ///
  /// Parámetros:
  /// - [id]: identificador único del tercero
  ///
  /// Retorna [TerceroDetailEntity] si existe, `null` en caso contrario.
  Future<TerceroDetailEntity?> getTerceroDetail(String id);
```

---

### 5. features/domain/usecases/get_terceros_usecase.dart

**Ruta:** `lib/domain/terceros/features/domain/usecases/get_terceros_usecase.dart`

#### Mejora 1: Documentar clase GetTercerosUseCase

**Línea:** 3 (antes de `class GetTercerosUseCase`)

```dart
/// Use case que obtiene la lista de terceros.
///
/// Delega la lógica de obtención al [TerceroRepository] para mantener
/// separación entre capa de presentación y lógica de datos.
///
/// Uso: `await GetTercerosUseCase(repository).call(query: 'ABC')`
class GetTercerosUseCase {
```

#### Mejora 2: Documentar constructor y método call

**Línea:** 5 (antes del constructor)

```dart
  /// Constructor que recibe el [TerceroRepository] inyectado.
  final TerceroRepository repository;
  const GetTercerosUseCase(this.repository);

  /// Ejecuta el use case: obtiene terceros.
  ///
  /// Parámetros:
  /// - [query]: filtro de búsqueda opcional
  ///
  /// Retorna: [Future<List<TerceroEntity>>]
  Future<List<TerceroEntity>> call({String? query}) =>
      repository.getTerceros(query: query);
```

---

### 6. features/domain/usecases/get_tercero_detail_usecase.dart

**Ruta:** `lib/domain/terceros/features/domain/usecases/get_tercero_detail_usecase.dart`

#### Mejora: Documentar clase GetTerceroDetailUseCase

**Línea:** 3 (antes de `class GetTerceroDetailUseCase`)

```dart
/// Use case que obtiene el detalle completo de un tercero específico.
///
/// Delega al [TerceroRepository] e incluye lista de producciones asociadas.
///
/// Uso: `await GetTerceroDetailUseCase(repository).call('tercero-id-123')`
class GetTerceroDetailUseCase {
```

#### Mejora 2: Documentar método call

**Línea:** 6 (antes del método)

```dart
  /// Ejecuta el use case: obtiene detalle de un tercero.
  ///
  /// Parámetros:
  /// - [id]: identificador único del tercero
  ///
  /// Retorna: [TerceroDetailEntity?] o `null` si no existe
  Future<TerceroDetailEntity?> call(String id) =>
      repository.getTerceroDetail(id);
```

---

### 7. features/presentation/state/terceros_state.dart

**Ruta:** `lib/domain/terceros/features/presentation/state/terceros_state.dart`

#### Mejora: Documentar clase TercerosState

**Línea:** 1 (antes de `class TercerosState`)

```dart
/// Estado inmutable para la pantalla de lista de terceros.
///
/// Propiedades:
/// - [terceros]: lista cargada de [TerceroEntity]
/// - [isLoading]: indicador de carga
/// - [error]: mensaje de error (null si no hay error)
/// - [searchQuery]: texto de búsqueda actual (para filtrar y recordar)
///
/// Uso estándar: actualizar vía [copyWith] para inmutabilidad.
///
/// Getters recomendados:
/// - `bool get hasError => error != null`
/// - `bool get isNotEmpty => terceros.isNotEmpty`
class TercerosState {
```

---

### 8. features/presentation/state/tercero_detail_state.dart

**Ruta:** `lib/domain/terceros/features/presentation/state/tercero_detail_state.dart`

#### Mejora 1: Documentar enum TerceroDetailStatus

**Línea:** 1 (antes del enum)

```dart
/// Estados posibles al cargar detalle de un tercero.
///
/// - [initial]: estado inicial, no se ha solicitado data
/// - [loading]: cargando detalle del tercero
/// - [loaded]: detalle cargado exitosamente
/// - [error]: error durante la carga
enum TerceroDetailStatus { initial, loading, loaded, error }
```

#### Mejora 2: Documentar clase TerceroDetailState

**Línea:** 3 (antes de `class TerceroDetailState`)

```dart
/// Estado inmutable para la pantalla de detalle de un tercero.
///
/// Propiedades:
/// - [status]: [TerceroDetailStatus] actual (initial, loading, loaded, error)
/// - [detail]: [TerceroDetailEntity?] si está cargado
/// - [error]: mensaje de error (null si no hay error)
///
/// Getters útiles:
/// - [isLoading]: true si status == TerceroDetailStatus.loading
/// - [hasError]: true si status == TerceroDetailStatus.error
/// - [isLoaded]: true si status == TerceroDetailStatus.loaded
///
/// Uso: actualizar vía [copyWith].
class TerceroDetailState {
```

---

### 9. features/presentation/providers/terceros_provider.dart

**Ruta:** `lib/domain/terceros/features/presentation/providers/terceros_provider.dart`

#### Mejora 1: Documentar clase TercerosProvider

**Línea:** 6 (antes de `class TercerosProvider`)

```dart
/// Provider que gestiona el estado de la lista de terceros.
///
/// Responsabilidades:
/// - Cargar lista inicial de terceros vía [GetTercerosUseCase]
/// - Filtrar terceros vía búsqueda ([updateSearch])
/// - Mantener estado sincronizado ([TercerosState])
///
/// Integración:
/// - Usa [TercerosApiService] para obtener datos (remoto + fallback local)
/// - Se inicializa automáticamente en constructor con [loadTerceros]
///
/// Métodos principales:
/// - [loadTerceros]: recarga lista según búsqueda actual
/// - [updateSearch]: actualiza query e inmediatamente recarga
class TercerosProvider extends ChangeNotifier {
```

#### Mejora 2: Documentar método loadTerceros

**Línea:** 20 (antes del método)

```dart
/// Carga o recarga la lista de terceros desde [TercerosApiService].
///
/// Actualiza [_state] mostrando:
/// - [isLoading]: true mientras se obtienen datos
/// - [terceros]: resultado final
/// - [error]: message si falla la carga
///
/// Usa [searchQuery] del estado actual para filtrar si no está vacío.
Future<void> loadTerceros() async {
```

#### Mejora 3: Documentar método updateSearch

**Línea:** 35 (antes del método)

```dart
/// Actualiza el query de búsqueda y recarga la lista automáticamente.
///
/// Parámetros:
/// - [query]: texto a buscar (búsqueda en nombre, código, NIT, etc.)
///
/// Si [query] está vacío, carga toda la lista sin filtro.
void updateSearch(String query) {
```

---

### 10. features/presentation/providers/tercero_detail_provider.dart

**Ruta:** `lib/domain/terceros/features/presentation/providers/tercero_detail_provider.dart`

#### Mejora 1: Documentar clase TerceroDetailProvider

**Línea:** 6 (antes de `class TerceroDetailProvider`)

```dart
/// Provider que gestiona el estado de la página de detalle de un tercero.
///
/// Responsabilidades:
/// - Cargar detalle completo de un tercero vía [GetTerceroDetailUseCase]
/// - Mantener estado sincronizado ([TerceroDetailState])
/// - Manejar estados de carga, error y éxito
///
/// Integración:
/// - Usa [TercerosApiService] para obtener datos (remoto + fallback local)
/// - **No se inicializa automáticamente:** requiere llamada explícita a [loadDetail]
///
/// Método principal:
/// - [loadDetail]: carga detalle de un tercero específico por [id]
class TerceroDetailProvider extends ChangeNotifier {
```

#### Mejora 2: Documentar método loadDetail

**Línea:** 18 (antes del método)

```dart
/// Carga el detalle completo de un tercero específico.
///
/// Parámetros:
/// - [id]: identificador único del tercero
///
/// Actualiza [_state] con:
/// - [status]: TerceroDetailStatus.loading mientras se carga
/// - [detail]: [TerceroDetailEntity] si carga exitosamente
/// - [status] + [error]: ambos si ocurre error o tercero no existe
Future<void> loadDetail(String id) async {
```

---

### 11. features/presentation/pages/terceros_page.dart

**Ruta:** `lib/domain/terceros/features/presentation/pages/terceros_page.dart`

#### Mejora: Documentar clase TercerosPage

**Línea:** 10 (antes de `class TercerosPage`)

```dart
/// Pantalla principal de listado de terceros (standalone).
///
/// Características:
/// - Se navega desde el menú principal como view independiente
/// - Crea su propio [TercerosProvider] vía [TercerosDependencies]
/// - Incluye barra de búsqueda y lista de tarjetas
/// - Cada tarjeta navega a [TerceroDetailPage] al hacer tap
///
/// Estructura:
/// - AppBar con botón atrás y título
/// - Campo de búsqueda (SearchBar)
/// - Lista scrollable de [TerceroCard]
/// - Indicador de carga y manejo de errores
class TercerosPage extends StatelessWidget {
```

---

### 12. features/presentation/pages/tercero_detail_page.dart

**Ruta:** `lib/domain/terceros/features/presentation/pages/tercero_detail_page.dart`

#### Mejora: Documentar clase TerceroDetailPage

**Línea:** 12 (antes de `class TerceroDetailPage`)

```dart
/// Pantalla de detalle de un tercero con navegación por tabs.
///
/// Tabs disponibles:
/// 1. **Info General:** Información de contacto, NIT, dirección, estado
/// 2. **Producciones:** Historial de cortes/producciones asignadas
///
/// Características:
/// - Carga automática del detalle al entrar (via initState)
/// - Manejo de estados: loading, loaded, error
/// - TabBar para navegar entre pestañas
/// - AppBar con botón atrás y nombre del tercero
///
/// Parámetro requerido:
/// - [tercero]: [TerceroEntity] del tercero (obtenido de lista)
class TerceroDetailPage extends StatefulWidget {
```

#### Mejora 2: Documentar initState

**Línea:** 19 (antes del método)

```dart
  /// Inicializa la página y solicita carga del detalle del tercero.
  ///
  /// Via post-frame callback, dispara [TerceroDetailProvider.loadDetail]
  /// con el id del tercero para obtener información completa y producciones.
  @override
  void initState() {
```

---

### 13. features/data/services/terceros_api_service.dart

**Ruta:** `lib/domain/terceros/features/data/services/terceros_api_service.dart`

#### Mejora 1: Documentar constructor

**Línea:** 13 (antes del constructor)

```dart
  /// Constructor del servicio de API.
  ///
  /// Parámetros:
  /// - [baseUrl]: URL base de la API REST (default: 'https://api.example.com')
  /// - [local]: datasource local para fallback (default: [TerceroLocalDataSourceImpl])
  ///
  /// Si la API falla, automáticamente usa [_local] para mantener app funcional.
  TercerosApiService({
```

#### Mejora 2: Documentar método getTerceros

**Línea:** 19 (antes del método)

```dart
  /// Obtiene lista de terceros desde la API REST.
  ///
  /// Parámetros:
  /// - [query]: término de búsqueda opcional
  ///
  /// Fallback: si API falla o no está disponible, usa [_local.getTerceros]
  ///
  /// Retorna: [Future<List<TerceroEntity>>]
  Future<List<TerceroEntity>> getTerceros({String? query}) async {
```

#### Mejora 3: Documentar método getTerceroDetail

**Línea:** 41 (antes del método)

```dart
  /// Obtiene detalle completo de un tercero desde la API REST.
  ///
  /// Parámetros:
  /// - [id]: identificador único del tercero
  ///
  /// Fallback: si API falla, busca en [_local] (mock data)
  ///
  /// Retorna: [TerceroDetailEntity?] o `null` si no existe
  Future<TerceroDetailEntity?> getTerceroDetail(String id) async {
```

---

## 📂 MÓDULO PROVEEDORES

### 1. features/domain/entities/proveedor_entity.dart

**Ruta:** `lib/domain/proveedores/features/domain/entities/proveedor_entity.dart`

#### Mejora 1: Documentar enum ProveedorEstado

**Línea:** 1 (antes del enum)

```dart
/// Estados posibles de un proveedor.
///
/// - [activo]: proveedor disponible para compras/interacción
/// - [inactivo]: proveedor desactivado
enum ProveedorEstado { activo, inactivo }
```

#### Mejora 2: Documentar clase ProveedorEntity

**Línea:** 3 (antes de `class ProveedorEntity`)

```dart
/// Entidad que representa un proveedor de materiales/servicios.
///
/// Contiene información de identificación, contacto y estado.
///
/// Propiedades:
/// - [id]: identificador único
/// - [nit]: número de identificación tributaria
/// - [nombre]: razón social del proveedor
/// - [contacto]: persona de contacto principal
/// - [direccion]: domicilio comercial
/// - [telefono]: número telefónico
/// - [correo]: correo electrónico de contacto
/// - [sitioWeb]: sitio web del proveedor
/// - [estado]: [ProveedorEstado.activo] o [.inactivo]
///
/// Getters útiles:
/// - [isActivo]: alias para `estado == ProveedorEstado.activo`
/// - [estadoLabel]: label legible ('ACTIVO' / 'INACTIVO')
class ProveedorEntity {
```

---

### 2. features/presentation/providers/proveedores_provider.dart

**Ruta:** `lib/domain/proveedores/features/presentation/providers/proveedores_provider.dart`

#### Mejora: Documentar clase ProveedoresProvider

**Línea:** 5 (antes de `class ProveedoresProvider`)

```dart
/// Provider que gestiona el estado de la lista de proveedores.
///
/// Responsabilidades:
/// - Cargar lista de proveedores desde [ProveedoresApiService]
/// - Filtrar por búsqueda (nombre, NIT, contacto, etc.)
/// - Mantener estado de carga y errores
///
/// Propiedades principales:
/// - [items]: lista de [ProveedorEntity] cargados
/// - [isLoading]: indicador de carga
/// - [error]: mensaje de error (null si no hay error)
///
/// Se inicializa automáticamente con [load] en constructor.
///
/// Métodos principales:
/// - [load]: recarga lista completa o con filtro de búsqueda
/// - [search]: atajo para [load] con parámetro de búsqueda
class ProveedoresProvider extends ChangeNotifier {
```

#### Mejora 2: Documentar método load

**Línea:** 16 (antes del método)

```dart
  /// Carga o recarga la lista de proveedores.
  ///
  /// Parámetros:
  /// - [q]: término de búsqueda opcional
  ///
  /// Actualiza [items], [isLoading], [error] según resultado.
  /// Si [q] está vacío, carga todos los proveedores.
  Future<void> load({String? q}) async {
```

#### Mejora 3: Documentar método search

**Línea:** 23 (antes del método)

```dart
  /// Busca proveedores por término.
  ///
  /// Parámetros:
  /// - [q]: término de búsqueda
  ///
  /// Atajo: equivalente a `load(q: q)`
  void search(String q) => load(q: q);
```

---

### 3. features/data/services/proveedores_api_service.dart

**Ruta:** `lib/domain/proveedores/features/data/services/proveedores_api_service.dart`

#### Mejora 1: Documentar constructor

**Línea:** 14 (antes de la existente)

```dart
  /// Constructor del servicio de API de proveedores.
  ///
  /// Parámetros:
  /// - [baseUrl]: URL base de la API REST (default: 'https://api.example.com')
  /// - [local]: datasource local para fallback (default: [ProveedorDataSource])
  ///
  /// Estrategia: intenta API remota; si falla, usa [_local] para mock data.
  final String baseUrl;
  final ProveedorDataSource _local;

  ProveedoresApiService({
```

#### Mejora 2: Documentar método getAll

**Línea:** 24 (antes del método)

```dart
  /// Obtiene lista completa o filtrada de proveedores desde la API.
  ///
  /// Parámetros:
  /// - [query]: término de búsqueda opcional (nombre, NIT, etc.)
  ///
  /// Fallback: si API no está disponible, usa [_local.getAll]
  ///
  /// Retorna: [Future<List<ProveedorEntity>>]
  // ── Obtener lista de proveedores ──────────────────────────────────────────

  Future<List<ProveedorEntity>> getAll({String? query}) async {
```

#### Mejora 3: Documentar método getById

**Línea:** 47 (antes del método)

```dart
  /// Obtiene detalle de un proveedor específico desde la API.
  ///
  /// Parámetros:
  /// - [id]: identificador único del proveedor
  ///
  /// Fallback: si API falla, busca en [_local]
  ///
  /// Retorna: [ProveedorEntity?] o `null` si no existe
  // ── Obtener detalle de un proveedor ───────────────────────────────────────

  Future<ProveedorEntity?> getById(String id) async {
```

---

### 4. features/presentation/pages/proveedores_page.dart

**Ruta:** `lib/domain/proveedores/features/presentation/pages/proveedores_page.dart`

#### Mejora: Documentar clase ProveedoresPage

**Línea:** 9 (antes de `class ProveedoresPage`)

```dart
/// Pantalla principal de listado de proveedores.
///
/// Características:
/// - Se navega desde el menú principal
/// - Crea su propio [ProveedoresProvider]
/// - Incluye barra de búsqueda con filtro en tiempo real
/// - Lista scrollable de "tarjetas" de proveedores
/// - Manejo de estados: loading, loaded, error
///
/// Estructura visual:
/// - AppBar con botón atrás y título
/// - Campo de búsqueda (TextField con icono)
/// - Lista de proveedores (nombre, contacto, estado)
/// - Bottom navigation bar ([GlobalBottomNav])
class ProveedoresPage extends StatelessWidget {
```

#### Mejora 2: Documentar clase \_ProveedoresView

**Línea:** 25 (antes de `class _ProveedoresView`)

```dart
/// Widget estateless que envuelve el contenido principales de proveedores.
///
/// Estructura interna:
/// - _ProveedoresViewState: estado con TextField controller y colores
/// - Scaffold con SafeArea
/// - Header con título, búsqueda y ordenamiento
/// - Lista con scroll
/// - Bottom nav bar
class _ProveedoresView extends StatefulWidget {
```

---

## 📋 Resumen de cambios

| Módulo          | Archivos | Cambios recomendados                                                                               | Prioridad |
| :-------------- | :------- | :------------------------------------------------------------------------------------------------- | :-------- |
| **Producción**  | 7        | Documentar app_dependencies, app_shell, app_theme, app_colors, ProduccionProvider, ProduccionState | Alto      |
| **Terceros**    | 13       | Documentar entities, repository, usecases, states, providers, pages, API service                   | Alto      |
| **Proveedores** | 4        | Documentar entity, provider, API service, page                                                     | Medio     |
| **TOTAL**       | 24+      | ~80+ doc comments propuestos                                                                       | -         |

---

## 💡 Notas de implementación

1. **Formato:** Usar `///` para doc comments, incluyendo línea en blanco después de `///` para párrafos.
2. **Referencias cruzadas:** Usar `[NombreClase]` para referenciar otras clases (ej: `[TerceroEntity]`).
3. **Evitar redundancia:** No documentar si ya tiene documentación adecuada.
4. **Tono:** Profesional, claro, conciso. Incluir cuándo es pertinente ejemplos (`Uso: ...`) o referencias a métodos relacionados.
5. **Ubicación:** Siempre antes de la definición de clase/método, no después.

---

**Documento generado:** 4 de abril de 2026
