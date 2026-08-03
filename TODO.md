# TODO — Corrección del buscador de terceros

## Pasos del plan aprobado

- [x] 1. Análisis y diagnóstico (causa raíz identificada)
- [x] 2. `terceros_state.dart` — guardar lista completa + getter `tercerosFiltrados` (filtro local)
- [x] 3. `terceros_provider.dart` — cargar sin query; `updateSearch` filtra localmente sin llamadas HTTP por tecla
- [x] 4. `terceros_page.dart` — usar `tercerosFiltrados` y diferenciar mensajes de lista vacía vs sin resultados
- [x] 5. `terceros_embedded_list.dart` — usar `tercerosFiltrados` y diferenciar mensajes
- [x] 6. `produccion_page.dart` — el buscador delega al proveedor correcto según pestaña activa; sincronizar búsqueda al cambiar de pestaña y refrescar la barra
- [x] 7. Validar con `flutter analyze` (y opcionalmente `flutter run`)
