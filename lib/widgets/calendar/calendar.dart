import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:ezhandy_user/utils/app_colors.dart';

class CustomCalendar extends StatefulWidget {
  final List<DateTime> highlightedDates;
  final Function(List<DateTime>)? onDatesChanged;
  final DateTime? initialFocusedDate;

  const CustomCalendar({
    Key? key,
    required this.highlightedDates,
    this.onDatesChanged,
    this.initialFocusedDate,
  }) : super(key: key);

  @override
  State<CustomCalendar> createState() => _CustomCalendarState();
}

class _CustomCalendarState extends State<CustomCalendar> {
  late DateTime focusedDay;
  late Set<DateTime> selectedDates;

  @override
  void initState() {
    super.initState();

    focusedDay = widget.initialFocusedDate ?? DateTime.now();

    selectedDates = widget.highlightedDates
        .map(_normalizeDate)
        .toSet();

    if (selectedDates.isEmpty) {
      selectedDates.add(_normalizeDate(DateTime.now()));
    }
  }

  DateTime _normalizeDate(DateTime date) =>
      DateTime(date.year, date.month, date.day);

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  bool _isSelected(DateTime day) {
    return selectedDates.any((d) => _isSameDay(d, day));
  }

  void _onDayTapped(DateTime day, DateTime focused) {
    final normalized = _normalizeDate(day);

    setState(() {
      if (selectedDates.contains(normalized)) {
        /// 🔴 REMOVE if already selected
        selectedDates.remove(normalized);
      } else {
        /// 🟢 ADD if not selected
        selectedDates.add(normalized);
      }
      focusedDay = focused;
    });

    widget.onDatesChanged?.call(selectedDates.toList());
  }

  @override
  Widget build(BuildContext context) {
    return TableCalendar(
      firstDay: DateTime.utc(2020, 1, 1),
      lastDay: DateTime.utc(2030, 12, 31),
      focusedDay: focusedDay,

      selectedDayPredicate: (day) => _isSelected(day),

      startingDayOfWeek: StartingDayOfWeek.monday,

      headerStyle: const HeaderStyle(
        formatButtonVisible: false,
        titleCentered: true,
      ),

      calendarStyle: CalendarStyle(
        todayDecoration: const BoxDecoration(color: Colors.transparent),
        selectedDecoration: BoxDecoration(
          color: AppColors.orange,
          borderRadius: BorderRadius.circular(10),
        ),
        selectedTextStyle: const TextStyle(color: Colors.white),
      ),

      calendarBuilders: CalendarBuilders(
        defaultBuilder: (context, day, _) {
          final isSelected = _isSelected(day);

          return Container(
            margin: const EdgeInsets.only(bottom: 5),
            alignment: Alignment.center,
            decoration: isSelected
                ? BoxDecoration(
                    color: AppColors.orange.withOpacity(0.85),
                    borderRadius: BorderRadius.circular(10),
                  )
                : null,
            child: Text(
              '${day.day}',
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.black,
              ),
            ),
          );
        },
      ),

      onDaySelected: _onDayTapped,
    );
  }
}
