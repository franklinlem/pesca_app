import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';
import 'package:pesca_app/features/sessions/models/fishing_session.dart';

class PdfReportService {
  static Future<void> generateAndShowPdf(FishingSession session) async {
    final pdf = pw.Document();

    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');
    final startDateStr = dateFormat.format(session.startTime);
    final endDateStr = session.endTime != null ? dateFormat.format(session.endTime!) : 'Em andamento';

    final List<pw.Widget> photoWidgets = [];
    for (var c in session.catches) {
      if (c.photoPath != null && File(c.photoPath!).existsSync()) {
        final imageBytes = await File(c.photoPath!).readAsBytes();
        final pdfImage = pw.MemoryImage(imageBytes);

        photoWidgets.add(
          pw.Container(
            margin: const pw.EdgeInsets.only(bottom: 12),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Container(
                  height: 180,
                  width: double.infinity,
                  child: pw.Image(pdfImage, fit: pw.BoxFit.cover),
                ),
                pw.SizedBox(height: 4),
                pw.Text(
                  '${c.species} - ${c.lengthCm} cm ${c.weightKg != null ? "(${c.weightKg} kg)" : ""} | ${c.isReleased ? "✅ Captura & Soltura" : "🎣 Retido"}',
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10),
                ),
                if (c.baitUsed != null)
                  pw.Text('Isca: ${c.baitUsed} | Técnica: ${c.technique ?? "Não informada"}',
                      style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700)),
              ],
            ),
          ),
        );
      }
    }

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return [
            pw.Header(
              level: 0,
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('Relatório de Pescaria — Diário de Pesca',
                      style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold, color: PdfColors.blue800)),
                  pw.Text(DateFormat('dd/MM/yyyy').format(DateTime.now()),
                      style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey600)),
                ],
              ),
            ),
            pw.SizedBox(height: 12),

            pw.Container(
              padding: const pw.EdgeInsets.all(12),
              decoration: pw.BoxDecoration(
                color: PdfColors.grey100,
                borderRadius: pw.BorderRadius.circular(8),
                border: pw.Border.all(color: PdfColors.grey300),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text('Local: ${session.locationName ?? "Local Não Especificado"}',
                      style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
                  pw.SizedBox(height: 4),
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text('Início: $startDateStr', style: const pw.TextStyle(fontSize: 10)),
                      pw.Text('Fim: $endDateStr', style: const pw.TextStyle(fontSize: 10)),
                    ],
                  ),
                  pw.SizedBox(height: 8),
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text('Total de Peixes: ${session.totalCatches}',
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.blue900)),
                      pw.Text('Capturados & Soltos: ${session.totalReleased} 🌿',
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.green800)),
                      pw.Text('Maior Peixe: ${session.maxLen} cm 🏆',
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.orange800)),
                    ],
                  ),
                ],
              ),
            ),
            pw.SizedBox(height: 16),

            if (session.weather != null) ...[
              pw.Text('Condições Climáticas Observadas', style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 6),
              pw.TableHelper.fromTextArray(
                headers: ['Clima', 'Vento', 'Condição da Água', 'Temperatura'],
                data: [
                  [
                    session.weather!.weather,
                    session.weather!.wind,
                    session.weather!.waterCondition,
                    session.weather!.temperatureC != null ? '${session.weather!.temperatureC}°C' : 'N/I',
                  ]
                ],
                headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.white),
                headerDecoration: const pw.BoxDecoration(color: PdfColors.blue700),
                cellStyle: const pw.TextStyle(fontSize: 10),
              ),
              pw.SizedBox(height: 16),
            ],

            pw.Text('Registro Detalhado das Capturas', style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 6),
            if (session.catches.isEmpty)
              pw.Text('Nenhuma captura registrada nesta sessão.', style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey600))
            else
              pw.TableHelper.fromTextArray(
                headers: ['Horário', 'Espécie', 'Comprimento', 'Peso', 'Isca / Técnica', 'Solto?'],
                data: session.catches.map((c) {
                  return [
                    DateFormat('HH:mm').format(c.timestamp),
                    c.species,
                    '${c.lengthCm} cm',
                    c.weightKg != null ? '${c.weightKg} kg' : '-',
                    '${c.baitUsed ?? "-"}\n(${c.technique ?? "-"})',
                    c.isReleased ? 'Sim 🟢' : 'Não 🔴',
                  ];
                }).toList(),
                headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.white),
                headerDecoration: const pw.BoxDecoration(color: PdfColors.teal800),
                cellStyle: const pw.TextStyle(fontSize: 9),
              ),
            pw.SizedBox(height: 20),

            if (photoWidgets.isNotEmpty) ...[
              pw.Text('Galeria de Fotografias', style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 10),
              ...photoWidgets,
            ],
          ];
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
      name: 'Pescaria_${session.locationName ?? "Local"}_${DateFormat('dd-MM-yyyy').format(session.startTime)}.pdf',
    );
  }
}
