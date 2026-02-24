import 'package:flutter/material.dart';

class TrackingStep extends StatelessWidget {
  final String title;
  final String? subtitle; // 🔥 For showing time
  final bool isCompleted;
  final bool isCurrent;
  final bool isLast;

  const TrackingStep({
    super.key,
    required this.title,
    this.subtitle,
    required this.isCompleted,
    required this.isCurrent,
    required this.isLast,
  });

  @override
  Widget build(BuildContext context) {
    Color activeColor = Colors.green;
    Color pendingColor = Colors.grey;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            // 🔵 Circle
            Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                color: isCompleted
                    ? activeColor
                    : isCurrent
                        ? Colors.orange
                        : pendingColor,
                shape: BoxShape.circle,
              ),
              child: isCompleted
                  ? const Icon(
                      Icons.check,
                      size: 14,
                      color: Colors.white,
                    )
                  : null,
            ),

            // 🔵 Vertical Line
            if (!isLast)
              Container(
                width: 2,
                height: 45,
                color: isCompleted ? activeColor : pendingColor,
              ),
          ],
        ),

        const SizedBox(width: 12),

        // 🔥 Title + Time
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: isCompleted
                        ? Colors.green
                        : isCurrent
                            ? Colors.orange
                            : Colors.black54,
                    fontWeight:
                        isCurrent ? FontWeight.bold : FontWeight.normal,
                  ),
                ),

                if (subtitle != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      subtitle!,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.black54,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
