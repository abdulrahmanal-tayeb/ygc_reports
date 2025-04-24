import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';

class FloatingActions<T> extends StatelessWidget {
  final List<T> options;
  final SpeedDialChild Function(T item) itemBuilder;
  final IconData icon;
  final IconData activeIcon;

  const FloatingActions({
    super.key,
    required this.options,
    required this.itemBuilder,
    this.icon = Icons.add,
    this.activeIcon = Icons.close,
  });

  @override
  Widget build(BuildContext context) {
    final isRtl = Directionality.of(context) == TextDirection.rtl;

    return SpeedDial(
      icon: icon,
      activeIcon: activeIcon,
      backgroundColor: Colors.white,
      foregroundColor: Colors.black,
      activeBackgroundColor: Colors.black,
      activeForegroundColor: Colors.white,
      spacing: 12,
      spaceBetweenChildren: 8,
      elevation: 4.0,
      childrenButtonSize: const Size(56.0, 56.0),
      direction: SpeedDialDirection.up, // open upward to avoid overflow
      switchLabelPosition: isRtl,       // labels to the left in RTL
      children: options.map((item) => itemBuilder(item)).toList(),
    );
  }
}
