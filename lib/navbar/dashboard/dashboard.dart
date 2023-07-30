import 'dart:async';
import 'dart:math';

import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:navbar_router/navbar_router.dart';
import 'package:vocabhub/exports.dart';
import 'package:vocabhub/models/word.dart';
import 'package:vocabhub/navbar/dashboard/bookmarks.dart';
import 'package:vocabhub/navbar/error_page.dart';
import 'package:vocabhub/pages/login.dart';
import 'package:vocabhub/pages/notifications/notifications.dart';
import 'package:vocabhub/services/analytics.dart';
import 'package:vocabhub/services/services.dart';
import 'package:vocabhub/utils/utility.dart';
import 'package:vocabhub/widgets/responsive.dart';
import 'package:vocabhub/widgets/widgets.dart';
import 'package:vocabhub/widgets/worddetail.dart';

class Dashboard extends ConsumerStatefulWidget {
  static String route = '/';
  const Dashboard({Key? key}) : super(key: key);

  @override
  ConsumerState<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends ConsumerState<Dashboard> {
  @override
  void initState() {
    _dashBoardNotifier = ValueNotifier(response);
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      publishWordOfTheDay();
    });
    super.initState();
  }

  /// get latest word of the day sort by descending order of created_at
  /// check current DateTime UTC and compare with the latest word of the day
  /// if the date is same, then don't publish a new word of the day
  /// else publish a new word of the day

  /// todo word of the day
  Future<void> publishWordOfTheDay({bool isRefresh = false}) async {
    _dashBoardNotifier.value = response.copyWith(state: RequestState.active, message: "Loading...");
    try {
      // If word of the day already published then get word of the day
      if (dashboardController.isWodPublishedToday) {
        if (isRefresh) {
          final word = await dashboardController.getLastPublishedWord();
          dashboardController.wordOfTheDay = word;
          _dashBoardNotifier.value = response.copyWith(data: word, state: RequestState.done);
          return;
        }
        final publishedWod = dashboardController.wordOfTheDay;
        _dashBoardNotifier.value = response.copyWith(data: publishedWod, state: RequestState.done);
        return;
      }
      final allWords = dashboardController.words;
      final random = Random();
      final randomWord = allWords[random.nextInt(allWords.length)];
      final success = await dashboardController.publishWod(randomWord);
      if (success) {
        _dashBoardNotifier.value = response.copyWith(state: RequestState.done);
      } else {
        NavbarNotifier.showSnackBar(context, "Something went wrong!");
        _dashBoardNotifier.value =
            response.copyWith(state: RequestState.error, message: "Something went wrong!");
      }
    } catch (e) {
      NavbarNotifier.showSnackBar(context, NETWORK_ERROR, bottom: 0);
      _dashBoardNotifier.value =
          response.copyWith(state: RequestState.error, message: e.toString());
    }
  }

  late final ValueNotifier<Response> _dashBoardNotifier;
  final response = Response.init();

  @override
  void dispose() {
    _dashBoardNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
        child: ValueListenableBuilder<Response>(
            valueListenable: _dashBoardNotifier,
            builder: (context, response, child) {
              if (response.state == RequestState.error) {
                return ErrorPage(
                  onRetry: () async {
                    await publishWordOfTheDay(isRefresh: true);
                  },
                  errorMessage: response.message,
                );
              }
              return ResponsiveBuilder(
                desktopBuilder: (context) => DashboardDesktop(),
                mobileBuilder: (context) {
                  if (response.state == RequestState.active) {
                    return LoadingWidget();
                  }
                  return RefreshIndicator(
                      onRefresh: () async {
                        await publishWordOfTheDay(isRefresh: true);
                      },
                      child: DashboardMobile());
                },
              );
            }));
  }
}

class DashboardMobile extends ConsumerWidget {
  static String route = '/';
  DashboardMobile({Key? key}) : super(key: key);
  final analytics = Analytics.instance;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userNotifierProvider);
    final word = dashboardController.wordOfTheDay;
    return CustomScrollView(
      scrollBehavior: const MaterialScrollBehavior().copyWith(overscroll: true),
      physics: BouncingScrollPhysics(
        parent: AlwaysScrollableScrollPhysics(),
      ),
      slivers: <Widget>[
        SliverAppBar(
            pinned: false,
            expandedHeight: 80.0,
            flexibleSpace: FlexibleSpaceBar(
              centerTitle: true,
              background: Container(
                alignment: Alignment.centerLeft,
                padding: EdgeInsets.only(left: 16, top: 16),
                child: Text(
                  'Dashboard',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.w400),
                ),
              ),
            ),
            actions: [
              user.isLoggedIn && SizeUtils.isMobile
                  ? IconButton(
                      onPressed: () {
                        Navigate.pushNamed(context, Notifications.route, isRootNavigator: true);
                      },
                      icon: Icon(
                        Icons.notifications_on,
                        color: Theme.of(context).colorScheme.primary.withOpacity(0.6),
                      ))
                  : SizedBox.shrink(),
              !user.isLoggedIn
                  ? TextButton(
                      onPressed: () async {
                        await Navigate.pushAndPopAll(context, AppSignIn());
                      },
                      child: Text('Sign In',
                          style: Theme.of(context)
                              .textTheme
                              .bodyLarge!
                              .copyWith(color: Theme.of(context).colorScheme.primary)))
                  : SizedBox.shrink()
            ]),
        SliverToBoxAdapter(
          child: Padding(
            padding: 16.0.horizontalPadding,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: 16.0.verticalPadding,
                  child: heading('Word of the day'),
                ),
                OpenContainer<bool>(
                    openBuilder: (BuildContext context, VoidCallback openContainer) {
                      return WordDetail(
                        word: word,
                        isWod: true,
                        title: 'Word of the Day',
                      );
                    },
                    tappable: true,
                    closedShape: 16.0.rounded,
                    transitionType: ContainerTransitionType.fadeThrough,
                    closedBuilder: (BuildContext context, VoidCallback openContainer) {
                      return WoDCard(
                        word: word,
                        color: Colors.green.shade300,
                        title: '${word.word}'.toUpperCase(),
                      );
                    }),
                Padding(
                  padding: 6.0.verticalPadding,
                ),
                !user.isLoggedIn
                    ? SizedBox.shrink()
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: 12.0.verticalPadding,
                            child: heading('Progress'),
                          ),
                          word.word.isEmpty
                              ? SizedBox.shrink()
                              : OpenContainer<bool>(
                                  openBuilder: (BuildContext context, VoidCallback openContainer) {
                                    return BookmarksPage(
                                      isBookMark: true,
                                      user: user,
                                    );
                                  },
                                  closedShape: 16.0.rounded,
                                  tappable: true,
                                  transitionType: ContainerTransitionType.fadeThrough,
                                  closedBuilder:
                                      (BuildContext context, VoidCallback openContainer) {
                                    return WoDCard(
                                      word: word,
                                      height: 180,
                                      fontSize: 42,
                                      color: Colors.amberAccent.shade400,
                                      title: 'Bookmarks',
                                    );
                                  }),
                          Padding(
                            padding: 6.0.verticalPadding,
                          ),
                          OpenContainer<bool>(
                              openBuilder: (BuildContext context, VoidCallback openContainer) {
                                return BookmarksPage(
                                  isBookMark: false,
                                  user: user,
                                );
                              },
                              tappable: true,
                              closedShape: 16.0.rounded,
                              transitionType: ContainerTransitionType.fadeThrough,
                              closedBuilder: (BuildContext context, VoidCallback openContainer) {
                                return WoDCard(
                                  word: word,
                                  height: 180,
                                  fontSize: 42,
                                  image: 'assets/dart.jpg',
                                  title: 'Mastered\nWords',
                                );
                              })
                        ],
                      ),
                100.0.vSpacer()
              ],
            ),
          ),
        )
      ],
    );
  }
}

class WoDCard extends StatelessWidget {
  final Word? word;
  final String title;
  final Color? color;
  final double? height;
  final double? width;
  final String? image;
  final double fontSize;

  const WoDCard(
      {super.key,
      this.word,
      this.height,
      this.width,
      required this.title,
      this.color,
      this.fontSize = 40,
      this.image});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Container(
      height: height ?? size.height / 3,
      width: width ?? size.width,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16.0),
          color: this.color,
          image: image != null
              ? DecorationImage(
                  fit: BoxFit.fill, opacity: 0.9, image: AssetImage('assets/dart.jpg'))
              : null),
      child: Align(
          alignment: Alignment.center,
          child: Text(
            '$title',
            textAlign: TextAlign.center,
            style: Theme.of(context)
                .textTheme
                .displaySmall!
                .copyWith(color: Theme.of(context).colorScheme.onPrimary, fontSize: fontSize),
          )),
    );
  }
}

class DashboardDesktop extends ConsumerWidget {
  static String route = '/';
  const DashboardDesktop({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // final dashBoardRef = ref.watch(dashBoardNotifier);
    final colorScheme = Theme.of(context).colorScheme;
    final word = dashboardController.wordOfTheDay;
    final user = ref.watch(userNotifierProvider);
    return Scaffold(
      backgroundColor: colorScheme.background,
      body: Padding(
        padding: 16.0.horizontalPadding,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
                flex: 3,
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Padding(
                    padding: 16.0.verticalPadding,
                    child: heading('Word of the day'),
                  ),
                  OpenContainer<bool>(
                      openBuilder: (BuildContext context, VoidCallback openContainer) {
                        return WordDetail(
                          word: word,
                          isWod: true,
                          title: 'Word of the Day',
                        );
                      },
                      tappable: true,
                      closedShape: 16.0.rounded,
                      transitionType: ContainerTransitionType.fadeThrough,
                      closedBuilder: (BuildContext context, VoidCallback openContainer) {
                        return WoDCard(
                          word: word,
                          color: Colors.green.shade300,
                          title: '${word.word}'.toUpperCase(),
                        );
                      }),
                  Padding(
                    padding: 12.0.verticalPadding,
                    child: heading('Progress'),
                  ),
                  Padding(
                    padding: 6.0.verticalPadding,
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: OpenContainer<bool>(
                            openBuilder: (BuildContext context, VoidCallback openContainer) {
                              return BookmarksPage(
                                isBookMark: false,
                                user: user,
                              );
                            },
                            tappable: true,
                            closedShape: 16.0.rounded,
                            transitionType: ContainerTransitionType.fadeThrough,
                            closedBuilder: (BuildContext context, VoidCallback openContainer) {
                              return WoDCard(
                                word: word,
                                height: 180,
                                fontSize: 42,
                                image: 'assets/dart.jpg',
                                title: 'Mastered\nWords',
                              );
                            }),
                      ),
                      16.0.hSpacer(),
                      Expanded(
                        child: OpenContainer<bool>(
                            openBuilder: (BuildContext context, VoidCallback openContainer) {
                              return BookmarksPage(
                                isBookMark: true,
                                user: user,
                              );
                            },
                            closedShape: 16.0.rounded,
                            tappable: true,
                            transitionType: ContainerTransitionType.fadeThrough,
                            closedBuilder: (BuildContext context, VoidCallback openContainer) {
                              return WoDCard(
                                word: word,
                                height: 180,
                                fontSize: 42,
                                color: Colors.amberAccent.shade400,
                                title: 'Bookmarks',
                              );
                            }),
                      ),
                    ],
                  )
                ])
                //  Container(
                //   alignment: Alignment.center,
                //   child: SizedBox(
                //     width: 600,
                //     child: DashboardMobile(),
                //   ),
                ),
            Expanded(flex: 2, child: Notifications()),
          ],
        ),
      ),
    );
  }
}
