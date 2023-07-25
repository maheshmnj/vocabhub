import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:navbar_router/navbar_router.dart';
import 'package:vocabhub/base_home.dart';
import 'package:vocabhub/main.dart';
import 'package:vocabhub/pages/login.dart';
import 'package:vocabhub/utils/utils.dart';
import 'package:vocabhub/widgets/button.dart';

import 'onboard.dart';

class WelcomePage extends ConsumerStatefulWidget {
  final String title;
  final String description;

  const WelcomePage({
    Key? key,
    required this.title,
    required this.description,
  }) : super(key: key);

  @override
  ConsumerState<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends ConsumerState<WelcomePage> {
  Future<void> startOnBoarding() async {}

  bool isLoading = false;
  String title = 'Welcome to Vocabhub';
  @override
  Widget build(BuildContext context) {
    final user = ref.watch(userNotifierProvider);
    return Material(
      child: Container(
        color: Colors.black,
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                    text: title.split(' ')[0],
                    style: GoogleFonts.quicksand(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Color.fromARGB(255, 87, 169, 110),
                    ),
                    children: [
                      TextSpan(
                        text: '\n${title.split(' ')[1]}',
                        style: GoogleFonts.quicksand(
                          fontSize: 40,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      TextSpan(
                        text: '\n${title.split(' ')[2]}',
                        style: GoogleFonts.quicksand(
                          fontSize: 38,
                          fontWeight: FontWeight.bold,
                          color: Color.fromARGB(255, 243, 255, 106),
                        ),
                      )
                    ]),
              ),
            ),
            Column(
              children: [
                VHButton(
                    width: 160,
                    onTap: () {
                      Navigate.push(context, OnboardingPage(),
                          transitionDuration: Duration(milliseconds: 500),
                          transitionType: TransitionType.reveal);
                    },
                    label: 'Take a tour'),
                16.0.vSpacer(),
                VHButton(
                    width: 200,
                    onTap: () {
                      if (user.isLoggedIn) {
                        Navigate.pushAndPopAll(context, AdaptiveLayout());
                      } else {
                        Navigate.push(context, AppSignIn(), transitionType: TransitionType.scale);
                      }
                    },
                    label: 'Skip for now'),
              ],
            )
          ],
        ),
      ),
    );
  }
}
