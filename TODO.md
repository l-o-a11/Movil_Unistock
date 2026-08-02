# TODO: Corregir datos de Producción (mostrar datos reales de la BD)

## Objetivo

El módulo de Producción (y el Dashboard, que lee el mismo endpoint
`GET /api/produccion/ordenes`) debe mostrar los datos REALES de la base de
datos, no el mock local.

## Pasos

- [x] 1. Analizar el flujo de datos del módulo producción
     (Provider → UseCase → Repository → ApiService → API).

- [x] 2. `lib/domain/produccion/features/data/services/produccion_api_service.dart`
     - Usar `ApiConfig.baseUrl` como base (consistente con Compras/Insumos).
     - Agregar helpers robustos `_extractList()` / `_extractOne()` para
       distintos formatos de respuesta (`{data:[...]}`, `{data:{data:[...]}}`,
       `docs`, `results`, `ordenes`, etc.).
     - `getOrdenes()`: HTTP 200 → retornar datos REALES (incl. lista vacía);
       error HTTP no-200 → lanzar `ProduccionApiException` (la UI muestra el
       error real); solo error de RED → fallback al mock local (desarrollo).
     - `getOrdenDetail()`: mismo tratamiento; 404 → `null`.
     - `avanzarEstado()` y `confirmarEtapa()`: lanzan `ProduccionApiException`.

- [x] 3. `lib/domain/produccion/features/data/models/orden_model.dart`
     - Parseo defensivo de `detalles`, `historial` y `terceros`
       (usar `is List` en vez de `as List`) para que un payload válido
       nunca lance excepción y dispare el fallback mock.

- [x] 4. `lib/domain/produccion/features/data/models/orden_detail_model.dart`
     - Parseo defensivo de `detalles`, `historial`, `referencias`, `terceros`.

- [x] 5. `lib/domain/dashboard/data/dashboard_data_source.dart`
     - Usa `ApiConfig.baseUrl` en lugar de hardcode `http://10.0.2.2:3000/api`.
     - `_fetchList()` envuelto en try/catch para evitar que errores de red
       propaguen excepción.
     - Nuevo helper `_extractList()` que tolera múltiples formatos de respuesta
       (`[...]`, `{data:[...]}`, `{data:{data:[...]}}`, `docs`, `results`, `ordenes`).
     - Parseo defensivo de `historial` y `asignaciones` (usa `is List` en vez de
       `as List<dynamic>?`).

- [x] 6. Ejecutar `flutter analyze` y verificar compilación.
     - ✅ 0 errores, 0 warnings relacionados con los cambios.
     - Las 127 issues son info-level preexistentes (deprecated `withOpacity`, etc.).

- [x] 7. Quitar botón "Siguiente →" del detalle de producción (FlujoProcesoCard).
     - `flujo_proceso_card.dart`: solo queda el botón "Confirmar finalización ✓"
       para empleados. Gerente/Administrador/otros roles → la tarjeta no se
       muestra. Se eliminó `onAvanzar`, `isGerente`, `actionError` y el diálogo
       `_AvanzarEstadoDialog`.
     - `orden_detail_page.dart`: se eliminó el callback `onAvanzar` de
       `_DetailBody` y del `FlujoProcesoCard`.

## Archivos editados

- `lib/domain/produccion/features/data/services/produccion_api_service.dart`
- `lib/domain/produccion/features/data/models/orden_model.dart`
- `lib/domain/produccion/features/data/models/orden_detail_model.dart`
- `lib/domain/dashboard/data/dashboard_data_source.dart`
- `lib/domain/produccion/features/presentation/widgets/detail/flujo_proceso_card.dart`
- `lib/domain/produccion/features/presentation/pages/orden_detail_page.dart`
