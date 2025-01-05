import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';
import 'package:sss_retail/constants/app_colors.dart';

class ScheduleOrderWidget extends StatefulWidget {
  final DateTime? selectedDate;
  final void Function()? onDateSelected;
  const ScheduleOrderWidget(
      {super.key, required this.selectedDate, required this.onDateSelected});

  @override
  State<ScheduleOrderWidget> createState() => _ScheduleOrderWidgetState();
}

class _ScheduleOrderWidgetState extends State<ScheduleOrderWidget> {
  @override
  Widget build(BuildContext context) {
    const String _orderType = 'Schedule';

    return Column(
      children: [
        if (_orderType == 'Schedule') ...[
          Gap(6),
          Container(
            margin: EdgeInsets.symmetric(horizontal: 15),
            padding: EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black26,
                  spreadRadius: 1,
                  blurRadius: 3,
                  offset: Offset(0, -1),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: ListTile(
                    title: Text(
                      widget.selectedDate != null
                          ? DateFormat('dd MMM yyyy')
                              .format(widget.selectedDate!)
                          : 'Select Date',
                      style: const TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                      ),
                    ),
                    leading: Icon(
                      Icons.calendar_today,
                      color: AppColors.primary,
                    ),
                    onTap: widget.onDateSelected,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}
