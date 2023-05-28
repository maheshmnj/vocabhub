# Vocabhub 0.4.1

A vocabulary app built with Flutter and Supabase, that is simple to use and available on multiple platforms with
- 800+ most common GRE words
- provides synonyms, mnemonics, examples to understand each word
- intelligent search that allows searching for a word with its meaning, synonym.
- supports dark mode for the night owls (Web only)
- Ability to suggest edits to improve the words on the platform.
- More words and features are being added every week.


### Running the app

The api keys in this project are managed using [--dart-define](https://dartcode.org/docs/using-dart-define-in-flutter/) flags passed to the flutter run command. You can also use the
```dart
flutter <command> --dart-define=SUPABASE_PROJECT_URL=<your project url here> --dart-define=SUPABASE_API_KEY=<your api key here> --dart-define=SUPABASE_REDIRECT_URL=<your redirect url here>
```
command to run the app from the command line, or If you want to use the launch.json file to run the app, you can copy paste the below configuration to your `.vscode/launch.json` file and pass the keys from the Supabase settings.

```
 {
    "name": "Launch",
    "request": "launch",
    "type": "dart",
    "program": "lib/main.dart",
    "args": [
        "--dart-define=SUPABASE_PROJECT_URL=<your project url here>",
        "--dart-define=SUPABASE_API_KEY=<your api key here>",
        "--dart-define=SUPABASE_REDIRECT_URL=<your redirect url here>"
    ]
  }
```

_Run the project using the command_
```
  flutter run --dart-define=SUPABASE_PROJECT_URL=<your project url here> --dart-define=SUPABASE_API_KEY=<your api key here> --dart-define=SUPABASE_REDIRECT_URL=<your redirect url here>
```

#### Build the app

```
  flutter build apk --dart-define=SUPABASE_PROJECT_URL=<your project url here> --dart-define=SUPABASE_API_KEY=<your api key here> --dart-define=SUPABASE_REDIRECT_URL=<your redirect url here>
```

The apk will be generated in the `build/app/outputs/flutter-apk/app-release.apk` folder.

### Mobile

Solarized dark             |  Solarized Ocean   |  Solarized Ocean
:-------------------------:|:-------------------------:|:-------------------------:
<img src="https://user-images.githubusercontent.com/31410839/199623337-febc03e2-0bc7-4c72-b269-4ccb0c88fd81.png" width="600">| <img src="https://user-images.githubusercontent.com/31410839/199623341-0b8d4e82-24a4-4c67-b3fc-aaa53f6feb2f.png" width="600"> | <img src="https://user-images.githubusercontent.com/31410839/199623349-e1021ef6-5f6d-473d-b584-0885d5d462e2.png" width="600">

Found a mistake?           |  Track your contributions
:-------------------------:|:-------------------------:
![preview 5](https://user-images.githubusercontent.com/31410839/199623676-846ff94b-7d00-4f2f-bcc1-19e12c60c779.png)| ![preview 4](https://user-images.githubusercontent.com/31410839/199623683-1e5841af-5310-41ab-b981-da5d8e654cd1.png)




## Adds Support for Dark Mode (Web only)

|                                                                     v0.2.2                                                                      |
| :---------------------------------------------------------------------------------------------------------------------------------------------: |
| <img src="https://user-images.githubusercontent.com/31410839/125232197-be28a180-e2f9-11eb-82db-980325528b55.png"/> |

|                                                                     v0.2.0                                                                      |
| :---------------------------------------------------------------------------------------------------------------------------------------------: |
| <img src="https://user-images.githubusercontent.com/31410839/121843891-b8429f00-cd00-11eb-8fc9-c242b8a6a19c.png" alt="" style="width: 400px;"/> |


|                                                                     v0.1.0                                                                      |
| :---------------------------------------------------------------------------------------------------------------------------------------------: |
| <img src="https://user-images.githubusercontent.com/31410839/120900881-131b2d00-c655-11eb-8c00-6aafade70d29.png" alt="" style="width: 400px;"/> |

### Platform

| Android | iOS | MacOS | Web |
| :-----: | :-: | :---: | :-: |
|   ✅    | ✅  |  ❌   | ✅  |

<a href="https://play.google.com/store/apps/details?id=com.vocabhub.app" target="_blank">
<img src="assets/googleplay.png" height="60">
</a>

<a href="http://www.amazon.com/gp/mas/dl/android?p=com.vocabhub.app" target="_blank">
<img src="assets/amazonappstore.png" height="60">
</a>


### [Try it out on the web](https://vocabhub.web.app/)


## Contributing

Feel Free to contribute to this app to make the platform better.

Design files for this project can be found here https://www.figma.com/file/xPCoi1IcW8M6TODTqjG9GZ/Vocabhub?node-id=0%3A1

Data is no longer being collected into [this sheet](https://docs.google.com/spreadsheets/d/1G1RtQfsEDqHhHP4cgOpO9x_ZtQ1dYa6QrGCq3KFlu50/edit#gid=0). Contribution does not necessarily mean sending a pull request you could also contribute by improving the sheet.
