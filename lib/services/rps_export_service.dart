import 'dart:io';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:url_launcher/url_launcher.dart';
import '../core/utils.dart';
import '../models/loan.dart';

class RpsExportService {
  /// Generates a PDF Repayment Schedule (RPS) statement document as byte data.
  static Future<Uint8List> generatePdfBytes({
    required Loan loan,
    required List<RepaymentDetail> schedule,
    required String userName,
    String? orgName,
  }) async {
    final pdf = pw.Document();

    final totalInst = schedule.fold<num>(0, (sum, item) => sum + item.instAmt);
    final totalPrincipal = schedule.fold<num>(0, (sum, item) => sum + item.principal);
    final totalInterest = schedule.fold<num>(0, (sum, item) => sum + item.interest);

    final tableHeaders = [
      'Inst #',
      'Due Date',
      'Opening',
      'Principal',
      'Interest',
      'EMI',
      'Closing',
      'Status'
    ];

    final tableData = schedule.map((item) {
      return [
        item.instlNum.toString(),
        formatDate(item.dueDate),
        formatMoneyNumeric(item.openingPrincipal, round: true),
        formatMoneyNumeric(item.principal, round: true),
        formatMoneyNumeric(item.interest, round: true),
        formatMoneyNumeric(item.instAmt, round: true),
        formatMoneyNumeric(item.closingPrincipal, round: true),
        item.isOverdue ? 'OVERDUE' : 'SCHEDULED',
      ];
    }).toList();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        header: (pw.Context context) {
          return pw.Column(
            children: [
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        'MADURAI FINANCE',
                        style: pw.TextStyle(
                          fontSize: 22,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColor.fromHex('#0B192C'),
                        ),
                      ),
                      pw.SizedBox(height: 2),
                      pw.Text(
                        'Official Repayment Schedule (RPS)',
                        style: pw.TextStyle(
                          fontSize: 11,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColor.fromHex('#C9A227'),
                        ),
                      ),
                    ],
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Text(
                        'Loan ID: ${loan.pkLoanId}',
                        style: pw.TextStyle(
                          fontSize: 13,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColor.fromHex('#0B192C'),
                        ),
                      ),
                      pw.SizedBox(height: 2),
                      pw.Text(
                        'Statement Date: ${formatDate(DateTime.now().toIso8601String())}',
                        style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700),
                      ),
                    ],
                  ),
                ],
              ),
              pw.SizedBox(height: 8),
              pw.Divider(color: PdfColor.fromHex('#0B192C'), thickness: 2),
              pw.SizedBox(height: 10),
            ],
          );
        },
        footer: (pw.Context context) {
          return pw.Column(
            children: [
              pw.Divider(color: PdfColors.grey300),
              pw.SizedBox(height: 6),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    'Madurai Finance App — Official System-Generated RPS Statement',
                    style: const pw.TextStyle(fontSize: 8.5, color: PdfColors.grey600),
                  ),
                  pw.Text(
                    'Page ${context.pageNumber} of ${context.pagesCount}',
                    style: const pw.TextStyle(fontSize: 8.5, color: PdfColors.grey600),
                  ),
                ],
              ),
            ],
          );
        },
        build: (pw.Context context) {
          return [
            // Metadata Card Box
            pw.Container(
              padding: const pw.EdgeInsets.all(12),
              decoration: pw.BoxDecoration(
                color: PdfColor.fromHex('#F7F5EF'),
                borderRadius: pw.BorderRadius.circular(8),
                border: pw.Border.all(color: PdfColor.fromHex('#0B192C'), width: 0.5),
              ),
              child: pw.Column(
                children: [
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      _pdfMetaPair('Borrower Name:', userName),
                      _pdfMetaPair('Loan Amount:', formatMoneyNumeric(loan.loanAmount, round: true)),
                    ],
                  ),
                  pw.SizedBox(height: 5),
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      _pdfMetaPair('Interest Rate:', '${loan.interestRate}% p.a.'),
                      _pdfMetaPair('Tenure:', '${loan.tenureMonths} Months'),
                    ],
                  ),
                  pw.SizedBox(height: 5),
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      _pdfMetaPair(
                        'Disbursement Date:',
                        formatDate(loan.disbursementDate ?? loan.approvalDate ?? loan.applicationDate),
                      ),
                      _pdfMetaPair('Organization:', orgName ?? 'Madurai Finance'),
                    ],
                  ),
                ],
              ),
            ),
            pw.SizedBox(height: 14),

            pw.Text(
              'Installment Repayment Table',
              style: pw.TextStyle(
                fontSize: 13,
                fontWeight: pw.FontWeight.bold,
                color: PdfColor.fromHex('#0B192C'),
              ),
            ),
            pw.SizedBox(height: 8),

            // Main Table View
            pw.TableHelper.fromTextArray(
              headers: tableHeaders,
              data: tableData,
              border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
              headerStyle: const pw.TextStyle(
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.white,
                fontSize: 9,
              ),
              headerDecoration: pw.BoxDecoration(color: PdfColor.fromHex('#0B192C')),
              cellStyle: const pw.TextStyle(fontSize: 8.5),
              cellAlignment: pw.Alignment.centerLeft,
              cellAlignments: {
                0: pw.Alignment.center,
                1: pw.Alignment.centerLeft,
                2: pw.Alignment.centerRight,
                3: pw.Alignment.centerRight,
                4: pw.Alignment.centerRight,
                5: pw.Alignment.centerRight,
                6: pw.Alignment.centerRight,
                7: pw.Alignment.center,
              },
              oddRowDecoration: pw.BoxDecoration(
                color: PdfColor.fromHex('#F9F9F8'),
              ),
              cellPadding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 5),
            ),

            pw.SizedBox(height: 12),

            // Summary Totals
            pw.Container(
              padding: const pw.EdgeInsets.all(10),
              decoration: pw.BoxDecoration(
                color: PdfColor.fromHex('#0B192C'),
                borderRadius: pw.BorderRadius.circular(6),
              ),
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    'TOTAL REPAYABLE: ${formatMoneyNumeric(totalInst, round: true)}',
                    style: const pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.white, fontSize: 10),
                  ),
                  pw.Text(
                    'Principal: ${formatMoneyNumeric(totalPrincipal, round: true)}  |  Interest: ${formatMoneyNumeric(totalInterest, round: true)}',
                    style: pw.TextStyle(color: PdfColor.fromHex('#C9A227'), fontSize: 9.5, fontWeight: pw.FontWeight.bold),
                  ),
                ],
              ),
            ),
          ];
        },
      ),
    );

    return pdf.save();
  }

  static pw.Widget _pdfMetaPair(String label, String value) {
    return pw.Row(
      children: [
        pw.Text(label, style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700)),
        pw.SizedBox(width: 4),
        pw.Text(
          value,
          style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold, color: PdfColor.fromHex('#0B192C')),
        ),
      ],
    );
  }

  /// Saves PDF RPS statement to app temp directory and opens Print / Share dialog.
  static Future<File> saveAndDownloadPdf({
    required Loan loan,
    required List<RepaymentDetail> schedule,
    required String userName,
    String? orgName,
  }) async {
    final pdfBytes = await generatePdfBytes(
      loan: loan,
      schedule: schedule,
      userName: userName,
      orgName: orgName,
    );

    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/RPS_${loan.pkLoanId}.pdf');
    await file.writeAsBytes(pdfBytes, flush: true);

    await Printing.sharePdf(bytes: pdfBytes, filename: 'RPS_${loan.pkLoanId}.pdf');

    return file;
  }

  /// Generates a complete HTML Repayment Schedule (RPS) statement document.
  static String generateHtmlRps({
    required Loan loan,
    required List<RepaymentDetail> schedule,
    required String userName,
    String? orgName,
  }) {
    final totalInst = schedule.fold<num>(0, (sum, item) => sum + item.instAmt);
    final totalPrincipal = schedule.fold<num>(0, (sum, item) => sum + item.principal);
    final totalInterest = schedule.fold<num>(0, (sum, item) => sum + item.interest);

    final rowsHtml = schedule.map((item) {
      final isOverdue = item.isOverdue;
      final statusTag = isOverdue
          ? '<span style="color:#b3261e; font-weight:bold;">OVERDUE</span>'
          : '<span style="color:#1e7b4d; font-weight:bold;">SCHEDULED</span>';
      return '''
      <tr>
        <td style="padding:10px; border-bottom:1px solid #eee; text-align:center;">${item.instlNum}</td>
        <td style="padding:10px; border-bottom:1px solid #eee;">${formatDate(item.dueDate)}</td>
        <td style="padding:10px; border-bottom:1px solid #eee; text-align:right;">${formatMoney(item.openingPrincipal)}</td>
        <td style="padding:10px; border-bottom:1px solid #eee; text-align:right; color:#1D4ED8; font-weight:600;">${formatMoney(item.principal)}</td>
        <td style="padding:10px; border-bottom:1px solid #eee; text-align:right; color:#b07a00;">${formatMoney(item.interest)}</td>
        <td style="padding:10px; border-bottom:1px solid #eee; text-align:right; font-weight:bold; color:#0B192C;">${formatMoney(item.instAmt)}</td>
        <td style="padding:10px; border-bottom:1px solid #eee; text-align:right;">${formatMoney(item.closingPrincipal)}</td>
        <td style="padding:10px; border-bottom:1px solid #eee; text-align:center;">$statusTag</td>
      </tr>
      ''';
    }).join('\n');

    return '''
<!DOCTYPE html>
<html>
<head>
  <meta charset="utf-8">
  <title>Repayment Schedule (RPS) - ${loan.pkLoanId}</title>
  <style>
    body { font-family: 'Segoe UI', Roboto, Helvetica, Arial, sans-serif; color: #1b2a25; margin: 0; padding: 24px; background: #f7f5ef; }
    .container { max-width: 850px; margin: 0 auto; background: #ffffff; padding: 32px; border-radius: 16px; box-shadow: 0 4px 20px rgba(0,0,0,0.08); }
    .header { border-bottom: 3px solid #0B192C; padding-bottom: 20px; margin-bottom: 24px; display: flex; justify-content: space-between; align-items: center; }
    .brand { font-size: 24px; font-weight: 800; color: #0B192C; letter-spacing: 0.5px; }
    .tagline { font-size: 13px; color: #c9a227; font-weight: 600; text-transform: uppercase; }
    .meta-grid { display: grid; grid-template-columns: repeat(2, 1fr); gap: 16px; background: #f7f5ef; padding: 20px; border-radius: 12px; margin-bottom: 28px; }
    .meta-item { display: flex; justify-content: space-between; font-size: 14px; }
    .meta-label { color: #6b776f; font-weight: 500; }
    .meta-value { font-weight: 700; color: #0B192C; }
    table { width: 100%; border-collapse: collapse; margin-top: 10px; font-size: 13.5px; }
    th { background: #0B192C; color: #ffffff; padding: 12px 10px; font-weight: 600; text-align: left; }
    th.num { text-align: right; }
    th.center { text-align: center; }
    tfoot tr { background: #f7f5ef; font-weight: bold; }
    tfoot td { padding: 12px 10px; border-top: 2px solid #0B192C; }
    .footer { margin-top: 30px; text-align: center; font-size: 12px; color: #6b776f; border-top: 1px solid #eee; padding-top: 16px; }
  </style>
</head>
<body>
  <div class="container">
    <div class="header">
      <div>
        <div class="brand">MADURAI FINANCE</div>
        <div class="tagline">Official Repayment Schedule (RPS)</div>
      </div>
      <div style="text-align: right;">
        <div style="font-size: 14px; font-weight: bold; color: #0B192C;">Loan ID: ${loan.pkLoanId}</div>
        <div style="font-size: 12px; color: #6b776f;">Issued to: $userName</div>
      </div>
    </div>

    <div class="meta-grid">
      <div class="meta-item"><span class="meta-label">Borrower Name:</span><span class="meta-value">$userName</span></div>
      <div class="meta-item"><span class="meta-label">Loan Amount:</span><span class="meta-value">${formatMoney(loan.loanAmount)}</span></div>
      <div class="meta-item"><span class="meta-label">Interest Rate:</span><span class="meta-value">${loan.interestRate}% p.a.</span></div>
      <div class="meta-item"><span class="meta-label">Tenure:</span><span class="meta-value">${loan.tenureMonths} Months</span></div>
      <div class="meta-item"><span class="meta-label">Disbursement Date:</span><span class="meta-value">${formatDate(loan.disbursementDate ?? loan.approvalDate ?? loan.applicationDate)}</span></div>
      <div class="meta-item"><span class="meta-label">Organization:</span><span class="meta-value">${orgName ?? 'Madurai Finance'}</span></div>
    </div>

    <h3 style="color:#0B192C; margin-bottom:12px;">Installment Breakdown</h3>
    <table>
      <thead>
        <tr>
          <th class="center">Inst #</th>
          <th>Due Date</th>
          <th class="num">Opening</th>
          <th class="num">Principal</th>
          <th class="num">Interest</th>
          <th class="num">EMI Amount</th>
          <th class="num">Closing</th>
          <th class="center">Status</th>
        </tr>
      </thead>
      <tbody>
        $rowsHtml
      </tbody>
      <tfoot>
        <tr>
          <td colspan="3" style="text-align:right;">TOTAL:</td>
          <td style="text-align:right; color:#1D4ED8;">${formatMoney(totalPrincipal)}</td>
          <td style="text-align:right; color:#b07a00;">${formatMoney(totalInterest)}</td>
          <td style="text-align:right; color:#0B192C;">${formatMoney(totalInst)}</td>
          <td colspan="2"></td>
        </tr>
      </tfoot>
    </table>

    <div class="footer">
      This is a system generated Repayment Schedule (RPS) statement from Madurai Finance.<br/>
      For queries, contact support at your registered branch.
    </div>
  </div>
</body>
</html>
''';
  }

  /// Formats RPS into clean text format for quick copying.
  static String generateTextRps({
    required Loan loan,
    required List<RepaymentDetail> schedule,
    required String userName,
  }) {
    final sb = StringBuffer();
    sb.writeln('==================================================');
    sb.writeln('             MADURAI FINANCE - RPS               ');
    sb.writeln('          Official Repayment Schedule             ');
    sb.writeln('==================================================');
    sb.writeln('Loan ID          : ${loan.pkLoanId}');
    sb.writeln('Borrower Name    : $userName');
    sb.writeln('Loan Amount      : ${formatMoney(loan.loanAmount)}');
    sb.writeln('Interest Rate    : ${loan.interestRate}% p.a.');
    sb.writeln('Tenure           : ${loan.tenureMonths} Months');
    sb.writeln('Disbursed On     : ${formatDate(loan.disbursementDate ?? loan.applicationDate)}');
    sb.writeln('--------------------------------------------------');
    sb.writeln('No.  Due Date     Principal    Interest    EMI Amount');
    sb.writeln('--------------------------------------------------');
    for (final item in schedule) {
      final inst = item.instlNum.toString().padRight(4);
      final date = formatDate(item.dueDate).padRight(12);
      final prin = formatMoney(item.principal).padRight(12);
      final int = formatMoney(item.interest).padRight(11);
      final emi = formatMoney(item.instAmt);
      sb.writeln('$inst $date $prin $int $emi');
    }
    sb.writeln('--------------------------------------------------');
    sb.writeln('Generated via Madurai Finance Mobile App');
    return sb.toString();
  }

  /// Saves HTML RPS document to app temp directory and opens it.
  static Future<File> saveAndOpenRps({
    required Loan loan,
    required List<RepaymentDetail> schedule,
    required String userName,
    String? orgName,
  }) async {
    final html = generateHtmlRps(loan: loan, schedule: schedule, userName: userName, orgName: orgName);
    final dir = await getTemporaryDirectory();

    final file = File('${dir.path}/RPS_${loan.pkLoanId}.html');
    await file.writeAsString(html);

    final text = generateTextRps(loan: loan, schedule: schedule, userName: userName);
    await Clipboard.setData(ClipboardData(text: text));

    try {
      final uri = Uri.file(file.path);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } catch (_) {}
    return file;
  }

  /// Copies text RPS to clipboard.
  static Future<void> copyRpsToClipboard({
    required Loan loan,
    required List<RepaymentDetail> schedule,
    required String userName,
  }) async {
    final text = generateTextRps(loan: loan, schedule: schedule, userName: userName);
    await Clipboard.setData(ClipboardData(text: text));
  }
}
