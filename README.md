# eBroker Maintenance Guide

## Generate Keystore

Generate a keystore for the app to sign Android APKs:

```shell
cd android/
keytool -genkey -v -keystore keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload -storepass {PASSWORD HERE} -keypass {PASSWORD HERE} -dname "CN={Your Name}, OU={Your Unit}, O={Your Organization}, L={Your Location}, S={Your State}, C={Your Country}" 
```

## Obtain SHA Keys

To obtain SHA keys required for integrating Firebase:

```shell
cd android
./gradlew signingReport
cd ..
```

## Clean Flutter Project

Clean the Flutter project:

```shell
rm -rf ~/Library/Developer/Xcode/DerivedData
flutter clean
```

### Clean and Fetch Dependencies

Clean the project and fetch dependencies:

```shell
flutter clean
yes | flutter pub cache clean
flutter pub get
```

### Clean and Fetch Dependencies for iOS

Clean the project and fetch dependencies for iOS:

```shell
rm -rf ~/Library/Developer/Xcode/DerivedData
flutter clean
yes | flutter pub cache clean
flutter pub get
cd ios/
pod init
pod install
pod update
```

## Build Android Application

To build the Android application:

```shell
flutter clean
flutter pub get
flutter build apk
```

## Build Android App Bundle

To build the Android app bundle:

```shell
flutter clean
flutter pub get
flutter build appbundle
```

## Update iOS Pods

Update iOS dependencies:

```shell
rm -rf ~/Library/Developer/Xcode/DerivedData
flutter clean
flutter pub get
cd ios
pod init
pod install
pod update
cd ..
```

## Publish iOS App

### Publish Without Changing Version

To publish the iOS app without changing the version:

```shell
rm -rf ~/Library/Developer/Xcode/DerivedData
cd ios
flutter clean
flutter pub get
pod init
pod install
pod update
xed .
```

### Publish With Changing Version

To publish the iOS app with a version change:

```shell
rm -rf ~/Library/Developer/Xcode/DerivedData
cd ios
flutter clean
flutter pub get
pod init
pod install
pod update
flutter build ios
pod install
pod update
xed .
```

## Resolve Common iOS Errors

To resolve common iOS errors:

```shell
rm -rf ~/Library/Developer/Xcode/DerivedData
flutter clean
rm -rf ios/Pods
rm -rf ios/.symlinks
rm -rf ios/Flutter/Flutter.framework
rm -rf Flutter/Flutter.podspec
rm ios/podfile.lock
cd ios 
pod deintegrate
flutter pub cache repair
flutter pub get 
pod install 
pod update 
flutter build ios
pod install 
pod update
xed .
```

## Clean Firebase Data and Cache

To clean old Firebase data and cache from the code:

```shell
rm -rf ~/Library/Developer/Xcode/DerivedData
rm -rf .pub-cache/
rm -rf build
rm -rf firebase.json
rm -rf export_changes.sh
rm -rf android/build
rm -rf .dart_tool/
rm -rf .idea
rm -rf android/.idea
rm -rf .metadata
rm -rf .flutter-plugins-dependencies
rm -rf .flutter-plugins
rm -rf devtools_options.yaml
rm -rf analysis_options.yaml
rm -rf android/app/google-services.json
rm -rf android/.gradle
rm -rf ios/.symlinks
rm -rf ios/Pods
rm -rf ios/Runner/GoogleService-Info.plist
rm -rf ios/firebase_app_id_file.json
rm -rf ios/build
rm -rf ios/Podfile.lock
rm -rf pubspec.lock
rm -rf lib/firebase_options.dart
```

## Clean Temp Cached Files

To clean cache from the code:

```shell
rm -rf ~/Library/Developer/Xcode/DerivedData
rm -rf .pub-cache/
rm -rf build
rm -rf android/build
rm -rf .dart_tool/
rm -rf .idea
rm -rf android/.idea
rm -rf .vscode/
rm -rf android/.gradle/
rm -rf ios/.symlinks/
rm -rf ios/Pods/
rm -rf ios/build/
rm -rf ios/Podfile.lock
rm -rf pubspec.lock
rm -rf devtools_options.yaml
rm -rf analysis_options.yaml
rm -rf .flutter-plugins
rm -rf .flutter-plugins-dependencies
rm -rf ios/Flutter/Flutter.podspec
rm -rf ios/Flutter/flutter_export_environment.sh
rm -rf ios/Flutter/Generated.xcconfig
```


//buildscript {
//    ext.kotlin_version = '1.9.0'
//
//    dependencies {
//        classpath 'com.android.tools.build:gradle:7.1.3'
//        classpath "org.jetbrains.kotlin:kotlin-gradle-plugin:$kotlin_version"
//        classpath 'com.google.gms:google-services:4.3.13'
//    }
//}
