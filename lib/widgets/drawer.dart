import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:vocabhub/constants/constants.dart';
import 'package:vocabhub/utils/utils.dart';

bool isAnimated = false;

// class DrawerBuilder extends ConsumerStatefulWidget {
//   final Function(String)? onMenuTap;

//   const DrawerBuilder({Key? key, this.onMenuTap}) : super(key: key);

//   @override
//   _DrawerBuilderState createState() => _DrawerBuilderState();
// }

// class _DrawerBuilderState extends ConsumerState<DrawerBuilder> {
//   Widget subTitle(String text) {
//     return Text(
//       '$text',
//       style: VocabTheme.listSubtitleStyle,
//     );
//   }

//   Widget title(String text) {
//     return Text(
//       '$text',
//       style: Theme.of(context).textTheme.headlineSmall,
//     );
//   }

//   @override
//   void dispose() {
//     isAnimated = true;
//     super.dispose();
//   }

//   Widget _avatar(UserModel user) {
//     if (user.email.isEmpty) {
//       return CircularAvatar(
//         url: '${Constants.PROFILE_AVATAR_ASSET}',
//         radius: 35,
//       );
//     } else {
//       return CircularAvatar(
//         name: getInitial('${user.name}'),
//         url: user.avatarUrl,
//         radius: 35,
//         onTap: null,
//       );
//     }
//   }

//   Future<void> downloadFile() async {
//     try {
//       final success = await VocabStoreService().downloadFile();
//       if (success) {
//         NavbarNotifier.showSnackBar(context, 'Downloaded successfully!');
//       } else {
//         NavbarNotifier.showSnackBar(context, 'Failed to Download');
//       }
//     } catch (x) {
//       NavbarNotifier.showSnackBar(context, '$x');
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final userProvider = ref.watch(userNotifierProvider);
//     Widget trailingIcon(IconData data) {
//       return Icon(
//         data,
//       );
//     }

//     final appThemeController = ref.watch(appThemeProvider);
//     final bool isAdmin = (userProvider.isLoggedIn && userProvider.isAdmin);

//     return Drawer(
//       child: Container(
//         child: Column(
//           children: [
//             Container(
//               padding: EdgeInsets.symmetric(vertical: 16, horizontal: 8),
//               height: 150,
//               child: Row(
//                 crossAxisAlignment: CrossAxisAlignment.center,
//                 children: [
//                   _avatar(userProvider),
//                   (userProvider.isLoggedIn ? 20.0 : 30.0).hSpacer(),
//                   Flexible(
//                     child: GestureDetector(
//                         onTap: () {
//                           if (!userProvider.isLoggedIn) {
//                             Navigate.popView(context);
//                             widget.onMenuTap?.call('Sign In');
//                           }
//                         },
//                         child: Text(userProvider.isLoggedIn ? '${userProvider.name}' : 'Sign In',
//                             style: Theme.of(context)
//                                 .textTheme
//                                 .headlineMedium!
//                                 .copyWith(fontWeight: FontWeight.w500))),
//                   ),
//                 ],
//               ),
//             ),
//             hLine(),
//             ListTile(
//               onTap: () {
//                 launchURL(Constants.REPORT_URL);
//               },
//               subtitle: subTitle(
//                 'Report a bug or Request a feature',
//               ),
//               trailing: trailingIcon(Icons.bug_report),
//               title: title(
//                 'Report',
//               ),
//             ),
//             hLine(),
//             ListTile(
//               onTap: () {
//                 Navigate.popView(context);
//                 Navigate.push(context, AddWordForm(), transitionType: TransitionType.btt);
//               },
//               trailing: trailingIcon(
//                 Icons.add,
//               ),
//               title: title(
//                 'Add a word',
//               ),
//               subtitle: subTitle('Can\'t find a word?'),
//             ),
//             hLine(),
//             ListTile(
//               subtitle: subTitle('The code to this app is Open Sourced'),
//               onTap: () {
//                 launchURL(Constants.SOURCE_CODE_URL);
//               },
//               title: title(
//                 'Source code',
//               ),
//               trailing: Image.asset(
//                 appThemeController.isDark ? GITHUB_WHITE_ASSET_PATH : GITHUB_ASSET_PATH,
//                 width: 26,
//               ),
//             ),
//             isAdmin ? hLine() : SizedBox(),
//             isAdmin
//                 ? ListTile(
//                     subtitle: subTitle('Downlod the data as json'),
//                     onTap: () async {
//                       await Navigate.popView(context);
//                       downloadFile();
//                     },
//                     title: title(
//                       'Download file',
//                     ),
//                     trailing: trailingIcon(Icons.download),
//                   )
//                 : SizedBox.shrink(),
//             hLine(),
//             ListTile(
//               onTap: () {
//                 launchURL(Constants.PRIVACY_POLICY);
//               },
//               trailing: trailingIcon(Icons.privacy_tip),
//               title: title(
//                 'Privacy Policy',
//               ),
//               subtitle: subTitle(''),
//             ),
//             hLine(),
//             userProvider.isLoggedIn
//                 ? ListTile(
//                     onTap: () {
//                       Navigate.popView(context);
//                       widget.onMenuTap!('Sign Out');
//                     },
//                     trailing: trailingIcon(Icons.exit_to_app),
//                     title: title(
//                       'Sign Out',
//                     ),
//                     subtitle: subTitle(''),
//                   )
//                 : Container(),
//             !userProvider.isLoggedIn ? Container() : hLine(),
//             Expanded(child: Container()),
//             hLine(),
//             WordsCountAnimator(
//               isAnimated: isAnimated,
//             ),
//             20.0.hSpacer(),
//             if (kIsWeb) storeRedirect(context),
//             Container(
//               height: 60,
//               alignment: Alignment.center,
//               child: VersionBuilder(),
//             )
//           ],
//         ),
//       ),
//     );
//   }
// }

class VersionBuilder extends StatelessWidget {
  final String version;
  const VersionBuilder({Key? key, this.version = ''}) : super(key: key);

  Future<String> getAppDetails() async {
    final packageInfo = await PackageInfo.fromPlatform();
    return packageInfo.version; // + ' (' + packageInfo.buildNumber + ')';
  }

  @override
  Widget build(BuildContext context) {
    return Center(
        child: Container(
      alignment: Alignment.center,
      child: FutureBuilder<String>(
          future: getAppDetails(),
          builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
            return Column(
              children: [
                snapshot.data == null
                    ? Text('${Constants.VERSION}', style: Theme.of(context).textTheme.bodySmall)
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('v', style: Theme.of(context).textTheme.bodySmall),
                          Text(snapshot.data!, style: Theme.of(context).textTheme.bodySmall),
                        ],
                      ),
                16.0.vSpacer(),
                Text('Made with ❤️ in India', style: Theme.of(context).textTheme.bodySmall),
                // copyRightText(),
                Text('© 2022 ${Constants.ORGANIZATION}',
                    style: Theme.of(context).textTheme.bodySmall),
              ],
            );
          }),
    ));
  }
}
