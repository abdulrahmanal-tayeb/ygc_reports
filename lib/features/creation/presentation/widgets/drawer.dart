import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:ygc_reports/widgets/logo.dart';
import 'package:ygc_reports/widgets/language_switcher.dart';

class DrawerWidget extends StatelessWidget {
  const DrawerWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.black,
      child: SafeArea(
        child: Container(
          margin: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 40),
              const Center(
                child: Directionality(
                  textDirection: TextDirection.ltr, 
                  child: Row(
                    spacing: 7,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Logo(
                        logoType: LogoType.ygcReports,
                        color: Colors.white,
                        size: 25
                      ),
                      Text(
                        'YGC Reports',
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 1.5,
                        ),
                      )
                    ],
                  )
                ),
              ),
              const SizedBox(height: 32),

              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                child: LanguageSwitcher(),
              ),

              const Spacer(),

              Padding(
                padding: const EdgeInsets.only(bottom: 20.0),
                child: Center(
                  child: GestureDetector(
                    onTap: () async {
                      final Uri url = Uri.parse('https://amtcode.com');
                      if (await canLaunchUrl(url)) {
                        await launchUrl(url, mode: LaunchMode.externalApplication);
                      }
                    },
                    child: const Column(
                      spacing: 10,
                      children: [
                        Logo(
                          logoType: LogoType.amtcode, 
                          color: Colors.white,
                          size: 100,
                        ),
                        Text("From AmtCode", style: TextStyle(color: Colors.grey),),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
