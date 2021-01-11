# Augmented Reality with Google Maps in Dart

Display AR objects when users arrive at a specific location

## Installation

### Android
1. Flutter setup on Linux
```Bash
git clone https://github.com/flutter/flutter.git
export PATH="$PATH:`pwd`/flutter/bin"
flutter doctor
# Append the export to .bashrc file
echo "export PATH="$PATH:`pwd`/flutter/bin"" >> ~/.bashrc
flutter doctor
```
2. Download and install Android Studio
    * 2.1. Start Android Studio.
    * 2.2. Open plugin preferences (File > Settings > Plugins).
    * 2.3. Make sure tab *Marketplace* is selected before search.
    * 2.4. Type in Flutter in the search box, Select the Flutter plugin and click Install.
    * 2.5. Click Yes when prompted to install the Dart plugin.
    * 2.6. Click Restart when prompted.
    * 2.7. Open File > Settings > Languages & Frameworks > Flutter
    * 2.8. Set the path to the flutter SDK as same as set in the PATH, or it can be get by:
    ```bash
    which flutter
    ```
    * 2.9. Open File > Settings > Languages & Frameworks > Dart
    * 2.10. Set the path to the Dart SDK, normally, it should be generated automatically, but in
    case it is not, set to flutter/bin/cache/dart-sdk
    For example: if the path to Flutter is: /home/congnt/flutter/bin/flutter
    Then the path to Dark is: /home/congnt/flutter/bin/cache/dart-sdk
    * 2.11. Restart the Android Studio
3. Clone the project
```bash
git clone https://github.com/binpoi/cross-ux
cd cross-ux
flutter pub get
```
4. Open the project using the Android Studio
5. Run the project
### iOS

## Reference
[Installation](https://flutter.dev/docs/get-started/install)