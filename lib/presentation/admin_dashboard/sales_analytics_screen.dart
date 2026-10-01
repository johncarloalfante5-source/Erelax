import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../core/sales_analytics_service.dart';
import '../../theme/app_theme.dart';

class SalesAnalyticsScreen extends StatefulWidget {
  const SalesAnalyticsScreen({super.key});

  @override
  State<SalesAnalyticsScreen> createState() => SalesAnalyticsScreenState();
}

class SalesAnalyticsScreenState extends State<SalesAnalyticsScreen> {
  SalesPeriod _period = SalesPeriod.daily;
  DateTime _anchor = DateTime.now();
  DateTime? _customStart;
  DateTime? _customEnd;
  SalesAnalytics? _analytics;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    refresh();
  }

  Future<void> refresh() async {
    setState(() => _loading = true);
    await Future<void>.delayed(Duration.zero);
    if (!mounted) return;
    final result = SalesAnalyticsService.calculate(
      period: _period,
      anchor: _anchor,
      customStart: _customStart,
      customEnd: _customEnd,
    );
    setState(() {
      _analytics = result;
      _loading = false;
    });
  }

  Future<void> _chooseAnchor() async {
    final today = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _anchor,
      firstDate: DateTime(today.year - 10),
      lastDate: DateTime(today.year + 2),
    );
    if (picked == null) return;
    setState(() => _anchor = picked);
    await refresh();
  }

  Future<void> _chooseCustomStart() async {
    final today = DateTime.now();
    final selected = await showDatePicker(
      context: context,
      initialDate: _customStart ?? _anchor,
      firstDate: DateTime(today.year - 20),
      lastDate: DateTime(today.year + 2),
    );
    if (selected == null) return;
    setState(() {
      _customStart = selected;
      _customEnd ??= selected;
      _anchor = selected;
    });
    await refresh();
  }

  Future<void> _chooseCustomEnd() async {
    final today = DateTime.now();
    final start = _customStart ?? _anchor;
    final selected = await showDatePicker(
      context: context,
      initialDate: _customEnd ?? start,
      firstDate: DateTime(today.year - 20),
      lastDate: DateTime(today.year + 2),
    );
    if (selected == null) return;
    setState(() => _customEnd = selected);
    await refresh();
  }

  String _dateLabel(DateTime date) =>
      '${date.month.toString().padLeft(2, '0')}/${date.day.toString().padLeft(2, '0')}/${date.year}';

  String _money(double amount) => '₱${amount.toStringAsFixed(2)}';

  @override
  Widget build(BuildContext context) {
    final analytics = _analytics;
    return Scaffold(
      backgroundColor: AppTheme.backgroundDark,
      body: _loading || analytics == null
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: refresh,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
                children: [
                  _periodSelector(),
                  const SizedBox(height: 12),
                  if (_period == SalesPeriod.custom)
                    _customRangeSelector()
                  else
                    _anchorSelector(),
                  const SizedBox(height: 16),
                  _summaryGrid(analytics),
                  const SizedBox(height: 20),
                  if (!analytics.hasSalesData && !analytics.hasReservationData)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 20),
                      child: Center(
                        child: Text('No sales data available for this period.'),
                      ),
                    )
                  else ...[
                    _chartSection(
                      'Sales Overview',
                      'Payments received less refunds in the selected period',
                      _salesChart(analytics),
                    ),
                    const SizedBox(height: 12),
                    _chartSection(
                      'Reservation Overview',
                      'Reservations grouped by current status',
                      _statusChart(analytics),
                    ),
                    const SizedBox(height: 12),
                    _chartSection(
                      'Service Sales',
                      'Recorded payments grouped by service',
                      _serviceBreakdown(analytics),
                    ),
                    const SizedBox(height: 12),
                    _chartSection(
                      'Walk-In vs Online',
                      'Reservations and recorded payments by source',
                      _sourceBreakdown(analytics),
                    ),
                    const SizedBox(height: 12),
                    _chartSection(
                      'Payment Status',
                      'Reservation count and current net amount by status',
                      _paymentBreakdown(analytics),
                    ),
                  ],
                  if (analytics.hasSalesData ||
                      analytics.hasReservationData) ...[
                    const SizedBox(height: 12),
                    _periodDetails(analytics),
                  ],
                ],
              ),
            ),
    );
  }

  Widget _periodSelector() => SingleChildScrollView(
    scrollDirection: Axis.horizontal,
    child: SegmentedButton<SalesPeriod>(
      segments: const [
        ButtonSegment(value: SalesPeriod.daily, label: Text('Daily')),
        ButtonSegment(value: SalesPeriod.weekly, label: Text('Weekly')),
        ButtonSegment(value: SalesPeriod.monthly, label: Text('Monthly')),
        ButtonSegment(value: SalesPeriod.yearly, label: Text('Yearly')),
        ButtonSegment(value: SalesPeriod.custom, label: Text('Custom')),
      ],
      selected: {_period},
      showSelectedIcon: false,
      onSelectionChanged: (selection) async {
        setState(() {
          _period = selection.first;
          if (_period == SalesPeriod.custom) {
            _customStart ??= _anchor;
            _customEnd ??= _anchor;
          }
        });
        await refresh();
      },
    ),
  );

  Widget _anchorSelector() {
    final label = switch (_period) {
      SalesPeriod.daily => 'Date: ${_dateLabel(_anchor)}',
      SalesPeriod.weekly =>
        'Week of ${_dateLabel(_anchor.subtract(Duration(days: _anchor.weekday - 1)))}',
      SalesPeriod.monthly =>
        'Month: ${_anchor.year}-${_anchor.month.toString().padLeft(2, '0')}',
      SalesPeriod.yearly => 'Year: ${_anchor.year}',
      SalesPeriod.custom => 'Choose a custom range',
    };
    return OutlinedButton.icon(
      onPressed: _chooseAnchor,
      icon: const Icon(Icons.calendar_month_rounded),
      label: Text(label),
      style: OutlinedButton.styleFrom(
        foregroundColor: AppTheme.primary,
        alignment: Alignment.centerLeft,
      ),
    );
  }

  Widget _customRangeSelector() => Row(
    children: [
      Expanded(
        child: OutlinedButton(
          onPressed: _chooseCustomStart,
          child: Text('Start ${_dateLabel(_customStart ?? _anchor)}'),
        ),
      ),
      const SizedBox(width: 8),
      Expanded(
        child: OutlinedButton(
          onPressed: _chooseCustomEnd,
          child: Text(
            'End ${_dateLabel(_customEnd ?? _customStart ?? _anchor)}',
          ),
        ),
      ),
    ],
  );

  Widget _summaryGrid(SalesAnalytics data) => LayoutBuilder(
    builder: (context, constraints) {
      final columns = constraints.maxWidth >= 600 ? 4 : 2;
      final metrics = <(String, String, Color)>[
        ('Net sales', _money(data.totalSales), AppTheme.primary),
        (
          'Completed service value',
          _money(data.totalServiceValue),
          AppTheme.success,
        ),
        ('Payments received', _money(data.totalPaid), const Color(0xFF54B8A9)),
        ('Refunds recorded', _money(data.totalRefunded), AppTheme.errorColor),
        ('Total unpaid', _money(data.totalUnpaid), AppTheme.warning),
        ('Down payments', _money(data.downPayments), const Color(0xFF7FA7F2)),
        ('Reservations', '${data.reservations}', AppTheme.onSurfaceDark),
        ('Completed', '${data.completed}', AppTheme.success),
        ('Cancelled', '${data.cancelled}', AppTheme.errorColor),
        ('No-show', '${data.noShow}', AppTheme.mutedText),
      ];
      return GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: metrics.length,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: columns,
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
          childAspectRatio: columns == 2 ? 1.75 : 1.55,
        ),
        itemBuilder: (context, index) {
          final (label, value, color) = metrics[index];
          return Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.surfaceDark,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFF2C2C2E)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  label,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppTheme.mutedText,
                  ),
                ),
                const SizedBox(height: 5),
                FittedBox(
                  alignment: Alignment.centerLeft,
                  fit: BoxFit.scaleDown,
                  child: Text(
                    value,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: color,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      );
    },
  );

  Widget _chartSection(String title, String subtitle, Widget child) =>
      Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppTheme.surfaceDark,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFF2C2C2E)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 3),
            Text(
              subtitle,
              style: const TextStyle(fontSize: 11, color: AppTheme.mutedText),
            ),
            const SizedBox(height: 16),
            child,
          ],
        ),
      );

  Widget _salesChart(SalesAnalytics data) {
    if (!data.hasSalesData) {
      return _emptyChart();
    }
    final spots = <FlSpot>[];
    for (var i = 0; i < data.trend.length; i++) {
      spots.add(FlSpot(i.toDouble(), data.trend[i].sales));
    }
    if (spots.isEmpty) return _emptyChart();
    final maxValue = data.trend.fold<double>(
      0,
      (value, point) => math.max(value, point.sales),
    );
    return SizedBox(
      height: 220,
      child: LineChart(
        LineChartData(
          minY: math.min(
            0,
            data.trend.fold<double>(
              0,
              (value, point) => math.min(value, point.sales),
            ),
          ),
          maxY: maxValue <= 0 ? 1 : maxValue * 1.2,
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            getDrawingHorizontalLine: (_) =>
                FlLine(color: const Color(0xFF343438), strokeWidth: 1),
          ),
          borderData: FlBorderData(show: false),
          titlesData: FlTitlesData(
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 45,
                getTitlesWidget: (value, meta) => Text(
                  _compactMoney(value),
                  style: const TextStyle(
                    fontSize: 9,
                    color: AppTheme.mutedText,
                  ),
                ),
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: data.trend.length > 12
                    ? (data.trend.length / 6).ceilToDouble()
                    : 1,
                getTitlesWidget: (value, meta) {
                  final index = value.toInt();
                  if (index < 0 || index >= data.trend.length) {
                    return const SizedBox.shrink();
                  }
                  return Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      data.trend[index].label,
                      style: const TextStyle(
                        fontSize: 9,
                        color: AppTheme.mutedText,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              color: AppTheme.primary,
              barWidth: 3,
              dotData: FlDotData(show: data.trend.length <= 12),
              belowBarData: BarAreaData(
                show: true,
                color: AppTheme.primary.withAlpha(22),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _compactMoney(double value) {
    if (value.abs() >= 1000) return '₱${(value / 1000).toStringAsFixed(0)}k';
    return '₱${value.toStringAsFixed(0)}';
  }

  Widget _statusChart(SalesAnalytics data) {
    const labels = [
      'Confirmed',
      'Completed',
      'Cancelled',
      'No-Show',
      'Pending',
    ];
    final values = labels.map((label) => data.statuses[label] ?? 0).toList();
    return _barChart(
      labels,
      values.map((value) => value.toDouble()).toList(),
      const [
        Color(0xFF4D9BE8),
        AppTheme.success,
        AppTheme.errorColor,
        Color(0xFF9B8AFB),
        AppTheme.warning,
      ],
      valuePrefix: '',
    );
  }

  Widget _serviceBreakdown(SalesAnalytics data) {
    final items = data.services
        .where((item) => item.reservations > 0 || item.sales != 0)
        .toList();
    if (items.isEmpty) return _emptyChart();
    return Column(
      children: [
        SizedBox(
          height: math.max(150, items.length * 46).toDouble(),
          child: _barChart(
            items.map((item) => item.name).toList(),
            items.map((item) => item.sales).toList(),
            List.generate(
              items.length,
              (index) =>
                  index.isEven ? AppTheme.primary : const Color(0xFF54B8A9),
            ),
            valuePrefix: '₱',
          ),
        ),
        const SizedBox(height: 8),
        ...items.map((item) {
          final percentage = data.totalSales == 0
              ? 0.0
              : item.sales / data.totalSales * 100;
          return _breakdownRow(
            item.name,
            '${item.reservations} bookings • ${_money(item.sales)} • ${percentage.toStringAsFixed(1)}%',
          );
        }),
      ],
    );
  }

  Widget _sourceBreakdown(SalesAnalytics data) => Column(
    children: [
      _donutChart(
        data.sources.where((item) => item.reservations > 0).toList(),
        (item) => item.reservations.toDouble(),
        (index) => index == 0 ? AppTheme.primary : const Color(0xFF54B8A9),
      ),
      const SizedBox(height: 8),
      ...data.sources.map(
        (item) => _breakdownRow(
          item.name,
          '${item.reservations} reservations • ${_money(item.sales)} net payments',
          color: item.name == 'Walk-In'
              ? AppTheme.primary
              : const Color(0xFF54B8A9),
        ),
      ),
    ],
  );

  Widget _paymentBreakdown(SalesAnalytics data) {
    final items = data.payments.where((item) => item.reservations > 0).toList();
    return Column(
      children: [
        _donutChart(
          items,
          (item) => item.reservations.toDouble(),
          (index) => _paymentColor(items[index].name),
        ),
        const SizedBox(height: 8),
        ...items.map(
          (item) => _breakdownRow(
            item.name,
            '${item.reservations} reservations • ${_paymentAmountLabel(item)}',
            color: _paymentColor(item.name),
          ),
        ),
      ],
    );
  }

  Widget _donutChart(
    List<SalesBreakdown> items,
    double Function(SalesBreakdown) valueFor,
    Color Function(int) colorFor,
  ) {
    final visible = items.where((item) => valueFor(item) > 0).toList();
    if (visible.isEmpty) return _emptyChart();
    return SizedBox(
      height: 170,
      child: PieChart(
        PieChartData(
          centerSpaceRadius: 42,
          sectionsSpace: 3,
          sections: List.generate(visible.length, (index) {
            final item = visible[index];
            return PieChartSectionData(
              value: valueFor(item),
              color: colorFor(index),
              radius: 48,
              title: '${item.reservations}',
              titleStyle: const TextStyle(
                color: Colors.black,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            );
          }),
        ),
      ),
    );
  }

  Color _paymentColor(String status) => switch (status) {
    'Fully Paid' => AppTheme.success,
    'Down Payment' => const Color(0xFF7FA7F2),
    'Refunded' => AppTheme.errorColor,
    _ => AppTheme.warning,
  };

  String _paymentAmountLabel(SalesBreakdown item) => switch (item.name) {
    'Unpaid' => '${_money(item.amount)} balance due',
    'Refunded' => '${_money(item.amount)} net retained',
    _ => '${_money(item.amount)} received',
  };

  Widget _breakdownRow(
    String title,
    String detail, {
    Color color = AppTheme.primary,
  }) => Container(
    margin: const EdgeInsets.only(bottom: 8),
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
    decoration: BoxDecoration(
      color: AppTheme.surfaceVariantDark,
      borderRadius: BorderRadius.circular(8),
    ),
    child: Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 9),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
              Text(
                detail,
                style: const TextStyle(color: AppTheme.mutedText, fontSize: 10),
              ),
            ],
          ),
        ),
      ],
    ),
  );

  Widget _barChart(
    List<String> labels,
    List<double> values,
    List<Color> colors, {
    required String valuePrefix,
  }) {
    if (labels.isEmpty) return _emptyChart();
    final maxValue = values.fold<double>(
      0,
      (value, item) => math.max(value, item.abs()),
    );
    return SizedBox(
      height: 220,
      child: BarChart(
        BarChartData(
          minY: values.any((value) => value < 0)
              ? values.reduce(math.min) * 1.2
              : 0,
          maxY: maxValue <= 0 ? 1 : maxValue * 1.2,
          alignment: BarChartAlignment.spaceAround,
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            getDrawingHorizontalLine: (_) =>
                FlLine(color: const Color(0xFF343438), strokeWidth: 1),
          ),
          borderData: FlBorderData(show: false),
          titlesData: FlTitlesData(
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 42,
                getTitlesWidget: (value, meta) => Text(
                  valuePrefix == '₱'
                      ? _compactMoney(value)
                      : value.toStringAsFixed(0),
                  style: const TextStyle(
                    fontSize: 9,
                    color: AppTheme.mutedText,
                  ),
                ),
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  final index = value.toInt();
                  if (index < 0 || index >= labels.length) {
                    return const SizedBox.shrink();
                  }
                  final label = labels[index];
                  return Padding(
                    padding: const EdgeInsets.only(top: 7),
                    child: SizedBox(
                      width: 58,
                      child: Text(
                        label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 9,
                          color: AppTheme.mutedText,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          barGroups: List.generate(
            values.length,
            (index) => BarChartGroupData(
              x: index,
              barRods: [
                BarChartRodData(
                  toY: values[index],
                  color: colors[index % colors.length],
                  width: labels.length > 10 ? 7 : 15,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(3),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _periodDetails(SalesAnalytics data) {
    final header = switch (_period) {
      SalesPeriod.daily => 'Daily activity',
      SalesPeriod.weekly => 'Weekly activity',
      SalesPeriod.monthly => 'Monthly activity',
      SalesPeriod.yearly => 'Yearly activity',
      SalesPeriod.custom => 'Selected range activity',
    };
    return _chartSection(
      header,
      'Customers ${data.uniqueCustomers} • completed ${data.completed} • walk-ins ${data.walkIns} • online ${data.online}',
      Column(
        children: data.trend
            .map(
              (bucket) => _breakdownRow(
                bucket.label,
                '${_money(bucket.sales)} received • ${bucket.reservations} reservations • ${bucket.completed} completed • ${bucket.walkIns} walk-ins • ${bucket.online} online',
              ),
            )
            .toList(),
      ),
    );
  }

  Widget _emptyChart() => const SizedBox(
    height: 80,
    child: Center(child: Text('No sales data available for this period.')),
  );
}
