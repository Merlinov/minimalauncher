import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class CustomCalendarView extends StatefulWidget {
  final DateTime initialDate;
  final Color bgColor;
  final Color accentColor;
  final Color textColor;
  final String fontFamily;
  final List<DateTime> eventDates;

  CustomCalendarView({
    Key? key,
    required this.initialDate,
    required this.bgColor,
    required this.textColor,
    required this.accentColor,
    required this.eventDates,
    required this.fontFamily,
  }) : super(key: key);

  @override
  _CustomCalendarViewState createState() => _CustomCalendarViewState();
}

class _CustomCalendarViewState extends State<CustomCalendarView> {
  late DateTime selectedDate;

  @override
  void initState() {
    super.initState();
    selectedDate = widget.initialDate;
  }

  void _goToPreviousMonth() {
    setState(() {
      selectedDate = DateTime(selectedDate.year, selectedDate.month - 1);
    });
  }

  void _goToNextMonth() {
    setState(() {
      selectedDate = DateTime(selectedDate.year, selectedDate.month + 1);
    });
  }

  @override
  Widget build(BuildContext context) {
    final daysInMonth =
        DateUtils.getDaysInMonth(selectedDate.year, selectedDate.month);
    final firstDayOfMonth = DateTime(selectedDate.year, selectedDate.month, 1);
    final startWeekday = firstDayOfMonth.weekday % 7;
    final monthName = DateFormat('MMMM yyyy').format(selectedDate);

    return Container(
      padding: const EdgeInsets.only(bottom: 16, top: 10, left: 10, right: 10),
      decoration: BoxDecoration(
        color: widget.textColor.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Month Navigation
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: Icon(
                  Icons.arrow_back_rounded,
                  color: widget.textColor,
                  size: 28,
                ),
                onPressed: () {
                  HapticFeedback.lightImpact();
                  _goToPreviousMonth();
                },
              ),
              GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  setState(() {
                    selectedDate = DateTime.now();
                  });
                },
                child: Text(
                  monthName,
                  style: TextStyle(
                    fontSize: 20,
                    fontFamily: widget.fontFamily,
                    fontWeight: FontWeight.w500,
                    color: widget.textColor,
                  ),
                ),
              ),
              IconButton(
                icon: Icon(
                  Icons.arrow_forward_rounded,
                  color: widget.textColor,
                  size: 28,
                ),
                onPressed: () {
                  HapticFeedback.lightImpact();
                  _goToNextMonth();
                },
              ),
            ],
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
                            fontFamily: widget.fontFamily,
                            color: widget.textColor.withOpacity(0.5),
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
    List<Widget> days = List.generate(startWeekday, (index) => Container());

    for (int day = 1; day <= daysInMonth; day++) {
      final currentDate = DateTime(selectedDate.year, selectedDate.month, day);
      bool hasEvent = widget.eventDates.any((date) =>
          date.year == currentDate.year &&
          date.month == currentDate.month &&
          date.day == currentDate.day);

      days.add(Column(
        children: [
          GestureDetector(
            onTap: () {
              // TODO day clicked
            },
            child: Text(
              '$day',
              style: TextStyle(
                fontSize: 16,
                fontFamily: widget.fontFamily,
                color: hasEvent
                    ? widget.accentColor
                    : widget.textColor.withOpacity(0.8),
              ),
            ),
          ),
          // Indicator below the day with an event
          // if (hasEvent)
          //   Container(
          //     margin: const EdgeInsets.only(top: 2),
          //     width: 5,
          //     height: 5,
          //     decoration: BoxDecoration(
          //       color: widget.accentColor,
          //       shape: BoxShape.circle,
          //     ),
          //   ),
        ],
      ));

      if (days.length == 7 || day == daysInMonth) {
        if (days.length < 7) {
          days.addAll(List.generate(7 - days.length, (index) => Container()));
        }
        rows.add(TableRow(children: days));
        days = [];
      }
    }

    return rows;
  }
}
