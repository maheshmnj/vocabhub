import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vocabhub/exports.dart';
import 'package:vocabhub/models/notification.dart';
import 'package:vocabhub/navbar/error_page.dart';
import 'package:vocabhub/navbar/pageroute.dart';
import 'package:vocabhub/navbar/profile/edit.dart';
import 'package:vocabhub/navbar/profile/settings.dart';
import 'package:vocabhub/services/services.dart';
import 'package:vocabhub/utils/utility.dart';
import 'package:vocabhub/widgets/circle_avatar.dart';
import 'package:vocabhub/widgets/icon.dart';
import 'package:vocabhub/widgets/responsive.dart';
import 'package:vocabhub/widgets/widgets.dart';

class UserProfile extends ConsumerStatefulWidget {
  static const String route = '/';
  const UserProfile({Key? key}) : super(key: key);

  @override
  _UserProfileState createState() => _UserProfileState();
}

class _UserProfileState extends ConsumerState<UserProfile> {
  @override
  void initState() {
    super.initState();
    userProfileNotifier = ValueNotifier<Response>(response);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // getUser();
    });
  }

  // Future<void> getUser() async {
  //   try {
  //     final userState = ref.watch(userNotifierProvider);

  //     if (userState.isLoggedIn) {
  //       final user = await UserService.findByEmail(email: userState.email);
  //       if (user.email.isNotEmpty) {
  //         AppStateWidget.of(context).setUser(user);
  //         userProfileNotifier.value = response.copyWith(didSucced: true, data: user);
  //       }
  //     }
  //   } on Exception catch (_) {
  //     NavbarNotifier.showSnackBar(context, _.toString());
  //     userProfileNotifier.value =
  //         response.copyWith(didSucced: false, message: _.toString(), state: RequestState.error);
  //   } catch (_) {
  //     userProfileNotifier.value =
  //         response.copyWith(didSucced: false, message: _.toString(), state: RequestState.error);
  //   }
  // }

  late final ValueNotifier<Response> userProfileNotifier;
  final response = Response.init();

  @override
  void dispose() {
    userProfileNotifier.dispose();
    super.dispose();
  }

  Future<void> _retry() async {
    userProfileNotifier.value =
        response.copyWith(state: RequestState.active, message: "Loading...");
    final user = ref.watch(userNotifierProvider);
    final updatedUser = await UserService.findByEmail(email: user.email, cache: true);
    user.setUser(updatedUser);
    userProfileNotifier.value = response.copyWith(
        state: RequestState.done, message: "Success", data: updatedUser, didSucced: true);
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: ValueListenableBuilder<Response>(
          valueListenable: userProfileNotifier,
          builder: (context, response, child) {
            if (response.state == RequestState.error) {
              return ErrorPage(
                onRetry: _retry,
                errorMessage: response.message,
              );
            }
            return ResponsiveBuilder(
                desktopBuilder: (context) => UserProfileDesktop(),
                mobileBuilder: (context) {
                  if (response.state == RequestState.active) {
                    return LoadingWidget();
                  }
                  return UserProfileMobile(
                    onRefresh: () async {
                      await _retry();
                    },
                  );
                });
          }),
    );
  }
}

class UserProfileMobile extends ConsumerStatefulWidget {
  const UserProfileMobile({Key? key, this.onRefresh}) : super(key: key);
  final VoidCallback? onRefresh;

  @override
  _UserProfileMobileState createState() => _UserProfileMobileState();
}

class _UserProfileMobileState extends ConsumerState<UserProfileMobile> {
  Future<void> getEditStats() async {
    final user = ref.watch(userNotifierProvider);
    final resp = await EditHistoryService.getUserContributions(user);
    stats = [0, 0, 0];
    if (resp.didSucced && resp.data != null) {
      final editHistory = resp.data as List<NotificationModel>;
      for (var history in editHistory) {
        if (history.edit.state == EditState.approved) {
          if (history.edit.edit_type == EditType.add) {
            stats[0]++;
          } else if (history.edit.edit_type == EditType.edit) {
            stats[1]++;
          }
        } else if (history.edit.state == EditState.pending) {
          stats[2]++;
        }
      }
    }
    if (mounted) {
      _statsNotifier.value = stats;
    }
  }

  List<int> stats = [0, 0, 0];

  @override
  void initState() {
    _statsNotifier = ValueNotifier<List<int>>(stats);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      getEditStats();
    });
    super.initState();
  }

  @override
  void dispose() {
    _statsNotifier.dispose();
    super.dispose();
  }

  late ValueNotifier<List<int>> _statsNotifier;
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey = GlobalKey<RefreshIndicatorState>();

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(userNotifierProvider);
    final size = MediaQuery.of(context).size;
    final colorScheme = Theme.of(context).colorScheme;
    return ValueListenableBuilder<List<int>>(
        valueListenable: _statsNotifier,
        builder: (BuildContext context, List<int> stats, Widget? child) {
          return RefreshIndicator(
            key: _refreshIndicatorKey,
            onRefresh: () async {
              await getEditStats();
              if (widget.onRefresh != null) {
                widget.onRefresh!();
              }
              setState(() {});
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
              child: ListView(
                children: [
                  Container(
                    decoration: BoxDecoration(
                        borderRadius: 16.0.allRadius,
                        border: Border.all(color: colorScheme.secondary)),
                    child: Align(
                      alignment: Alignment.center,
                      child: Padding(
                        padding: 18.0.verticalPadding,
                        child: Column(
                          children: [
                            // Container(
                            //     alignment: Alignment.topRight,
                            //     padding: EdgeInsets.only(right: 16),
                            //     child: IconButton(
                            //       onPressed: () {
                            //         if (VocabTheme.isDark) {
                            //           Settings.setTheme(ThemeMode.light);
                            //         } else {
                            //           Settings.setTheme(ThemeMode.dark);
                            //         }
                            //       },
                            //       icon: VocabTheme.isDark
                            //           ? const Icon(Icons.light_mode)
                            //           : const Icon(Icons.dark_mode),
                            //     )),
                            size.width > 600
                                ? SizedBox.shrink()
                                : Container(
                                    alignment: Alignment.topRight,
                                    child: Padding(
                                      padding: 16.0.horizontalPadding,
                                      child: VHIcon(
                                        Icons.settings,
                                        size: 38,
                                        onTap: () {
                                          Navigator.of(context, rootNavigator: true).push(
                                              PageRoutes.sharedAxis(const SettingsPageMobile(),
                                                  SharedAxisTransitionType.horizontal));
                                        },
                                      ),
                                    ),
                                  ),

                            Stack(
                              children: [
                                Padding(
                                  padding: 16.0.allPadding,
                                  child: CircleAvatar(
                                      radius: 46,
                                      backgroundColor: colorScheme.primary.withOpacity(0.2),
                                      child: CircularAvatar(
                                        url: '${user!.avatarUrl}',
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
                                        Navigator.of(context, rootNavigator: true)
                                            .push(PageRoutes.sharedAxis(
                                                EditProfile(
                                                  user: user,
                                                  onClose: () async {
                                                    setState(() {});
                                                  },
                                                ),
                                                SharedAxisTransitionType.scaled));
                                      },
                                    ))
                              ],
                            ),
                            Padding(
                                padding: 8.0.horizontalPadding,
                                child: Text(
                                    '@${user.username} ${!user.isAdmin ? ' (User)' : '(Admin)'}')),
                            Text(
                              '${user.name.capitalize()}',
                              textAlign: TextAlign.center,
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineMedium!
                                  .copyWith(fontSize: 26, fontWeight: FontWeight.w500),
                            ),
                            10.0.vSpacer(),
                            RichText(
                                text: TextSpan(children: [
                              TextSpan(
                                  text: 'Joined ',
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleSmall!
                                      .copyWith(fontWeight: FontWeight.w600, fontSize: 12)),
                              TextSpan(
                                text: user.created_at!.formatDate(),
                                style: Theme.of(context)
                                    .textTheme
                                    .titleSmall!
                                    .copyWith(fontWeight: FontWeight.w600),
                              ),
                            ])),
                          ],
                        ),
                      ),
                    ),
                  ),
                  16.0.vSpacer(),
                  Container(alignment: Alignment.centerLeft, child: heading('Contributions')),
                  16.0.vSpacer(),

                  /// rounded Container with border

                  Container(
                    height: 80,
                    decoration: BoxDecoration(
                        borderRadius: 16.0.allRadius,
                        border: Border.all(color: colorScheme.secondary)),
                    child: Row(
                      children: [
                        for (int i = 0; i < stats.length; i++)
                          Expanded(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  '${stats[i]}',
                                  style: Theme.of(context)
                                      .textTheme
                                      .headlineMedium!
                                      .copyWith(fontSize: 28, fontWeight: FontWeight.w500),
                                ),
                                4.0.vSpacer(),
                                Text(
                                  i == 0
                                      ? 'Words Added'
                                      : i == 1
                                          ? 'Words Edited'
                                          : 'Under Review',
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleSmall!
                                      .copyWith(fontSize: 12, fontWeight: FontWeight.w600),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  )
                ],
              ),
            ),
          );
        });
  }
}

class UserProfileDesktop extends StatelessWidget {
  const UserProfileDesktop({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        title: Text('Profile'),
      ),
      body: Row(
        children: [
          Expanded(child: UserProfileMobile()),
          Expanded(child: SettingsPageMobile()),
        ],
      ),
    );
  }
}
