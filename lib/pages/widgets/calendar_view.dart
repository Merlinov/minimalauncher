import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CustomCalendarView extends StatelessWidget {
  final DateTime selectedDate;
  final Color bgColor;
  final Color accentColor;
  final Color textColor;
  final List<DateTime> eventDates;

  CustomCalendarView({
    Key? key,
    required this.selectedDate,
    required this.bgColor,
    required this.textColor,
    required this.accentColor,
    required this.eventDates,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final daysInMonth =
        DateUtils.getDaysInMonth(selectedDate.year, selectedDate.month);
    final firstDayOfMonth = DateTime(selectedDate.year, selectedDate.month, 1);
    final startWeekday =
        firstDayOfMonth.weekday % 7; // 0 for Sunday, 1 for Monday, etc.
    final monthName = DateFormat('MMMM yyyy').format(selectedDate);

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
      decoration: BoxDecoration(
        color: bgColor.withOpacity(0.2),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Month Name
          Text(
            monthName,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: bgColor,
            ),
          ),
          const SizedBox(height: 10),

          // Days of the Week Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
                .map((day) => Expanded(
                      child: Center(
                        child: Text(
                          day,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: bgColor,
                          ),
                        ),
                      ),
                    ))
                .toList(),
          ),
          const SizedBox(height: 10),

          // Calendar Days
          Table(
            columnWidths: const {
              0: FractionColumnWidth(1 / 7),
              1: FractionColumnWidth(1 / 7),
              2: FractionColumnWidth(1 / 7),
              3: FractionColumnWidth(1 / 7),
              4: FractionColumnWidth(1 / 7),
              5: FractionColumnWidth(1 / 7),
              6: FractionColumnWidth(1 / 7),
            },
            children: _buildCalendarDays(daysInMonth, startWeekday),
          ),
        ],
      ),
    );
  }

  List<TableRow> _buildCalendarDays(int daysInMonth, int startWeekday) {
    List<TableRow> rows = [];
    // Padding for starting weekday
    List<Widget> days = List.generate(startWeekday, (index) => Container());

    for (int day = 1; day <= daysInMonth; day++) {
      final currentDate = DateTime(selectedDate.year, selectedDate.month, day);
      bool hasEvent = eventDates.any((date) =>
          date.year == currentDate.year &&
          date.month == currentDate.month &&
          date.day == currentDate.day);

      days.add(Column(
        children: [
          Text(
            '$day',
            style: TextStyle(
              fontSize: 16,
              color: hasEvent ? accentColor : textColor,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (hasEvent)
            Container(
              margin: const EdgeInsets.only(top: 4),
              width: 5,
              height: 5,
              decoration: BoxDecoration(
                color: bgColor,
                shape: BoxShape.circle,
              ),
            ),
        ],
      ));

      if (days.length == 7 || day == daysInMonth) {
        if (days.length < 7) {
          days.addAll(List.generate(7 - days.length,
              (index) => Container())); // Padding for end of the month
        }
        rows.add(TableRow(children: days));
        days = [];
      }
    }

    return rows;
  }
}
