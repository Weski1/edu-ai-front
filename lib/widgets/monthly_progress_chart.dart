import 'package:flutter/material.dart';

class MonthlyProgressChart extends StatelessWidget {
  final Map<String, double> monthlyProgress;

  const MonthlyProgressChart({super.key, required this.monthlyProgress});

  @override
  Widget build(BuildContext context) {
    if (monthlyProgress.isEmpty) {
      return SizedBox(
        height: 200,
        child: Center(
          child: Text(
            'Brak danych o postępach',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
        ),
      );
    }

    // Determine the timeline (last 6 months based on latest data or now)
    DateTime latestDate = DateTime.now();
    if (monthlyProgress.isNotEmpty) {
      final dates =
          monthlyProgress.keys.map((k) {
            final parts = k.split('-');
            if (parts.length >= 2) {
              return DateTime(int.parse(parts[0]), int.parse(parts[1]));
            }
            return DateTime.now();
          }).toList();
      dates.sort();
      latestDate = dates.isNotEmpty ? dates.last : DateTime.now();
    }

    // Generate last 6 months keys
    final List<String> chartKeys = [];
    for (int i = 5; i >= 0; i--) {
      int year = latestDate.year;
      int month = latestDate.month - i;
      while (month <= 0) {
        month += 12;
        year -= 1;
      }
      chartKeys.add('$year-${month.toString().padLeft(2, '0')}');
    }

    // Fixed max value 100%
    const double maxValue = 100.0;
    const double plotHeight = 160.0;

    return Card(
      elevation: 4,
      shadowColor: Theme.of(context).shadowColor.withOpacity(0.1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Postęp w czasie',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Y-Axis Labels
                SizedBox(
                  height: plotHeight, // Match plot height
                  width: 30, // Fixed width for labels
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildYLabel(context, '100%'),
                      _buildYLabel(context, '75%'),
                      _buildYLabel(context, '50%'),
                      _buildYLabel(context, '25%'),
                      _buildYLabel(context, '0%'),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                // Chart & X-Labels
                Expanded(
                  child: Column(
                    children: [
                      // Plot Area
                      SizedBox(
                        height: plotHeight,
                        child: Stack(
                          children: [
                            // Grid Lines
                            Column(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: const [
                                Divider(height: 1),
                                Divider(height: 1),
                                Divider(height: 1),
                                Divider(height: 1),
                                Divider(height: 1),
                              ],
                            ),
                            // Bars
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children:
                                  chartKeys.map((month) {
                                    final score = monthlyProgress[month] ?? 0.0;
                                    final heightPercentage = score / maxValue;

                                    return Expanded(
                                      child: Align(
                                        alignment: Alignment.bottomCenter,
                                        child:
                                            score > 0
                                                ? Tooltip(
                                                  message:
                                                      '${score.toStringAsFixed(1)}%',
                                                  child: TweenAnimationBuilder<
                                                    double
                                                  >(
                                                    tween: Tween<double>(
                                                      begin: 0,
                                                      end: heightPercentage,
                                                    ),
                                                    duration: const Duration(
                                                      milliseconds: 1000,
                                                    ),
                                                    curve: Curves.easeOutQuart,
                                                    builder: (
                                                      context,
                                                      value,
                                                      child,
                                                    ) {
                                                      return Container(
                                                        height:
                                                            plotHeight * value,
                                                        width: 16,
                                                        decoration: BoxDecoration(
                                                          gradient: LinearGradient(
                                                            begin:
                                                                Alignment
                                                                    .bottomCenter,
                                                            end:
                                                                Alignment
                                                                    .topCenter,
                                                            colors: [
                                                              Theme.of(context)
                                                                  .colorScheme
                                                                  .primary
                                                                  .withOpacity(
                                                                    0.5,
                                                                  ),
                                                              Theme.of(context)
                                                                  .colorScheme
                                                                  .primary,
                                                            ],
                                                          ),
                                                          borderRadius:
                                                              const BorderRadius.vertical(
                                                                top:
                                                                    Radius.circular(
                                                                      6,
                                                                    ),
                                                              ),
                                                        ),
                                                      );
                                                    },
                                                  ),
                                                )
                                                : const SizedBox(
                                                  height: 0,
                                                  width: 16,
                                                ),
                                      ),
                                    );
                                  }).toList(),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      // X-Axis Labels
                      Row(
                        children:
                            chartKeys.map((month) {
                              final dateParts = month.split('-');
                              String monthLabel = month;
                              if (dateParts.length == 2) {
                                monthLabel = _getMonthName(
                                  int.tryParse(dateParts[1]) ?? 0,
                                );
                              }
                              return Expanded(
                                child: Center(
                                  child: Text(
                                    monthLabel,
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.onSurface.withOpacity(0.6),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildYLabel(BuildContext context, String text) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 10,
        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
      ),
    );
  }

  String _getMonthName(int month) {
    const months = [
      '',
      'Sty',
      'Lut',
      'Mar',
      'Kwi',
      'Maj',
      'Cze',
      'Lip',
      'Sie',
      'Wrz',
      'Paź',
      'Lis',
      'Gru',
    ];
    if (month >= 1 && month <= 12) return months[month];
    return '?';
  }
}
