import 'package:flutter/material.dart';
import 'package:vocabhub/pages/login.dart';
import 'package:vocabhub/services/appstate.dart';
import 'package:vocabhub/services/services/user.dart';
import 'package:vocabhub/utils/navigator.dart';
import 'package:vocabhub/utils/utils.dart';
import 'package:vocabhub/widgets/button.dart';
import 'package:vocabhub/widgets/circle_avatar.dart';
import 'package:vocabhub/widgets/icon.dart';
import 'package:vocabhub/widgets/responsive.dart';

class UserProfile extends StatefulWidget {
  static const String route = '/';
  const UserProfile({Key? key}) : super(key: key);

  @override
  State<UserProfile> createState() => _UserProfileState();
}

class _UserProfileState extends State<UserProfile> {
  @override
  void initState() {
    super.initState();
    getUser();
  }

  Future<void> getUser() async {
    await Duration.zero;
    final _userStore = UserService();
    final userState = AppStateScope.of(context).user;
    if (userState!.isLoggedIn) {
      final user = await _userStore.findByEmail(email: userState.email);
      if (user.email.isNotEmpty) {
        AppStateWidget.of(context).setUser(user);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(
        desktopBuilder: (context) => UserProfileMobile(),
        mobileBuilder: (context) => UserProfileMobile());
  }
}

class UserProfileMobile extends StatefulWidget {
  const UserProfileMobile({Key? key}) : super(key: key);

  @override
  State<UserProfileMobile> createState() => _UserProfileMobileState();
}

class _UserProfileMobileState extends State<UserProfileMobile> {
  bool isLoading = false;
  @override
  Widget build(BuildContext context) {
    final user = AppStateScope.of(context).user;
    return Scaffold(
        body: Center(
            child: user == null || !user.isLoggedIn
                ? VocabButton(
                    onTap: () {
                      Navigate.push(context, AppSignIn());
                    },
                    label: 'Sign In')
                : Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: kBottomNavigationBarHeight * 1.2),
                    child: Column(
                      children: [
                        Stack(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: CircleAvatar(
                                  radius: 46,
                                  backgroundColor: Theme.of(context)
                                      .colorScheme
                                      .primary
                                      .withOpacity(0.2),
                                  child: CircularAvatar(
                                    url: '${user.avatarUrl}',
                                    radius: 40,
                                  )),
                            ),
                            Positioned(
                                right: 8,
                                bottom: 16,
                                child: VHIcon(
                                  Icons.edit,
                                  size: 30,
                                  onTap: () {
                                    print('tapped icon');
                                  },
                                ))
                          ],
                        ),
                        Padding(
                            padding: const EdgeInsets.all(8.0),
                            child:
                                Text(!user.isAdmin ? ' User 🔒' : 'Admin 🔑')),
                        RichText(
                            text: TextSpan(children: [
                          TextSpan(
                              text: 'Joined on ',
                              style: Theme.of(context)
                                  .textTheme
                                  .subtitle2!
                                  .copyWith(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 12)),
                          TextSpan(
                            text: user.created_at!.formatDate(),
                            style: Theme.of(context)
                                .textTheme
                                .subtitle2!
                                .copyWith(fontWeight: FontWeight.w600),
                          ),
                        ])),
                        Text(
                          '${user.name}',
                          style: Theme.of(context)
                              .textTheme
                              .headline4!
                              .copyWith(
                                  fontSize: 32, fontWeight: FontWeight.w500),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        Spacer(),
                        VocabButton(
                          label: 'Sign Out',
                          height: 50,
                          isLoading: isLoading,
                          onTap: () async {
                            setState(() {
                              isLoading = true;
                            });
                            await Settings.clear();
                            await UserService().updateLogin(
                                email: user.email, isLoggedIn: false);
                            Navigate().pushAndPopAll(context, AppSignIn());
                          },
                        ),
                        SizedBox(
                          height: kBottomNavigationBarHeight,
                        )
                      ],
                    ),
                  )));
  }
}

class UserProfileDesktop extends StatelessWidget {
  const UserProfileDesktop({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile Desktop'),
      ),
      body: ListView.builder(
          padding: EdgeInsets.zero,
          itemCount: 20,
          itemBuilder: (BuildContext context, int x) {
            return ListTile(
              title: Text('item $x'),
            );
          }),
    );
  }
}
