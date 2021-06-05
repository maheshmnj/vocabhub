import 'package:flutter/material.dart';
import 'package:vocabhub/models/word_model.dart';
import 'package:vocabhub/services/supastore.dart';
import 'package:vocabhub/widgets/synonymslist.dart';
import 'package:vocabhub/widgets/widgets.dart';

class WordDetail extends StatefulWidget {
  final Word? word;
  const WordDetail({Key? key, this.word}) : super(key: key);

  @override
  _WordDetailState createState() => _WordDetailState();
}

class _WordDetailState extends State<WordDetail>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<int> _animation;
  late Tween<int> _tween;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _animationController =
        AnimationController(vsync: this, duration: Duration(seconds: 3));
    meaning = '';
    if (widget.word != null) {
      meaning = widget.word!.meaning;
      length = widget.word!.meaning.length;
    }
    edited = meaning;
    supaStore = SupaStore();
    _tween = IntTween(begin: 0, end: length);
    _animation = _tween.animate(_animationController);
    _animationController.addStatusListener((status) {
      // if (status == AnimationStatus.completed) {
      // _animationController.reset();
      // }
    });
  }

  int length = 0;
  int synLength = 0;
  @override
  void dispose() {
    // TODO: implement dispose
    _animationController.dispose();
    editModeNotifier.dispose();
    textEditingController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant WordDetail oldWidget) {
    // TODO: implement didUpdateWidget
    super.didUpdateWidget(oldWidget);
    if (widget.word != null) {
      setState(() {
        length = widget.word!.meaning.length;
      });
    }
    textEditingController.clear();
    unfocus();
    _tween.end = length;
    _animationController.reset();
    _animationController.forward();
  }

  Future<void> updateMeaning() async {
    if (edited.isNotEmpty) {
      meaning = edited;
      textEditingController.text = edited;
      String id = widget.word!.id;
      Word word = widget.word!;
      word.meaning = edited;
      final response = await supaStore.updateMeaning(id: id, word: word);
      stopCircularIndicator(context);
      if (response.status == 200) {
        showMessage(context, " meaning of word ${word.word} updated.");
      } else {
        print('failed to update ${response.error!.message}');
      }
    }
  }

  void unfocus() => FocusScope.of(context).unfocus();

  void showMessage(BuildContext context, String message,
      {Duration duration = const Duration(seconds: 2),
      void Function()? onPressed}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('$message'),
      duration: duration,
      action: onPressed == null
          ? null
          : SnackBarAction(label: 'ACTION', onPressed: onPressed),
    ));
  }

  late String edited;
  late String meaning;
  late SupaStore supaStore;
  final ValueNotifier<bool> editModeNotifier = ValueNotifier<bool>(false);
  TextEditingController textEditingController = TextEditingController(text: "");
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return widget.word == null
        ? EmptyWord()
        : GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: () async {
              editModeNotifier.value = false;
              unfocus();
            },
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: size.height / 5,
                ),
                Align(
                  alignment: Alignment.topCenter,
                  child: Text(
                    widget.word!.word,
                    style: TextStyle(fontSize: size.height * 0.06),
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                SynonymsList(
                  synonyms: widget.word!.synonyms,
                ),
                SizedBox(
                  height: 50,
                ),
                ValueListenableBuilder<bool>(
                    valueListenable: editModeNotifier,
                    builder:
                        (BuildContext context, bool editMode, Widget? child) {
                      return GestureDetector(
                        onTap: () {
                          editModeNotifier.value = true;
                        },
                        child: AnimatedBuilder(
                          animation: _animation,
                          builder: (BuildContext _, Widget? child) {
                            meaning = widget.word!.meaning
                                .substring(0, _animation.value);
                            textEditingController.text = meaning;
                            return Column(
                              children: [
                                AnimatedContainer(
                                  padding: const EdgeInsets.all(16.0),
                                  duration: Duration(seconds: 1),
                                  color: editMode
                                      ? Colors.black12
                                      : Colors.transparent,
                                  child: TextField(
                                      controller: textEditingController,
                                      readOnly: !editMode,
                                      maxLines: 5,
                                      autofocus: false,
                                      onChanged: (x) {
                                        edited = x;
                                      },
                                      onTap: () {
                                        editModeNotifier.value = true;
                                      },
                                      decoration: InputDecoration(
                                          hintText: "Add a meaning",
                                          focusedBorder: InputBorder.none,
                                          border: InputBorder.none),
                                      style: TextStyle(fontSize: 20)),
                                ),
                                SizedBox(
                                  height: 10,
                                ),
                                AnimatedAlign(
                                  alignment: editMode
                                      ? Alignment.center
                                      : Alignment.centerRight,
                                  duration: Duration(milliseconds: 400),
                                  child: AnimatedOpacity(
                                    duration: Duration(seconds: 1),
                                    opacity: editMode ? 1.0 : 0.0,
                                    child: ElevatedButton(
                                      child: Text('Save'),
                                      onPressed: editMode
                                          ? () {
                                              editModeNotifier.value = false;
                                              unfocus();
                                              showCircularIndicator(context);
                                              if (edited != meaning &&
                                                  _animationController.status ==
                                                      AnimationStatus
                                                          .completed) {
                                                /// TODO: Update meaning
                                                length = edited.length;
                                                _tween.end = length;
                                                updateMeaning();
                                              }
                                            }
                                          : null,
                                    ),
                                  ),
                                )
                              ],
                            );
                          },
                        ),
                      );
                    })
              ],
            ),
          );
  }
}

class EmptyWord extends StatelessWidget {
  const EmptyWord({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Whats the word on your mind?',
            style: TextStyle(fontSize: 20),
          )
        ],
      ),
    );
  }
}
