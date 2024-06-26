import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:navbar_router/navbar_router.dart';
import 'package:vocabhub/constants/constants.dart';
import 'package:vocabhub/controller/explore_controller.dart';
import 'package:vocabhub/models/models.dart';
import 'package:vocabhub/navbar/empty_page.dart';
import 'package:vocabhub/pages/addword.dart';
import 'package:vocabhub/services/services.dart';
import 'package:vocabhub/services/services/word_state_service.dart';
import 'package:vocabhub/utils/extensions.dart';
import 'package:vocabhub/utils/utility.dart';
import 'package:vocabhub/widgets/examplebuilder.dart';
import 'package:vocabhub/widgets/responsive.dart';
import 'package:vocabhub/widgets/swipeup.dart';
import 'package:vocabhub/widgets/synonymslist.dart';
import 'package:vocabhub/widgets/widgets.dart';
import 'package:vocabhub/widgets/word_title.dart';
import 'package:vocabhub/widgets/worddetail.dart';

class ExploreWords extends StatelessWidget {
  static const String route = '/';
  final VoidCallback? onScrollThresholdReached;

  const ExploreWords({Key? key, this.onScrollThresholdReached}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(
        desktopBuilder: (context) => ExploreWordsDesktop(),
        mobileBuilder: (context) => ExploreWordsMobile(
              onScrollThresholdReached: () => onScrollThresholdReached!(),
            ));
  }
}

class ExploreWordsMobile extends ConsumerStatefulWidget {
  final VoidCallback? onScrollThresholdReached;

  const ExploreWordsMobile({Key? key, this.onScrollThresholdReached}) : super(key: key);

  @override
  _ExploreWordsMobileState createState() => _ExploreWordsMobileState();
}

class _ExploreWordsMobileState extends ConsumerState<ExploreWordsMobile>
    with SingleTickerProviderStateMixin {
  int page = 0;
  int max = 0;
  bool isFetching = false;
  ExploreController _exploreController = ExploreController();
  ValueNotifier<Response> _request = ValueNotifier<Response>(Response(state: RequestState.none));
  int _scrollCountCallback = 11;
  bool initAnimation = false;
  late AnimationController _progressAnimationController;

  @override
  void initState() {
    super.initState();
    _progressAnimationController = AnimationController(
        vsync: this, duration: Duration(seconds: settingsController.autoScroll.durationInSeconds));
    _listenToIndexChangeEvents();
    _progressAnimationListener();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      exploreWords();
    });
  }

  Future<void> exploreWords() async {
    try {
      _request.value = Response(state: RequestState.active);
      final user = ref.watch(userNotifierProvider);
      final newWords = await exploreController.getExploreWords(user.email, page: page);
      newWords.shuffle();
      max = newWords.length;
      if (mounted) {
        _request.value = _request.value.copyWith(data: newWords, state: RequestState.done);
      }
    } catch (_) {
      if (_.runtimeType == TimeoutException) {
        NavbarNotifier.showSnackBar(context, NETWORK_ERROR, bottom: kNavbarHeight);
        final exploreWords = exploreController.exploreWords;
        if (exploreWords.isNotEmpty) {
          _request.value = _request.value.copyWith(data: exploreWords, state: RequestState.done);
        } else {
          _request.value =
              _request.value.copyWith(state: RequestState.error, message: NETWORK_ERROR);
        }
      } else {
        NavbarNotifier.showSnackBar(context, SOMETHING_WENT_WRONG, bottom: kNavbarHeight);
        _request.value =
            _request.value.copyWith(state: RequestState.error, message: SOMETHING_WENT_WRONG);
      }
    }
  }

  void _listenToIndexChangeEvents() {
    NavbarNotifier.addIndexChangeListener((x) {
      if (x != EXPLORE_INDEX) {
        settingsController.autoScroll = settingsController.autoScroll.copyWith(isPaused: true);
        _progressAnimationController.stop();
      } else {
        if (!initAnimation) {
          _progressAnimationController.forward();
          initAnimation = false;
        }
        if (settingsController.autoScroll.enabled) {
          if (settingsController.autoScroll.isPaused) {
            _progressAnimationController.forward();
          } else {
            restartAnimation();
          }
        } else {
          _removeProgressAnimationListener();
        }
      }
    });
  }

  Future<void> _scrollToNextPage() async {
    exploreController.pageController
        .nextPage(duration: Duration(milliseconds: 1500), curve: Curves.fastOutSlowIn);
  }

  void _progressAnimationListener() {
    _progressAnimationController.addStatusListener((status) {
      if (_progressAnimationController.status == AnimationStatus.completed &&
          settingsController.autoScroll.enabled) {
        _scrollToNextPage();
        _progressAnimationController.reset();
      }
    });
  }

  void _removeProgressAnimationListener() {
    _progressAnimationController.removeStatusListener((status) {});
  }

  void restartAnimation() {
    _progressAnimationController.reset();
    _progressAnimationController.forward();
  }

  @override
  void dispose() {
    _request.dispose();
    _exploreController.dispose();
    _removeProgressAnimationListener();
    _progressAnimationController.dispose();
    NavbarNotifier.removeLastListener();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Response>(
        valueListenable: _request,
        builder: (BuildContext context, Response? request, Widget? child) {
          if (request == null || (request.data == null)) {
            return LoadingWidget();
          } else if ((request.data as List<dynamic>).isEmpty) {
            return Padding(
              padding: 16.0.horizontalPadding,
              child: EmptyPage(
                message: 'Uh oh! Looks like we ran out of words. Try again later.',
              ),
            );
          }
          final words = request.data as List<Word>;
          return Material(
            color: Colors.transparent,
            child: RefreshIndicator(
              onRefresh: () async {
                await exploreWords();
              },
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Column(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTapDown: (x) {
                            _progressAnimationController.stop();
                          },
                          onTapUp: (x) {
                            _progressAnimationController.forward();
                          },
                          child: PageView.builder(
                              itemCount: words.length,
                              controller: exploreController.pageController,
                              scrollBehavior: MaterialScrollBehavior(),
                              onPageChanged: (x) {
                                // if (x > max - 5) {
                                //   page++;
                                //   exploreWords();
                                // }
                                restartAnimation();
                                if (x % _scrollCountCallback == 0) {
                                  widget.onScrollThresholdReached!();
                                }
                                NavbarNotifier.hideSnackBar(context);
                              },
                              physics: ClampingScrollPhysics(),
                              scrollDirection: Axis.vertical,
                              itemBuilder: (context, index) {
                                return ExploreWord(word: words[index], index: index);
                              }),
                        ),
                      ),
                      AnimatedBuilder(
                          animation: _progressAnimationController,
                          builder: (context, child) {
                            return Padding(
                              padding: (kNavbarHeight * 1.2).bottomPadding,
                              child: settingsController.autoScroll.enabled
                                  ? LinearProgressIndicator(
                                      value: _progressAnimationController.value,
                                    )
                                  : SizedBox.shrink(),
                            );
                          }),
                    ],
                  ),
                  Positioned(
                    bottom: kBottomNavigationBarHeight + 50,
                    left: 0,
                    right: 0,
                    child: AnimatedBuilder(
                        animation: exploreController,
                        builder: (context, child) {
                          return exploreController.isAnimating
                              ? SwipeUpAnimation()
                              : SizedBox.shrink();
                        }),
                  ),
                  request.state == RequestState.active
                      ? Positioned(
                          bottom: kBottomNavigationBarHeight + 50,
                          left: 120,
                          child: Text(
                            'Fetching more words',
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: Colors.grey.shade600),
                          ))
                      : SizedBox.shrink(),
                ],
              ),
            ),
          );
        });
  }
}

class ExploreWordsDesktop extends StatefulWidget {
  ExploreWordsDesktop({Key? key}) : super(key: key);

  @override
  State<ExploreWordsDesktop> createState() => _ExploreWordsDesktopState();
}

class _ExploreWordsDesktopState extends State<ExploreWordsDesktop> {
  final focusNode = FocusNode();

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final words = dashboardController.words;
    if (words.isEmpty) return SizedBox.shrink();
    return KeyboardListener(
      focusNode: focusNode,
      autofocus: true,
      onKeyEvent: (event) {
        if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
          exploreController.pageController
              .previousPage(duration: Duration(milliseconds: 500), curve: Curves.easeIn);
        } else if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
          exploreController.pageController
              .nextPage(duration: Duration(milliseconds: 500), curve: Curves.easeIn);
        }
      },
      child: Material(
        child: Stack(
          fit: StackFit.expand,
          children: [
            Padding(
              padding: 40.0.horizontalPadding,
              child: PageView.builder(
                  itemCount: words.length,
                  controller: exploreController.pageController,
                  scrollBehavior: MaterialScrollBehavior(),
                  physics: ClampingScrollPhysics(),
                  onPageChanged: (x) {
                    NavbarNotifier.hideSnackBar(context);
                  },
                  scrollDirection: Axis.horizontal,
                  itemBuilder: (context, index) {
                    return WordDetail(word: words[index]);
                  }),
            ),
            Positioned(
              top: size.height * 0.5,
              left: kNotchedNavbarHeight,
              child: IconButton(
                  icon: Icon(
                    Icons.arrow_back_ios,
                    size: 42,
                  ),
                  onPressed: () => exploreController.pageController
                      .previousPage(duration: Duration(milliseconds: 500), curve: Curves.easeIn)),
            ),
            Positioned(
              top: size.height * 0.5,
              right: kNotchedNavbarHeight,
              child: IconButton(
                  icon: Icon(Icons.arrow_forward_ios, size: 42),
                  onPressed: () => exploreController.pageController
                      .nextPage(duration: Duration(milliseconds: 500), curve: Curves.easeIn)),
            ),
          ],
        ),
      ),
    );
  }
}

class ExploreWord extends ConsumerStatefulWidget {
  final Word? word;
  final int index;
  const ExploreWord({Key? key, this.word, required this.index}) : super(key: key);

  @override
  _ExploreWordState createState() => _ExploreWordState();
}

class _ExploreWordState extends ConsumerState<ExploreWord>
    with SingleTickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  late AnimationController _animationController;
  late Animation<int> _animation;
  late Tween<int> _tween;
  @override
  void initState() {
    super.initState();
    meaning = '';
    lowerIndex = widget.index > 5 ? widget.index - 5 : 0;
    upperIndex = widget.index + 5;
    if (widget.word != null) {
      selectedWord = widget.word!.word;
      meaning = widget.word!.meaning;
      length = widget.word!.meaning.length;
    }

    /// text Animation for word definition
    _animationController = AnimationController(vsync: this, duration: Duration(seconds: 3));
    if (length < 30) {
      _animationController.duration = Duration(seconds: 1);
    } else {
      _animationController.duration = Duration(seconds: 3);
    }
    supaStore = VocabStoreService();
    _tween = IntTween(begin: 0, end: length);
    _animation = _tween.animate(_animationController);
    isHidden = exploreController.isHidden;
    if (!isHidden) {
      _animationController.forward();
    }
  }

  int length = 0;
  int synLength = 0;
  String selectedWord = '';

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant ExploreWord oldWidget) {
    if (!exploreController.isHidden) {
      _animationController.forward();
    }
    super.didUpdateWidget(oldWidget);
  }

  late String meaning;
  late VocabStoreService supaStore;
  int upperIndex = 0;
  int lowerIndex = 0;
  WordState wordState = WordState.unanswered;
  List<Color> backgrounds = [
    Color(0xff989E9C),
    Color(0xffDFD3BB),
    Color(0xffB9B49E),
    Color(0xff72858C),
    Color(0xff30414B),
  ];
  late bool isHidden;
  @override
  Widget build(BuildContext context) {
    super.build(context);
    final userProvider = ref.watch(userNotifierProvider);
    if (!userProvider.isLoggedIn) {
      _animationController.forward();
    }
    return widget.word == null
        ? EmptyWord()
        : AnimatedBuilder(
            animation: exploreController,
            builder: (BuildContext context, Widget? child) {
              return Column(
                children: [
                  kToolbarHeight.vSpacer(),
                  Stack(
                    children: [
                      Padding(
                        padding: (kToolbarHeight * 0.4).topPadding + 12.0.bottomPadding,
                        child: Align(
                          alignment: Alignment.topCenter,
                          child: WordTitleBuilder(
                            word: widget.word!,
                            hasFloatingActionButton: Scaffold.of(context).hasFloatingActionButton,
                          ),
                        ),
                      ),
                      Positioned(
                        top: 10,
                        right: 40,
                        child: userProvider.isLoggedIn && !isHidden
                            ? IconButton(
                                onPressed: () {
                                  Navigate.push(
                                      context,
                                      AddWord(
                                        isEdit: true,
                                        word: widget.word,
                                      ),
                                      transitionType: TransitionType.scale);
                                },
                                icon: Icon(
                                  Icons.edit,
                                  color: Theme.of(context).colorScheme.primary,
                                ))
                            : SizedBox.shrink(),
                      )
                    ],
                  ),
                  (userProvider.isLoggedIn && isHidden)
                      ? IconButton(
                          onPressed: () {
                            setState(() {
                              isHidden = !isHidden;
                            });
                            _animationController.forward();
                          },
                          icon: Icon(
                            Icons.visibility_off,
                          ),
                        )
                      : SizedBox.shrink(),
                  AnimatedOpacity(
                    opacity: !isHidden ? 1 : 0,
                    duration: Duration(milliseconds: 500),
                    child: IgnorePointer(
                      ignoring: isHidden,
                      child: Column(
                        children: [
                          SynonymsList(
                            synonyms: widget.word!.synonyms,
                            emptyHeight: 0,
                            onTap: (synonym) {},
                          ),
                          AnimatedBuilder(
                              animation: _animation,
                              builder: (BuildContext _, Widget? child) {
                                meaning = widget.word!.meaning.substring(0, _animation.value);
                                // if (!exploreController.isHidden) {
                                // } else {
                                //   meaning = widget.word!.meaning;
                                // }
                                return Container(
                                  alignment: Alignment.center,
                                  margin: 24.0.verticalPadding,
                                  padding: 16.0.horizontalPadding,
                                  child: SelectableText(meaning,
                                      textAlign: TextAlign.center,
                                      style: Theme.of(context)
                                          .textTheme
                                          .headlineMedium!
                                          .copyWith(fontSize: 20, fontWeight: FontWeight.w400)),
                                );
                              }),
                          ExampleListBuilder(
                            title: 'Usage',
                            examples:
                                (widget.word!.examples == null || widget.word!.examples!.isEmpty)
                                    ? []
                                    : widget.word!.examples,
                            word: widget.word!.word,
                          ),
                          ExampleListBuilder(
                            title: 'Mnemonics',
                            examples:
                                (widget.word!.mnemonics == null || widget.word!.mnemonics!.isEmpty)
                                    ? []
                                    : widget.word!.mnemonics,
                            word: widget.word!.word,
                          ),
                        ],
                      ),
                    ),
                  ),
                  Flexible(child: SizedBox.expand()),
                  AnimatedBuilder(
                      animation: exploreController,
                      builder: (context, snapshot) {
                        if (userProvider.isLoggedIn && !exploreController.isAnimating) {
                          return WordMasteredPreference(
                            onChanged: (state) async {
                              final wordId = widget.word!.id;
                              final userEmail = userProvider.email;
                              String message = '';
                              if (state) {
                                wordState = WordState.known;
                                message = knownWord;
                              } else {
                                wordState = WordState.unknown;
                                message = unKnownWord;
                              }
                              setState(() {});
                              final resp = await WordStateService.storeWordPreference(
                                  wordId, userEmail, wordState);
                              if (resp.didSucced) {
                                showToast(message);
                              }
                            },
                            value: wordState,
                          );
                        } else {
                          return SizedBox.shrink();
                        }
                      }),
                  16.0.vSpacer()
                ],
              );
            });
  }

  @override
  bool get wantKeepAlive {
    if (widget.index < lowerIndex || widget.index > upperIndex) {
      return false;
    }
    return true;
  }
}

class WordMasteredPreference extends StatefulWidget {
  final WordState value;
  const WordMasteredPreference(
      {Key? key, required this.onChanged, this.value = WordState.unanswered})
      : super(key: key);
  final Function(bool) onChanged;

  @override
  State<WordMasteredPreference> createState() => _WordMasteredPreferenceState();
}

class _WordMasteredPreferenceState extends State<WordMasteredPreference> {
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final bool isMastered = widget.value == WordState.known;
    // final bool unAnswered = widget.value == WordState.unanswered;

    Color stateToColor(WordState state) {
      switch (state) {
        case WordState.unanswered:
          return Colors.grey;
        case WordState.known:
          return colorScheme.primary;
        case WordState.unknown:
          return colorScheme.error;
      }
    }

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Do you know this word?',
                style: Theme.of(context).textTheme.headlineMedium!.copyWith(
                      fontFamily: GoogleFonts.inter(
                        fontWeight: FontWeight.w200,
                      ).fontFamily,
                    )),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Tooltip(
                triggerMode: TooltipTriggerMode.tap,
                preferBelow: false,
                decoration: BoxDecoration(color: colorScheme.tertiaryContainer),
                richMessage: TextSpan(
                    style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                          fontWeight: FontWeight.w200,
                        ),
                    children: [
                      TextSpan(
                        text:
                            'If marked as "yes" this word will be under your mastered list and when marked as "no" it will be under your bookmarks.',
                      ),
                    ]),
                child: Icon(Icons.help),
              ),
            ),
          ],
        ),
        16.0.vSpacer(),
        ToggleButtons(
          borderColor: stateToColor(widget.value),
          selectedBorderColor: stateToColor(widget.value),
          renderBorder: true,
          selectedColor: stateToColor(widget.value),
          // color: isMastered ? colorScheme.primary : colorScheme.error,
          fillColor: stateToColor(widget.value).withOpacity(0.2),
          children: [
            SizedBox(
              width: 120,
              child: Text('Yes',
                  textAlign: TextAlign.center, style: Theme.of(context).textTheme.headlineMedium!),
            ),
            SizedBox(
              width: 120,
              child: Text('No',
                  textAlign: TextAlign.center, style: Theme.of(context).textTheme.headlineMedium!),
            ),
          ],
          isSelected: [isMastered, !isMastered],
          onPressed: (int index) {
            if (widget.value == WordState.known && index == 0) return;
            if (widget.value == WordState.unknown && index == 1) return;
            widget.onChanged(index == 0);
          },
        ),
      ],
    );
  }
}
