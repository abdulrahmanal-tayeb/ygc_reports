import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:ygc_reports/core/constants/types.dart';

class Logo extends StatelessWidget {
  final double size;
  final Color? color;
  final LogoType logoType;
  const Logo({super.key, this.size = 30, this.color, this.logoType = LogoType.ygcReports});

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      'assets/logos/${logoType == LogoType.ygcReports? "logo" : "amtcode"}.svg',
      fit: BoxFit.contain,
      width: size,
      colorFilter: ColorFilter.mode(color ?? Theme.of(context).colorScheme.primary, BlendMode.srcIn),
      alignment: Alignment.center,
    );
  }
}
