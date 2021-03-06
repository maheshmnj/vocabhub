import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vocabhub/exports.dart';
import 'package:vocabhub/models/user.dart';
import 'package:vocabhub/pages/home.dart';
import 'package:vocabhub/pages/login.dart';
import 'package:vocabhub/utils/navigator.dart';
import 'package:vocabhub/utils/settings.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    duration: const Duration(seconds: 2),
    vsync: this,
  );

  late final Animation<double> _animation = Tween<double>(
    begin: 0.0,
    end: 1.0,
  ).animate(CurvedAnimation(
    parent: _controller,
    curve: Curves.bounceIn,
  ));

  @override
  void initState() {
    super.initState();
    _controller.forward();
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        handleNavigation();
      }
    });
  }

  Future<void> handleNavigation() async {
    final user = Provider.of<UserModel>(context, listen: false);
    final bool signedIn = await Settings().isSignedIn;
    final String _email = await Settings().email;
    final int count = await Settings().skipCount;
    user.email = _email;
    if (signedIn && _email.isNotEmpty) {
      user.isLoggedIn = true;
      Navigate().pushAndPopAll(context, MyHomePage(title: '$APP_TITLE'),
          slideTransitionType: SlideTransitionType.ttb);
    } else {
      user.isLoggedIn = false;
      if (count > 0) {
        Navigate().pushAndPopAll(context, MyHomePage(title: '$APP_TITLE'),
            slideTransitionType: SlideTransitionType.ttb);
        Settings().setSkipCount = count - 1;
      } else {
        Navigate().pushAndPopAll(context, AppSignIn());
      }
    }
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Settings.size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                primaryColor.withOpacity(0.5),
                secondaryColor,
              ]),
        ),
        alignment: Alignment.center,
        child: ScaleTransition(
            // position: _offsetAnimation,
            scale: _animation,
            child: Stack(
              children: [
                Positioned(
                  top: 4,
                  left: 2,
                  child: Text('Vocabhub',
                      style: Theme.of(context)
                          .textTheme
                          .headline2!
                          .copyWith(color: Colors.grey)),
                ),
                Text('Vocabhub', style: Theme.of(context).textTheme.headline2),
              ],
            )),
      ),
    );
  }
}
