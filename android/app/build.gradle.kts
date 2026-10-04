import java.util.Properties
import java.io.FileInputStream

plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

// Signing credentials are kept out of the build script and out of version
// control: this file is read at build time and may simply be absent, in which
// case the release build falls back to the debug key.
//
// `key.properties` is NOT committed. It holds the upload keystore passwords,
// and this repository is public. Losing the keystore is unrecoverable: without
// it no further update can be published to the same Play Store listing.
val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
}

android {
    namespace = "com.ezshop.app"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        applicationId = "com.ezshop.app"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        create("release") {
            // Only declared when the credentials file is present, so a clone
            // without it still builds (debug builds and CI checks) instead of
            // failing on a missing password.
            if (keystorePropertiesFile.exists()) {
                keyAlias = keystoreProperties["keyAlias"] as String
                keyPassword = keystoreProperties["keyPassword"] as String
                // Resolved against `android/`, the same base as
                // key.properties itself: `file()` inside the app module would
                // look in `android/app/` and miss the keystore.
                storeFile = keystoreProperties["storeFile"]?.let {
                    rootProject.file(it)
                }
                storePassword = keystoreProperties["storePassword"] as String
            }
        }
    }

    buildTypes {
        release {
            // Play Store rejects a bundle signed with the debug key, so the
            // upload key is used whenever it is available. The fallback keeps
            // `flutter run --release` working on a machine that has no keystore.
            signingConfig = if (keystorePropertiesFile.exists()) {
                signingConfigs.getByName("release")
            } else {
                signingConfigs.getByName("debug")
            }
            // R8 shrinks and obfuscates the Dart entry points. Left off for
            // now: it needs a keep-rules pass to be sure nothing reflective
            // (image picking, cropping, URL launching) breaks in release.
            isMinifyEnabled = false
            isShrinkResources = false
        }
    }
}

flutter {
    source = "../.."
}