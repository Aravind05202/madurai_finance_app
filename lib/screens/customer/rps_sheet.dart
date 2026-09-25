import 'package:flutter/material.dart';
import '../../core/constants.dart';
import '../../core/utils.dart';
import '../../models/loan.dart';
import '../../services/rps_export_service.dart';
import '../widgets/primary_button.dart';

class RpsSheet extends StatefulWidget {
  final Loan loan;
  final List<RepaymentDetail> schedule;
  final String userName;
  final String? orgName;

  const RpsSheet({
    super.key,
    required this.loan,
    required this.schedule,
    required this.userName,
    this.orgName,
  });

  static void show(
    BuildContext context, {
    required Loan loan,
    required List<RepaymentDetail> schedule,
    required String userName,
    String? orgName,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => RpsSheet(
        loan: loan,
        schedule: schedule,
        userName: userName,
        orgName: orgName,
      ),
    );
  }

  @override
  State<RpsSheet> createState() => _RpsSheetState();
}

class _RpsSheetState extends State<RpsSheet> {
  bool _downloadingPdf = false;
  bool _downloadingHtml = false;
  bool _isTableView = true; // Default to Table View as requested

  num get _totalEmi => widget.schedule.fold<num>(0, (sum, item) => sum + item.instAmt);
  num get _totalPrincipal => widget.schedule.fold<num>(0, (sum, item) => sum + item.principal);
  num get _totalInterest => widget.schedule.fold<num>(0, (sum, item) => sum + item.interest);

  Future<void> _downloadPdfRps() async {
    setState(() => _downloadingPdf = true);
    try {
      final file = await RpsExportService.saveAndDownloadPdf(
        loan: widget.loan,
        schedule: widget.schedule,
        userName: widget.userName,
        orgName: widget.orgName,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.picture_as_pdf, color: Colors.white, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'RPS PDF Statement saved to ${file.path.split('/').last}!',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
            backgroundColor: AppColors.deepGreen,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving RPS PDF: $e'),
            backgroundColor: AppColors.danger,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _downloadingPdf = false);
    }
  }

  Future<void> _downloadHtmlRps() async {
    setState(() => _downloadingHtml = true);
    try {
      final file = await RpsExportService.saveAndOpenRps(
        loan: widget.loan,
        schedule: widget.schedule,
        userName: widget.userName,
        orgName: widget.orgName,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('RPS HTML statement saved as ${file.path.split('/').last}!\nText copied to clipboard.'),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving HTML RPS: $e'),
            backgroundColor: AppColors.danger,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _downloadingHtml = false);
    }
  }

  Future<void> _copyRps() async {
    await RpsExportService.copyRpsToClipboard(
      loan: widget.loan,
      schedule: widget.schedule,
      userName: widget.userName,
    );
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Repayment Schedule copied to clipboard!'),
          backgroundColor: AppColors.deepGreen,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.92,
      maxChildSize: 0.96,
      minChildSize: 0.5,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: AppColors.bg,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              // Sheet Handle & Header
              Container(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
                decoration: const BoxDecoration(
                  color: AppColors.deepGreen,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                ),
                child: Column(
                  children: [
                    Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.white30,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: AppColors.gold,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(Icons.table_chart_rounded, color: AppColors.deepGreen, size: 22),
                            ),
                            const SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Repayment Schedule (RPS)',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 17,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                Text(
                                  'Loan ID: ${widget.loan.pkLoanId}',
                                  style: const TextStyle(color: AppColors.goldLight, fontSize: 12.5),
                                ),
                              ],
                            ),
                          ],
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, color: Colors.white70),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Main Body Content
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(18),
                  children: [
                    // Summary Metric Card
                    Card(
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: BorderSide(color: AppColors.deepGreen.withValues(alpha: 0.1)),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                _metricTile('Total Loan Amount', formatMoney(widget.loan.loanAmount), AppColors.deepGreen),
                                _metricTile('Total Payable', formatMoney(_totalEmi), AppColors.gold),
                              ],
                            ),
                            const Divider(height: 24),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                _metricTile('Principal', formatMoney(_totalPrincipal), AppColors.green),
                                _metricTile('Interest (${widget.loan.interestRate}%)', formatMoney(_totalInterest), AppColors.warning),
                                _metricTile('Tenure', '${widget.loan.tenureMonths} Mos', AppColors.textDark),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Primary Download as PDF Action Button Row
                    Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child: PrimaryButton(
                            label: 'Download PDF Statement',
                            icon: Icons.picture_as_pdf_rounded,
                            onPressed: _downloadPdfRps,
                            loading: _downloadingPdf,
                            color: AppColors.deepGreen,
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton.filledTonal(
                          style: IconButton.styleFrom(
                            backgroundColor: AppColors.deepGreen.withValues(alpha: 0.1),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            minimumSize: const Size(48, 50),
                          ),
                          onPressed: _copyRps,
                          icon: const Icon(Icons.copy, color: AppColors.deepGreen, size: 20),
                          tooltip: 'Copy Text Statement',
                        ),
                        const SizedBox(width: 6),
                        IconButton.filledTonal(
                          style: IconButton.styleFrom(
                            backgroundColor: AppColors.gold.withValues(alpha: 0.15),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            minimumSize: const Size(48, 50),
                          ),
                          onPressed: _downloadingHtml ? null : _downloadHtmlRps,
                          icon: _downloadingHtml
                              ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                              : const Icon(Icons.html_rounded, color: AppColors.deepGreen, size: 22),
                          tooltip: 'Open HTML Statement',
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // View Mode Switcher Header (Table View vs Card View)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Schedule Breakdown',
                          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16, color: AppColors.textDark),
                        ),
                        Container(
                          padding: const EdgeInsets.all(3),
                          decoration: BoxDecoration(
                            color: AppColors.deepGreen.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            children: [
                              _viewToggleButton(
                                label: 'Table View',
                                icon: Icons.table_chart_rounded,
                                isSelected: _isTableView,
                                onTap: () => setState(() => _isTableView = true),
                              ),
                              _viewToggleButton(
                                label: 'Cards',
                                icon: Icons.view_agenda_rounded,
                                isSelected: !_isTableView,
                                onTap: () => setState(() => _isTableView = false),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Display Selected View (Table View or Card View)
                    if (_isTableView) _buildRpsTableView() else _buildRpsCardView(),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// Builds a formatted, interactive Table View for the RPS Installment details.
  Widget _buildRpsTableView() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.deepGreen.withValues(alpha: 0.12)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            headingRowColor: WidgetStateProperty.all(AppColors.deepGreen),
            headingRowHeight: 44,
            dataRowMaxHeight: 48,
            dataRowMinHeight: 42,
            columnSpacing: 18,
            horizontalMargin: 16,
            dividerThickness: 1,
            columns: const [
              DataColumn(
                label: Text(
                  'Inst #',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 12.5),
                ),
                numeric: true,
              ),
              DataColumn(
                label: Text(
                  'Due Date',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 12.5),
                ),
              ),
              DataColumn(
                label: Text(
                  'Opening Bal',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 12.5),
                ),
                numeric: true,
              ),
              DataColumn(
                label: Text(
                  'Principal',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 12.5),
                ),
                numeric: true,
              ),
              DataColumn(
                label: Text(
                  'Interest',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 12.5),
                ),
                numeric: true,
              ),
              DataColumn(
                label: Text(
                  'EMI Amount',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 12.5),
                ),
                numeric: true,
              ),
              DataColumn(
                label: Text(
                  'Closing Bal',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 12.5),
                ),
                numeric: true,
              ),
              DataColumn(
                label: Text(
                  'Status',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 12.5),
                ),
              ),
            ],
            rows: [
              ...widget.schedule.asMap().entries.map((entry) {
                final idx = entry.key;
                final item = entry.value;
                final isOverdue = item.isOverdue;
                final isEven = idx % 2 == 0;

                return DataRow(
                  color: WidgetStateProperty.all(
                    isOverdue
                        ? AppColors.danger.withValues(alpha: 0.05)
                        : (isEven ? Colors.white : AppColors.bg.withValues(alpha: 0.6)),
                  ),
                  cells: [
                    DataCell(
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: isOverdue ? AppColors.danger.withValues(alpha: 0.12) : AppColors.deepGreen.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          '#${item.instlNum}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                            color: isOverdue ? AppColors.danger : AppColors.deepGreen,
                          ),
                        ),
                      ),
                    ),
                    DataCell(Text(
                      formatDate(item.dueDate),
                      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12.5),
                    )),
                    DataCell(Text(formatMoney(item.openingPrincipal), style: const TextStyle(fontSize: 12))),
                    DataCell(Text(
                      formatMoney(item.principal),
                      style: const TextStyle(color: AppColors.green, fontWeight: FontWeight.w600, fontSize: 12),
                    )),
                    DataCell(Text(
                      formatMoney(item.interest),
                      style: const TextStyle(color: AppColors.warning, fontWeight: FontWeight.w600, fontSize: 12),
                    )),
                    DataCell(Text(
                      formatMoney(item.instAmt),
                      style: const TextStyle(color: AppColors.deepGreen, fontWeight: FontWeight.w800, fontSize: 13),
                    )),
                    DataCell(Text(formatMoney(item.closingPrincipal), style: const TextStyle(fontSize: 12))),
                    DataCell(
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: isOverdue ? AppColors.danger.withValues(alpha: 0.12) : AppColors.success.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          isOverdue ? 'OVERDUE' : 'SCHEDULED',
                          style: TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w700,
                            color: isOverdue ? AppColors.danger : AppColors.success,
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              }),
              // Table Footer Summary Row
              DataRow(
                color: WidgetStateProperty.all(AppColors.deepGreen.withValues(alpha: 0.08)),
                cells: [
                  const DataCell(Text('TOTAL', style: TextStyle(fontWeight: FontWeight.w900, color: AppColors.deepGreen))),
                  const DataCell(Text('')),
                  const DataCell(Text('')),
                  DataCell(Text(formatMoney(_totalPrincipal), style: const TextStyle(fontWeight: FontWeight.w800, color: AppColors.green, fontSize: 12.5))),
                  DataCell(Text(formatMoney(_totalInterest), style: const TextStyle(fontWeight: FontWeight.w800, color: AppColors.warning, fontSize: 12.5))),
                  DataCell(Text(formatMoney(_totalEmi), style: const TextStyle(fontWeight: FontWeight.w900, color: AppColors.deepGreen, fontSize: 13.5))),
                  const DataCell(Text('')),
                  const DataCell(Text('')),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Builds Card View as an alternative option.
  Widget _buildRpsCardView() {
    return Column(
      children: widget.schedule.map((item) {
        final isOverdue = item.isOverdue;
        return Card(
          elevation: 0,
          margin: const EdgeInsets.only(bottom: 10),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
            side: BorderSide(
              color: isOverdue ? AppColors.danger.withValues(alpha: 0.3) : AppColors.deepGreen.withValues(alpha: 0.08),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: isOverdue ? AppColors.danger.withValues(alpha: 0.12) : AppColors.deepGreen.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'Inst #${item.instlNum}',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 12.5,
                              color: isOverdue ? AppColors.danger : AppColors.deepGreen,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          'Due: ${formatDate(item.dueDate)}',
                          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13.5),
                        ),
                      ],
                    ),
                    Text(
                      formatMoney(item.instAmt),
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                        color: AppColors.deepGreen,
                      ),
                    ),
                  ],
                ),
                const Divider(height: 18),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _subStat('Opening Bal', formatMoney(item.openingPrincipal)),
                    _subStat('Principal', formatMoney(item.principal)),
                    _subStat('Interest', formatMoney(item.interest)),
                    _subStat('Closing Bal', formatMoney(item.closingPrincipal)),
                  ],
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _viewToggleButton({
    required String label,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.deepGreen : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(icon, size: 15, color: isSelected ? Colors.white : AppColors.textMuted),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected ? Colors.white : AppColors.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _metricTile(String label, String value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: AppColors.textMuted, fontSize: 12)),
        const SizedBox(height: 2),
        Text(value, style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: color)),
      ],
    );
  }

  Widget _subStat(String label, String val) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: AppColors.textMuted, fontSize: 11)),
        const SizedBox(height: 2),
        Text(val, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12.5)),
      ],
    );
  }
}
