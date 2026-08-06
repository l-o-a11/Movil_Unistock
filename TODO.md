# TODO - Dashboard Resumen Global y Control de Insumos

- [x] 1. Editar `summary_card.dart`: aclarar etiquetas del Resumen Global manteniendo los números en su posición original.
- [x] 2. Editar `progress_section.dart`: dar más espacio a los números en Control de Insumos (label flexible + número con FittedBox para crecer a 5 cifras).
- [x] 3. Corregir `dashboard_data_source.dart`: stock = sumar SOLO campo `stock`; total insumos = filtrar por `estado: true`; insumosSinStock basado en `stock == 0`.
- [x] 4. Ejecutar `flutter analyze` para verificar.
