import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:navbar_router/navbar_router.dart';
import 'package:vocabhub/main.dart';
import 'package:vocabhub/models/collection.dart';
import 'package:vocabhub/models/word.dart';
import 'package:vocabhub/navbar/empty_page.dart';
import 'package:vocabhub/navbar/error_page.dart';
import 'package:vocabhub/pages/collections/collections.dart';
import 'package:vocabhub/utils/extensions.dart';
import 'package:vocabhub/widgets/responsive.dart';
import 'package:vocabhub/widgets/widgets.dart';
import 'package:vocabhub/widgets/worddetail.dart';

class CollectionsNavigator extends StatefulWidget {
  final Word word;
  final ScrollController? controller;
  const CollectionsNavigator({super.key, required this.word, this.controller});

  @override
  State<CollectionsNavigator> createState() => _CollectionsNavigatorState();
}

class _CollectionsNavigatorState extends State<CollectionsNavigator> {
  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.vertical(top: Radius.circular(28.0)),
      child: Navigator(
        initialRoute: SavedCollections.route,
        onGenerateRoute: (settings) {
          switch (settings.name) {
            case NewCollection.route:
              return MaterialPageRoute(builder: (context) => NewCollection());
            case CollectionDetails.route:
              final collection = settings.arguments as VHCollection;
              return MaterialPageRoute(
                  builder: (context) => CollectionDetails(
                        collection: collection,
                      ));
            case SavedCollections.route:
              return MaterialPageRoute(
                  builder: (context) => SavedCollections(
                        controller: widget.controller,
                        word: widget.word,
                      ));
            case CollectionsGrid.route:
              return MaterialPageRoute(
                  builder: (context) => CollectionsGrid(
                        controller: widget.controller,
                      ));
            case DemoCollections.route:
              return MaterialPageRoute(builder: (context) => DemoCollections());
            default:
              return MaterialPageRoute(
                  builder: (context) => ErrorPage(
                      onRetry: () {},
                      errorMessage: 'Oh no! You have landed on an unknown planet '));
          }
        },
      ),
    );
  }
}

class SavedCollections extends StatelessWidget {
  static const String route = '/collections/saved';

  final ScrollController? controller;
  final Word word;

  const SavedCollections({super.key, this.controller, required this.word});

  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(desktopBuilder: (context) {
      return SavedCollectionsSheet(
        controller: controller,
        word: word,
      );
    }, mobileBuilder: (context) {
      return SavedCollectionsSheet(
        controller: controller,
        word: word,
      );
    });
  }
}

class SavedCollectionsSheet extends ConsumerStatefulWidget {
  final ScrollController? controller;
  final Word word;

  const SavedCollectionsSheet({super.key, this.controller, required this.word});

  @override
  ConsumerState<SavedCollectionsSheet> createState() => _CollectionsSavedState();
}

class _CollectionsSavedState extends ConsumerState<SavedCollectionsSheet> {
  @override
  Widget build(BuildContext context) {
    final collectionRef = ref.read(collectionNotifier.notifier);
    final collections = ref.watch(collectionNotifier).collections;
    return Column(
      children: [
        Padding(
          padding: 8.0.topPadding + 4.0.bottomPadding,
          child: ListTile(
            title: Text('Collections', style: Theme.of(context).textTheme.headlineSmall),
            trailing: TextButton(
                onPressed: () {
                  Navigate.pushNamed(context, '/new', isRootNavigator: false);
                },
                child: Text('Create Collection',
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall!
                        .copyWith(color: Theme.of(context).colorScheme.primary))),
          ),
        ),
        hLine(),
        if (collections.isEmpty)
          Expanded(child: DemoCollections())
        else
          Expanded(
              child: ListView.builder(
                  itemCount: collections.length,
                  controller: widget.controller ?? ScrollController(),
                  itemBuilder: (context, index) {
                    final title = collections[index].title;
                    final words = collections[index].words;
                    final isPinned = collections[index].isPinned;
                    final contains = words.containsWord(widget.word);
                    return ListTile(
                      title: Row(
                        children: [
                          Text(
                            '$title (${words.length})',
                          ),
                          8.0.hSpacer(),
                          circle(color: collections[index].color)
                        ],
                      ),
                      onTap: () {
                        Navigate.pushNamed(context, CollectionDetails.route,
                            arguments: collections[index]);
                      },
                      trailing: widget.word.word.isEmpty
                          ? IconButton(
                              onPressed: () async {
                                ref.read(collectionNotifier.notifier).togglePin(title);
                              },
                              icon: Icon(
                                !isPinned ? Icons.push_pin_outlined : Icons.push_pin_rounded,
                                color: Theme.of(context).colorScheme.primary,
                              ))
                          : IconButton(
                              onPressed: () async {
                                if (contains) {
                                  collectionRef.removeFromCollection(title, widget.word);
                                } else {
                                  collectionRef.addToCollection(title, widget.word);
                                }
                              },
                              icon:
                                  Icon(contains ? Icons.check : Icons.add_circle_outline_outlined)),
                    );
                  })),
      ],
    );
  }
}

class CollectionsGrid extends ConsumerStatefulWidget {
  final ScrollController? controller;
  static const String route = '/collections/grid';
  const CollectionsGrid({super.key, this.controller});

  @override
  ConsumerState<CollectionsGrid> createState() => CollectionsGridState();
}

class CollectionsGridState extends ConsumerState<CollectionsGrid> {
  @override
  Widget build(BuildContext context) {
    final collections = ref.watch(collectionNotifier).collections;
    return collections.isEmpty
        ? EmptyPage(message: 'No collections found')
        : GridView.builder(
            shrinkWrap: true,
            padding: 8.0.verticalPadding,
            itemCount: collections.length,
            controller: widget.controller ?? ScrollController(),
            gridDelegate:
                SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, childAspectRatio: 1.5),
            itemBuilder: (context, index) {
              final title = collections[index].title;
              final words = collections[index].words;
              return Card(
                color: Theme.of(context).colorScheme.primary,
                child: InkWell(
                  onTap: () {
                    Navigate.pushNamed(context, '/new');
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('$title (${words.length})',
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.headlineSmall),
                        Text('Tap to view', style: Theme.of(context).textTheme.bodySmall),
                      ],
                    ),
                  ),
                ),
              );
            });
  }
}

class CollectionDetails extends StatelessWidget {
  static const String route = '/collection/details';
  final VHCollection collection;
  const CollectionDetails({super.key, required this.collection});

  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(desktopBuilder: (context) {
      return CollectionDetailsSheet(
        collection: collection,
      );
    }, mobileBuilder: (context) {
      return CollectionDetailsSheet(
        collection: collection,
      );
    });
  }
}

class CollectionDetailsSheet extends ConsumerStatefulWidget {
  // collection name
  final VHCollection collection;
  const CollectionDetailsSheet({super.key, required this.collection});

  @override
  ConsumerState<CollectionDetailsSheet> createState() => _CollectionDetailsSheetState();
}

class _CollectionDetailsSheetState extends ConsumerState<CollectionDetailsSheet> {
  @override
  Widget build(BuildContext context) {
    final collection = widget.collection ?? VHCollection.init();
    return Column(
      children: [
        Padding(
          padding: 8.0.topPadding + 4.0.bottomPadding,
          child: ListTile(
            leading: BackButton(),
            // delete collection
            trailing: IconButton(
                onPressed: () {
                  ref.read(collectionNotifier.notifier).deleteCollection(collection.title);
                  Navigate.popView(context, isRootNavigator: false);
                },
                icon: Icon(Icons.delete, color: Theme.of(context).colorScheme.primary)),
            title: Text('${collection.title}', style: Theme.of(context).textTheme.headlineSmall),
          ),
        ),
        hLine(),
        if (collection.words.isEmpty)
          Expanded(child: EmptyPage(message: 'No words in ${collection.title}'))
        else
          Expanded(
              child: ListView.builder(
                  itemCount: collection.words.length,
                  itemBuilder: (context, index) {
                    final word = collection.words[index];
                    return ListTile(
                      title: Text('${word.word.capitalize()}'),
                      onTap: () {
                        Navigate.push(context, WordDetail(word: word),
                            isRootNavigator: true, transitionType: TransitionType.rtl);
                      },
                      trailing: IconButton(
                          onPressed: () {
                            //  push on top of the stack
                            Navigate.push(context, WordDetail(word: word),
                                isRootNavigator: true, transitionType: TransitionType.rtl);
                          },
                          icon: Icon(Icons.arrow_forward_ios_outlined)),
                    );
                  })),
      ],
    );
  }
}
