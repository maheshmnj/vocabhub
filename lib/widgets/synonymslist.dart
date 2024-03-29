import 'package:flutter/material.dart';
import 'package:vocabhub/utils/extensions.dart';
import 'package:vocabhub/utils/size_utils.dart';

class SynonymsList extends StatelessWidget {
  final List<String>? synonyms;
  final double emptyHeight;
  final Function(String) onTap;
  SynonymsList({
    Key? key,
    this.emptyHeight = 20,
    this.synonyms,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Size size = MediaQuery.of(context).size;
    return (synonyms == null || synonyms!.isEmpty)
        ? emptyHeight.vSpacer()
        : Container(
            alignment: Alignment.center,
            padding: EdgeInsets.symmetric(horizontal: !SizeUtils.isMobile ? 12.0 : 32.0),
            child: Wrap(
              direction: Axis.horizontal,
              alignment: WrapAlignment.center,
              runSpacing: 5,
              spacing: 10,
              children: List.generate(synonyms!.length, (index) {
                final String synonym = synonyms![index].capitalize()!;
                return MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: GestureDetector(
                      onTap: () {
                        onTap(synonym);
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                            border: Border.all(
                              color: Theme.of(context).colorScheme.secondaryContainer,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 2,
                                offset: Offset(1, 2),
                              )
                            ],
                            // color: Theme.of(context).colorScheme.secondaryContainer,
                            borderRadius: BorderRadius.circular(20)),
                        child: Text(
                          '${synonym.trim()}',
                        ),
                      ),
                    ));
              }),
            ),
          );
  }
}
