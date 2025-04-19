import 'package:flutter/material.dart';

class TimeInputField extends StatelessWidget {
  final String label;
  final TimeOfDay initialTime;
  final void Function(TimeOfDay) onTimeChanged;

  const TimeInputField({
    super.key,
    required this.label,
    required this.initialTime,
    required this.onTimeChanged,
  });

  @override
  Widget build(BuildContext context) {
    final controller = TextEditingController(text: initialTime.format(context));

    return GestureDetector(
      onTap: () async {
        final picked = await showTimePicker(
          context: context,
          initialTime: initialTime,
        );
        if (picked != null) {
          onTimeChanged(picked);
          controller.text = picked.format(context);
        }
      },
      child: AbsorbPointer(
        child: TextFormField(
          controller: controller,
          decoration: InputDecoration(labelText: label),
        ),
      ),
    );
  }
}