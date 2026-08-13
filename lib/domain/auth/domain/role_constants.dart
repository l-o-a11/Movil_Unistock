// lib/domain/auth/domain/role_constants.dart
//
// Catálogo único de nombres de rol y helpers de comparación.
//
// Los nombres de rol provienen del backend (`rolNombre` en el usuario
// autenticado). En lugar de repetir los strings ('gerente', 'administrador',
// 'empleado') en cada estado/modelo, se centralizan aquí en una única
// fuente de verdad para evitar datos quemados dispersos.

/// Nombre del rol "Administrador" tal como lo devuelve el backend.
const String rolAdministrador = 'administrador';

/// Nombre del rol "Gerente" tal como lo devuelve el backend.
const String rolGerente = 'gerente';

/// Nombre del rol "Empleado" tal como lo devuelve el backend.
const String rolEmpleado = 'empleado';

/// Normaliza un nombre de rol (minúsculas, sin espacios) para comparar.
String _normalizarRol(String? rol) => (rol ?? '').trim().toLowerCase();

/// Retorna `true` si [rol] corresponde al rol Administrador.
bool esAdministrador(String? rol) => _normalizarRol(rol) == rolAdministrador;

/// Retorna `true` si [rol] corresponde al rol Gerente.
bool esGerente(String? rol) => _normalizarRol(rol) == rolGerente;

/// Retorna `true` si [rol] corresponde al rol Empleado.
bool esEmpleado(String? rol) => _normalizarRol(rol) == rolEmpleado;

/// Retorna `true` si [rol] es un rol de administración (Gerente o
/// Administrador). Se usa para decidir si el usuario ve todas las órdenes.
bool esRolAdministrativo(String? rol) => esGerente(rol) || esAdministrador(rol);
