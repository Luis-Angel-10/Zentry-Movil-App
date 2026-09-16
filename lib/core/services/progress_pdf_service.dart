import 'dart:io';

import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import 'package:Zentry/core/models/achievement.dart';

class ProgressPdfService {
  const ProgressPdfService._();

  static Future<void> exportAndOpen({
    required String userDisplayName,
    required int points,
    required int streakCount,
    required int bestStreak,
    required List<AchievementDef> unlockedAchievements,
    required String Function(String achievementId) titleFor,
    required String docTitle,
    required String generatedOnLabel,
    required String rankLabel,
    required String pointsLabel,
    required String achievementsTitle,
    required String noAchievementsLabel,
    required String streakLabel,
  }) async {
    final rank = currentRank(points);
    final doc = pw.Document();

    doc.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                'Zentry',
                style: pw.TextStyle(
                  fontSize: 28,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColor.fromInt(0xFF8B5CF6),
                ),
              ),
              pw.SizedBox(height: 4),
              pw.Text(docTitle, style: const pw.TextStyle(fontSize: 18)),
              pw.SizedBox(height: 2),
              pw.Text(
                generatedOnLabel,
                style: const pw.TextStyle(
                  fontSize: 10,
                  color: PdfColors.grey700,
                ),
              ),
              pw.SizedBox(height: 20),
              pw.Text(
                userDisplayName,
                style: pw.TextStyle(
                  fontSize: 16,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 12),
              pw.Container(
                padding: const pw.EdgeInsets.all(12),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: PdfColors.grey400),
                  borderRadius: pw.BorderRadius.circular(8),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(rankLabel),
                    pw.SizedBox(height: 4),
                    pw.Text(pointsLabel),
                    pw.SizedBox(height: 4),
                    pw.Text(streakLabel),
                  ],
                ),
              ),
              pw.SizedBox(height: 20),
              pw.Text(
                achievementsTitle,
                style: pw.TextStyle(
                  fontSize: 14,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 8),
              if (unlockedAchievements.isEmpty)
                pw.Text(
                  noAchievementsLabel,
                  style: const pw.TextStyle(color: PdfColors.grey700),
                )
              else
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: unlockedAchievements
                      .map(
                        (a) => pw.Padding(
                          padding: const pw.EdgeInsets.only(bottom: 4),
                          child: pw.Text(
                            '• ${titleFor(a.id)} (+${a.points} pts)',
                          ),
                        ),
                      )
                      .toList(),
                ),
            ],
          );
        },
      ),
    );

    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/zentry_progreso_${rank.id}.pdf');
    await file.writeAsBytes(await doc.save());
    await OpenFilex.open(file.path);
  }
}
