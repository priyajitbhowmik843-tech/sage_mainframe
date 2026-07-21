import 'package:flutter/material.dart';
import 'package:sage_mainframe/theme/app_theme.dart';

class SageCalendar extends StatelessWidget {
  final DateTime currentMonth;
  final VoidCallback onPreviousMonth;
  final VoidCallback onNextMonth;
  final Widget Function(BuildContext context, DateTime date) cellBuilder;
  final Widget? legend;
  final Widget? customHeader;
  final Widget? customDaysOfWeek;
  final SliverGridDelegate? gridDelegate;

  const SageCalendar({
    Key? key,
    required this.currentMonth,
    required this.onPreviousMonth,
    required this.onNextMonth,
    required this.cellBuilder,
    this.legend,
    this.customHeader,
    this.customDaysOfWeek,
    this.gridDelegate,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final daysInMonth = DateUtils.getDaysInMonth(
      currentMonth.year,
      currentMonth.month,
    );
    final startOffset =
        DateTime(currentMonth.year, currentMonth.month, 1).weekday % 7;
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: SageColors.brutalistDecoration(),
      child: Column(
        children: [
          customHeader ??
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: onPreviousMonth,
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: SageColors.yellowAccent,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.black, width: 1.5),
                      ),
                      child: const Icon(Icons.chevron_left, size: 18),
                    ),
                  ),
                  Text(
                    '${months[currentMonth.month - 1]} ${currentMonth.year}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      letterSpacing: 1,
                    ),
                  ),
                  GestureDetector(
                    onTap: onNextMonth,
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: SageColors.yellowAccent,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.black, width: 1.5),
                      ),
                      child: const Icon(Icons.chevron_right, size: 18),
                    ),
                  ),
                ],
              ),
          const SizedBox(height: 10),
          customDaysOfWeek ??
              Row(
                children: ['S', 'M', 'T', 'W', 'T', 'F', 'S']
                    .map(
                      (d) => Expanded(
                        child: Center(
                          child: Text(
                            d,
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: Colors.black54,
                            ),
                          ),
                        ),
                      ),
                    )
                    .toList(),
              ),
          const SizedBox(height: 6),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate:
                gridDelegate ??
                const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 7,
                  childAspectRatio: 1,
                ),
            itemCount: daysInMonth + startOffset,
            itemBuilder: (ctx, i) {
              if (i < startOffset) return const SizedBox();
              final day = i - startOffset + 1;
              final date = DateTime(currentMonth.year, currentMonth.month, day);
              return cellBuilder(ctx, date);
            },
          ),
          if (legend != null) ...[const SizedBox(height: 10), legend!],
        ],
      ),
    );
  }
}

Widget calendarLegend(Color c, String label) => Row(
  children: [
    Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(
        color: c,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.black, width: 0.5),
      ),
    ),
    const SizedBox(width: 4),
    Text(
      label,
      style: const TextStyle(
        fontSize: 10,
        color: Colors.black54,
        fontWeight: FontWeight.bold,
      ),
    ),
  ],
);
