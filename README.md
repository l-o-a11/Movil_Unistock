# movil_unistock

Aplicación Flutter con arquitectura orientada a feature dentro de la carpeta `lib/domain`.

## Estructura real del proyecto

```text
lib/
├── config/
├── core/
├── domain/
│   ├── auth/
│   ├── compras/
│   ├── dashboard/
│   ├── empleados/
│   ├── insumos/
│   ├── menu/
│   ├── produccion/
│   ├── products/
│   ├── product_categories/
│   ├── proveedores/
│   ├── roles/
│   ├── sedes/
│   ├── terceros/
│   ├── usuarios/
│   └── ...
├── shared/
├── main.dart
└── ...
```

## Arquitectura aplicada

Cada módulo funcional ya vive dentro de su carpeta en `lib/domain`, con subcarpetas como:

- `data` para servicios y repositorios.
- `domain` para entidades y contratos.
- `presentation` para pantallas, widgets y providers.


Las pantallas que requieren más composición se separan internamente en:

- `presentation/pages` para la entrada de la feature.
- `presentation/widgets` para componentes visuales reutilizables de esa feature.
- `presentation/providers` para el estado de pantalla.

La regla de tamaño del proyecto es estricta: ningún archivo Dart debe superar 300 líneas. Cuando una pantalla crece, se extraen sus widgets, diálogos y hojas de detalle dentro de la misma feature.

## Regla de trabajo

- No mezclar lógica de negocio con la app principal.
- Mantener cada feature dentro de su carpeta del dominio.
- Importar desde rutas reales del proyecto, preferiblemente desde `lib/domain/...`.
- Cuando una funcionalidad crezca, dividirla dentro de ese mismo módulo sin romper la estructura actual.
