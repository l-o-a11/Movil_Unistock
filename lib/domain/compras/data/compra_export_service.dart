// Genera un reporte .xlsx del listado de Compras y abre el panel nativo de
// compartir (WhatsApp, correo, Drive, etc.), o de guardar en el celular.
//
// Estilo intermedio inspirado en el reporte de la web (xlsx-js-style):
// header rosado con texto blanco en negrita, filas alternadas y el estado
// (Activa/Anulada) en verde/rojo. No replica el 100% del detalle de la web
// (colores por cada estado posible, formato numérico avanzado, etc.) por las
// limitaciones de estilo del paquete `excel` en Flutter frente a JS.

import 'dart:io';

import 'package:excel/excel.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../domain/compra.dart';

class CompraExportService {
  // `excel` moderno usa ExcelColor, no String, para fontColorHex /
  // backgroundColorHex. Se precomputan acá para no crear objetos repetidos
  // dentro del loop de filas.
  static final ExcelColor _pinkColor = ExcelColor.fromHexString('#FF4FA3');
  static final ExcelColor _whiteColor = ExcelColor.fromHexString('#FFFFFF');
  static final ExcelColor _altRowColor = ExcelColor.fromHexString('#FFF3F9');
  static final ExcelColor _greenColor = ExcelColor.fromHexString('#2E7D32');
  static final ExcelColor _redColor = ExcelColor.fromHexString('#C62828');
  static final ExcelColor _textColor = ExcelColor.fromHexString('#1C1C1E');

  /// Genera el .xlsx a partir de [compras] y abre el panel de compartir.
  /// Lanza una excepción si el archivo no se pudo generar o guardar; la
  /// pantalla que llama decide cómo mostrar el error.
  Future<void> exportarYCompartir(List<Compra> compras) async {
    final excel = Excel.createExcel();
    final sheet = excel['Compras'];

    // Solo borrar el sheet por defecto si efectivamente existe, para no
    // romper si el paquete cambia el nombre por defecto en el futuro.
    if (excel.sheets.containsKey('Sheet1')) {
      excel.delete('Sheet1');
    }

    const headers = [
      'Factura',
      'Fecha',
      'Proveedor',
      'Total',
      'Estado',
      'Observaciones',
    ];

    final headerStyle = CellStyle(
      bold: true,
      fontColorHex: _whiteColor,
      backgroundColorHex: _pinkColor,
      horizontalAlign: HorizontalAlign.Center,
      verticalAlign: VerticalAlign.Center,
    );

    for (var col = 0; col < headers.length; col++) {
      sheet.updateCell(
        CellIndex.indexByColumnRow(columnIndex: col, rowIndex: 0),
        TextCellValue(headers[col]),
        cellStyle: headerStyle,
      );
    }

    // Estilos reutilizables por fila: par/impar × activa/anulada.
    // Evita instanciar CellStyle en cada celda cuando la lista es grande.
    final estilosDatos = <String, CellStyle>{};
    CellStyle estiloPara({
      required bool filaPar,
      required bool isEstadoCol,
      required bool anulada,
    }) {
      final key = '$filaPar-$isEstadoCol-$anulada';
      return estilosDatos.putIfAbsent(
        key,
        () => CellStyle(
          backgroundColorHex: filaPar ? _whiteColor : _altRowColor,
          bold: isEstadoCol,
          fontColorHex: isEstadoCol
              ? (anulada ? _redColor : _greenColor)
              : _textColor,
        ),
      );
    }

    for (var i = 0; i < compras.length; i++) {
      final compra = compras[i];
      final rowIndex = i + 1;
      final filaPar = i.isEven;

      final fecha = DateTime.tryParse(compra.fecha);
      final fechaTexto = fecha != null
          ? '${fecha.day.toString().padLeft(2, '0')}/${fecha.month.toString().padLeft(2, '0')}/${fecha.year}'
          : compra.fecha;

      final values = <CellValue>[
        TextCellValue(compra.numeroFactura),
        TextCellValue(fechaTexto),
        TextCellValue(compra.proveedorNombre ?? 'Sin resolver'),
        DoubleCellValue(compra.total),
        TextCellValue(compra.anulada ? 'Anulada' : 'Activa'),
        // Si `observaciones` es nullable en el modelo, esto evita el error
        // de tipos (TextCellValue espera String no nulo).
        TextCellValue(compra.observaciones ?? ''),
      ];

      for (var col = 0; col < values.length; col++) {
        final isEstadoCol = col == 4;
        sheet.updateCell(
          CellIndex.indexByColumnRow(columnIndex: col, rowIndex: rowIndex),
          values[col],
          cellStyle: estiloPara(
            filaPar: filaPar,
            isEstadoCol: isEstadoCol,
            anulada: compra.anulada,
          ),
        );
      }
    }

    for (var col = 0; col < headers.length; col++) {
      sheet.setColumnWidth(col, 22);
    }

    final bytes = excel.save();
    if (bytes == null) {
      throw Exception('No se pudo generar el archivo Excel');
    }

    final dir = await getTemporaryDirectory();
    await _limpiarReportesViejos(dir);

    final now = DateTime.now();
    final marcaTiempo =
        '${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}'
        '_${now.hour.toString().padLeft(2, '0')}${now.minute.toString().padLeft(2, '0')}';
    final file = File('${dir.path}/compras_$marcaTiempo.xlsx');
    await file.writeAsBytes(bytes, flush: true);

    await SharePlus.instance.share(
      ShareParams(
        files: [XFile(file.path)],
        text: 'Reporte de compras — Unistock',
      ),
    );
  }

  /// Borra reportes .xlsx generados en ejecuciones anteriores para no
  /// acumular archivos en el directorio temporal del dispositivo.
  Future<void> _limpiarReportesViejos(Directory dir) async {
    try {
      final entries = dir.listSync();
      for (final entry in entries) {
        if (entry is File &&
            entry.path.contains('compras_') &&
            entry.path.endsWith('.xlsx')) {
          await entry.delete();
        }
      }
    } catch (_) {
      // No es crítico: si falla la limpieza, seguimos con la exportación.
    }
  }
}
