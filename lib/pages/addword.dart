import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:uuid/uuid.dart';
import 'package:vocabhub/constants/const.dart';
import 'package:vocabhub/main.dart';
import 'package:vocabhub/models/history.dart';
import 'package:vocabhub/models/user.dart';
import 'package:vocabhub/models/word.dart';
import 'package:vocabhub/services/analytics.dart';
import 'package:vocabhub/services/appstate.dart';
import 'package:vocabhub/services/services/edit_history.dart';
import 'package:vocabhub/services/services/vocabstore.dart';
import 'package:vocabhub/themes/vocab_theme.dart';
import 'package:vocabhub/utils/navigator.dart';
import 'package:vocabhub/utils/utility.dart';
import 'package:vocabhub/utils/utils.dart';
import 'package:vocabhub/widgets/button.dart';
import 'package:vocabhub/widgets/widgets.dart';

class AddWordForm extends StatefulWidget {
  final bool isEdit;
  final Word? word;
  static const route = '/addword';

  const AddWordForm({Key? key, this.isEdit = false, this.word})
      : super(key: key);

  @override
  _AddWordFormState createState() => _AddWordFormState();
}

class _AddWordFormState extends State<AddWordForm> {
  late Size size;
  VocabStoreService supaStore = VocabStoreService();

  late TextEditingController wordController;
  late TextEditingController meaningController;
  late TextEditingController exampleController;
  late TextEditingController synonymController;
  late TextEditingController mnemonicController;

  Future<void> submitForm() async {
    showCircularIndicator(context);
    final newWord = wordController.text.trim();
    final meaning = meaningController.text.trim();
    Word wordObject;
    if (newWord.isNotEmpty && meaning.isNotEmpty) {
      wordObject = buildWordFromFields()!;
    } else {
      _requestNotifier.value =
          Response(state: RequestState.error, message: 'Word and Meaning are required');
      Future.delayed(Duration(seconds: 3), () {
        _requestNotifier.value = Response(state:RequestState.done);
      });
      stopCircularIndicator(context);
      return;
    }
    try {
      if (await wordExists(wordObject)) {
        stopCircularIndicator(context);
        _requestNotifier.value = Response(state:RequestState.error,
            message: 'Word "${wordObject.word}" already exists!');
        return;
      }
      var history = EditHistory.fromWord(wordObject, userProvider!.email);
      history = history.copyWith(
        edit_type: EditType.add,
      );
      final response = await EditHistoryService.insertHistory(history);
      if (response.didSucced) {
        firebaseAnalytics.logWordAdd(wordObject, userProvider!.email);
        showMessage(context,
            'Congrats! Your new word ${editedWord.word} is under review!',
            duration: Duration(seconds: 3), onClosed: () {
          stopCircularIndicator(context);
          Navigate().popView(context);
        });
      } else {
        _requestNotifier.value = Response(state:RequestState.error,
            message: 'Failed to add ${editedWord.word}');
        stopCircularIndicator(context);
      }
    } catch (x) {
      stopCircularIndicator(context);
      _requestNotifier.value = Response(state:RequestState.error, message: '$x');
    }
  }

  Word? buildWordFromFields() {
    final newWord = wordController.text.trim();
    final meaning = meaningController.text;
    Word wordObject = Word(
      Uuid().v1(),
      newWord.trim().capitalize()!,
      meaning,
    );
    wordObject = wordObject.copyWith(
        examples: editedWord.examples,
        synonyms: editedWord.synonyms,
        mnemonics: editedWord.mnemonics);
    return wordObject;
  }

  Future<bool> wordExists(Word editedWord) async {
    final currentWordFromDatabase =
        await VocabStoreService.findByWord(editedWord.word.capitalize()!);
    if (currentWordFromDatabase == null) {
      _requestNotifier.value = Response(state:RequestState.done);
      return false;
    }
    _requestNotifier.value =
        Response(state:RequestState.error, message: 'Word already exists');
    return true;
  }

  final firebaseAnalytics = Analytics();
  final _requestNotifier = ValueNotifier<Response>(Response(state:RequestState.none));
  Word? currentWordFromDatabase;

  @override
  void initState() {
    super.initState();
    wordController = TextEditingController();
    meaningController = TextEditingController();
    exampleController = TextEditingController();
    synonymController = TextEditingController();
    mnemonicController = TextEditingController();
    wordFocus = FocusNode(canRequestFocus: true);
    meaningFocus = FocusNode(canRequestFocus: true);
    _title = 'Lets add a new word';
    if (widget.isEdit) {
      _populateData();
      _title = 'Editing Word';
    }
    exampleController.addListener(_rebuild);
    synonymController.addListener(_rebuild);
    mnemonicController.addListener(_rebuild);
  }

  void _populateData() {
    editedWord = widget.word!.deepCopy();
    wordController.text = editedWord.word;
    meaningController.text = editedWord.meaning;
  }

  /// when field contains some info and user has not clicked on tick
  /// applies to synonyms, examples, mnemonics
  void _rebuild() {
    final synonym = synonymController.text;
    final example = exampleController.text;
    final mnemonic = mnemonicController.text;
    if (synonym.isNotEmpty || example.isNotEmpty || mnemonic.isNotEmpty) {
      _requestNotifier.value =
          Response(state:RequestState.error, message: 'Please submit the field');
    } else {
      _requestNotifier.value = Response(state:RequestState.done);
    }
    setState(() {});
  }

  /// Edit mode
  Future<void> updateWord() async {
    showCircularIndicator(context);
    String id = widget.word!.id;
    final newWord = wordController.text.trim();
    final meaning = meaningController.text.trim();
    try {
      if (newWord.isNotEmpty && meaning.isNotEmpty) {
        editedWord = editedWord.copyWith(word: newWord, meaning: meaning);
        var history = EditHistory.fromWord(editedWord, userProvider!.email);
        history = history.copyWith(edit_type: EditType.edit);
        if (widget.word != editedWord) {
          final response = await EditHistoryService.insertHistory(history);
          if (response.didSucced) {
            final pendingWord = response.data;
            showMessage(
                context,
                duration: Duration(seconds: 3),
                "Your edit is under review, We will notifiy you once there is an update",
                onClosed: () {
              stopCircularIndicator(context);
              Navigate().popView(context);
            });
          }
        } else {
          stopCircularIndicator(context);
          showMessage(context, "No changes to update", onClosed: () {});
        }
      }
    } catch (_) {
      stopCircularIndicator(context);
      showMessage(context, "Failed to edit word", onClosed: () {});
    }
  }

  Future<void> deleteWord() async {
    if (widget.isEdit) {
      showCircularIndicator(context);
      String id = widget.word!.id;
      final response = await VocabStoreService.deleteById(id);
      if (response.status == 200) {
        firebaseAnalytics.logWordDelete(widget.word!, userProvider!.email);
        showMessage(
            context, "The word \"${widget.word!.word}\" has been deleted.",
            onClosed: () => Navigate().popView(context));
      }
      stopCircularIndicator(context);
    }
  }

  Future<void> _showAlert() async {
    return showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) => VocabAlert(
            title: 'Are you sure you want to delete this word?',
            onConfirm: () {
              Navigator.of(context).pop();
              deleteWord();
            },
            onCancel: () {
              Navigate().popView(context);
            }));
  }

  @override
  void dispose() {
    wordController.dispose();
    meaningController.dispose();
    exampleController.dispose();
    synonymController.dispose();
    mnemonicController.dispose();
    _requestNotifier.dispose();
    super.dispose();
  }

  Word editedWord = Word('', '', '');
  late FocusNode wordFocus;
  late FocusNode meaningFocus;
  late String _title;
  UserModel? userProvider;

  @override
  Widget build(BuildContext context) {
    size = MediaQuery.of(context).size;
    bool isDark = darkNotifier.value;

    Widget synonymChip(String synonym, Function onDeleted) {
      return InputChip(
        label: Text(
          '${synonym.trim().capitalize()}',
          style: Theme.of(context)
              .textTheme
              .headline5!
              .copyWith(color: Colors.white),
        ),
        onDeleted: () => onDeleted(),
        isEnabled: true,
        backgroundColor:
            isDark ? VocabTheme.secondaryDark : VocabTheme.secondaryColor,
        deleteButtonTooltipMessage: 'remove',
      );
    }

    userProvider = AppStateScope.of(context).user!;
    final words = AppStateScope.of(context).words!;

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: ValueListenableBuilder<Response>(
          valueListenable: _requestNotifier,
          builder: (BuildContext context, Response request, Widget? child) {
            return Scaffold(
              resizeToAvoidBottomInset: true,
              appBar: AppBar(
                title: Text(widget.isEdit ? 'Edit Word' : 'Add word'),
              ),
              body: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: ListView(
                  children: [
                    25.0.vSpacer(),
                    VocabField(
                      autofocus: true,
                      fontSize: 30,
                      maxlength: 20,
                      hint: 'e.g Ambivalent',
                      onChange: (x) async {
                        editedWord = editedWord.copyWith(word: x);
                        if (!widget.isEdit) {
                          final currentWordFromDatabase =
                              await VocabStoreService.findByWord(
                                  editedWord.word.capitalize()!);
                          if (currentWordFromDatabase != null) {
                            _requestNotifier.value = Response(state:RequestState.error,
                                message: 'Word already exists');
                          } else {
                            _requestNotifier.value = Response(state:RequestState.done);
                          }
                          setState(() {});
                        }
                      },
                      focusNode: wordFocus,
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp('[A-Z-a-z]+'))
                      ],
                      controller: wordController,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: VocabField(
                        hint: 'What does ' +
                            '${editedWord.word.isEmpty ? 'it mean?' : editedWord.word + ' mean?'}',
                        controller: meaningController,
                        focusNode: meaningFocus,
                        maxlines: 4,
                      ),
                    ),
                    Wrap(
                      direction: Axis.horizontal,
                      alignment: WrapAlignment.center,
                      spacing: 8,
                      runSpacing: 2,
                      children:
                          List.generate(editedWord.synonyms!.length, (index) {
                        return synonymChip(editedWord.synonyms![index], () {
                          editedWord.synonyms!
                              .remove(editedWord.synonyms![index]);
                          setState(() {});
                        });
                      }),
                    ),
                    editedWord.synonyms!.length == maxSynonymCount
                        ? SizedBox.shrink()
                        : Row(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                width: 150,
                                child: VocabField(
                                  fontSize: 16,
                                  hint: 'add synonym',
                                  maxlength: 16,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.allow(
                                        RegExp('[A-Z-a-z]+')),
                                    FilteringTextInputFormatter.deny(wordController.text)
                                  ],
                                  controller: synonymController,
                                ),
                              ),
                              synonymController.text.isNotEmpty
                                  ? Padding(
                                      padding: const EdgeInsets.only(
                                          left: 16.0, right: 16, top: 8),
                                      child: IconButton(
                                          onPressed: () {
                                            String newSynonym = synonymController.text;
                                            if (editedWord.word.isNotEmpty) {
                                              if (newSynonym.isNotEmpty &&
                                                  !editedWord.synonyms!.contains(newSynonym)) {
                                                editedWord = editedWord.copyWith(synonyms: [
                                                  ...editedWord.synonyms!,
                                                  newSynonym
                                                ]);
                                                synonymController.clear();
                                              }
                                            } else {
                                              showMessage(context, 'You must add a word first');
                                              FocusScope.of(context).requestFocus(wordFocus);
                                              synonymController.clear();
                                            }
                                          },
                                          icon: Icon(Icons.done, size: 32)),
                                    )
                                  : Container(),
                            ],
                          ),
                    30.0.hSpacer(),
                    ...List.generate(editedWord.examples!.length, (index) {
                      return Container(
                        margin: EdgeInsets.symmetric(
                            horizontal: SizeUtils.isMobile ? 16 : 24.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Expanded(
                                child: buildExample(editedWord.examples![index],
                                    editedWord.word)),
                            GestureDetector(
                                onTap: () {
                                  editedWord.examples!.remove(
                                      editedWord.examples!.elementAt(index));
                                  setState(() {});
                                },
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8.0),
                                  child: Icon(Icons.delete),
                                )),
                          ],
                        ),
                      );
                    }),
                    editedWord.examples!.length < maxExampleCount
                        ? Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Flexible(
                                child: VocabField(
                                  hint:
                                      'An example sentence ${editedWord.word.isEmpty ? "" : "with ${editedWord.word}"} (Optional)',
                                  controller: exampleController,
                                  maxlines: 4,
                                ),
                              ),
                              exampleController.text.isNotEmpty
                                  ? Padding(
                                      padding: const EdgeInsets.only(
                                          left: 16.0, right: 16, top: 8),
                                      child: IconButton(
                                          onPressed: () {
                                            String text =
                                                exampleController.text;
                                            if (editedWord.word.isNotEmpty) {
                                              editedWord = editedWord.copyWith(
                                                  examples: [
                                                    ...editedWord.examples!,
                                                    text
                                                  ]);
                                              exampleController.clear();
                                            } else {
                                              showMessage(
                                                  context, 'Add a word first');
                                              FocusScope.of(context)
                                                  .requestFocus(wordFocus);
                                            }
                                            setState(() {});
                                          },
                                          icon: Icon(Icons.done, size: 32)),
                                    )
                                  : Container(),
                            ],
                          )
                        : Container(),
                    ...List.generate(editedWord.mnemonics!.length, (index) {
                      return Container(
                        margin: EdgeInsets.symmetric(
                            horizontal: SizeUtils.isMobile ? 16 : 24.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Expanded(
                                child: buildExample(
                                    editedWord.mnemonics![index],
                                    editedWord.word)),
                            GestureDetector(
                                onTap: () {
                                  editedWord.mnemonics!.remove(
                                      editedWord.mnemonics!.elementAt(index));
                                  setState(() {});
                                },
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8.0),
                                  child: Icon(Icons.delete),
                                )),
                          ],
                        ),
                      );
                    }),
                    24.0.vSpacer(),
                    editedWord.mnemonics!.length < maxMnemonicCount
                        ? Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Flexible(
                                child: VocabField(
                                  hint:
                                      'A mnemonic to help remember ${editedWord.word} (Optional)',
                                  controller: mnemonicController,
                                  maxlines: 4,
                                ),
                              ),
                              mnemonicController.text.isNotEmpty
                                  ? Padding(
                                      padding: const EdgeInsets.only(
                                          left: 16.0, right: 16, top: 8),
                                      child: IconButton(
                                          onPressed: () {
                                            String text =
                                                mnemonicController.text;
                                            if (text.isNotEmpty) {
                                              editedWord = editedWord.copyWith(
                                                  mnemonics: [
                                                    ...editedWord.mnemonics!,
                                                    text
                                                  ]);
                                              mnemonicController.clear();
                                            } else {
                                              showMessage(
                                                  context, 'Add a word first');
                                              FocusScope.of(context)
                                                  .requestFocus(wordFocus);
                                            }
                                            setState(() {});
                                          },
                                          icon: Icon(Icons.done, size: 32)),
                                    )
                                  : Container(),
                            ],
                          )
                        : Container(),
                    50.0.hSpacer(),
                    Align(
                      alignment: Alignment.center,
                      child: VHButton(
                        foregroundColor: Colors.white,
                        backgroundColor:
                            isDark ? Colors.teal : VocabTheme.primaryColor,
                        height: 44,
                        width: 120,
                        onTap: request.state == RequestState.error
                            ? null
                            : () => widget.isEdit ? updateWord() : submitForm(),
                        label: widget.isEdit ? 'Update' : 'Submit',
                      ),
                    ),
                    16.0.vSpacer(),
                    if (request.state == RequestState.error)
                      Align(
                        alignment: Alignment.center,
                        child: Text(
                          '${_requestNotifier.value.message}',
                          style: TextStyle(
                              color: isDark ? Colors.white : Colors.red),
                        ),
                      ),
                    16.0.vSpacer(),
                    Align(
                      alignment: Alignment.center,
                      child: SizedBox(
                        height: 40,
                        width: 150,
                        child: widget.isEdit && userProvider!.isAdmin
                            ? TextButton(
                                onPressed: _showAlert,
                                child: Text(
                                  'Delete',
                                  style: Theme.of(context)
                                      .textTheme
                                      .headline4!
                                      .copyWith(
                                          color: VocabTheme.errorColor,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600),
                                ))
                            : SizedBox.shrink(),
                      ),
                    ),
                    40.0.hSpacer(),
                  ],
                ),
              ),
            );
          }),
    );
  }
}

class VocabField extends StatefulWidget {
  final String hint;
  final int? maxlines;
  final int? maxlength;
  final bool autofocus;
  final double fontSize;
  final FocusNode? focusNode;
  final List<TextInputFormatter>? inputFormatters;
  final TextEditingController controller;
  final Function(String)? onChange;
  final Function(String)? onSubmit;

  const VocabField(
      {Key? key,
      required this.hint,
      this.maxlines = 1,
      this.maxlength,
      this.focusNode,
      this.onChange,
      this.onSubmit,
      this.inputFormatters,
      required this.controller,
      this.fontSize = 16,
      this.autofocus = false})
      : super(key: key);

  @override
  VocabFieldState createState() => VocabFieldState();
}

class VocabFieldState extends State<VocabField> {
  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context).textTheme.headline4;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
              controller: widget.controller,
              maxLines: widget.maxlines,
              textAlign: TextAlign.center,
              maxLength: widget.maxlength,
              autofocus: widget.autofocus,
              focusNode: widget.focusNode,
              textInputAction: TextInputAction.next,
              onSubmitted: (x) {
                if (widget.onSubmit != null) widget.onSubmit!(x);
              },
              inputFormatters: widget.inputFormatters,
              onChanged: (x) {
                if (widget.onChange != null) widget.onChange!(x);
              },
              decoration: InputDecoration(
                  hintText: widget.hint,
                  counterText: '',
                  hintStyle: style!
                      .copyWith(fontSize: widget.fontSize, color: Colors.grey),
                  focusedBorder: InputBorder.none,
                  border: InputBorder.none),
              style: style.copyWith(
                  fontWeight: FontWeight.bold, fontSize: widget.fontSize)),
        ],
      ),
    );
  }
}

class VocabAlert extends StatelessWidget {
  final String title;
  final Function()? onConfirm;
  final Function()? onCancel;

  const VocabAlert(
      {Key? key,
      required this.title,
      required this.onConfirm,
      required this.onCancel})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    bool isDark = darkNotifier.value;
    return AlertDialog(
      content: Text(title),
      actions: [
        TextButton(
          onPressed: onConfirm,
          child: Text(
            'Delete',
            style: TextStyle(color: VocabTheme.errorColor),
          ),
        ),
        TextButton(
          onPressed: onCancel,
          child: Text(
            'Cancel',
            style: TextStyle(color: isDark ? Colors.white : Colors.black),
          ),
        ),
      ],
    );
  }
}
