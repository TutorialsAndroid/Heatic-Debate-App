import java.io.FileInputStream
import java.io.IOException
import java.util.Properties

plugins {
    id("com.android.application")
    // START: FlutterFire Configuration
    id("com.google.gms.google-services")
    // END: FlutterFire Configuration
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

// Initialize Properties
val properties = Properties()
try {
    // Load keystore
    val keystorePropertiesFile = rootProject.file("keystore.properties")
    properties.load(FileInputStream(keystorePropertiesFile))
} catch (e: IOException) {
    // We don't have release keys, ignoring
    e.printStackTrace()
}

// Release key path, password, alias
val releaseKeyStorePath: String? = properties.getProperty("RELEASE_KEY_STORE_PATH")
val releaseKeyStorePathPassword: String? = properties.getProperty("RELEASE_KEY_STORE_PATH_PASSWORD")
val releaseKeyStorePathAlias: String? = properties.getProperty("RELEASE_KEY_STORE_PATH_ALIAS")

// Debug key path, password, alias
//val debugKeyStorePath: String? = properties.getProperty("DEBUG_KEY_STORE_PATH")
//val debugKeyStorePathPassword: String? = properties.getProperty("DEBUG_KEY_STORE_PATH_PASSWORD")
//val debugKeyStorePathAlias: String? = properties.getProperty("DEBUG_KEY_STORE_PATH_ALIAS")

android {
    namespace = "com.asm.heatic"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.asm.heatic"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        create("release") {
            if (releaseKeyStorePath != null) {
                keyAlias = releaseKeyStorePathAlias
                keyPassword = releaseKeyStorePathPassword
                storeFile = file(releaseKeyStorePath)
                storePassword = releaseKeyStorePathPassword
            } else {
                println("Release key store path is null. Signing configuration cannot be created.")
            }
        }

        create("debug2") {
            //Currently at this stage we are using release key store not debug store.
            //Don't change anything in this
            if (releaseKeyStorePath != null) {
                keyAlias = releaseKeyStorePathAlias
                keyPassword = releaseKeyStorePathPassword
                storeFile = file(releaseKeyStorePath)
                storePassword = releaseKeyStorePathPassword
            } else {
                println("Debug key store path is null. Signing configuration cannot be created.")
            }
        }
    }

    buildTypes {
        getByName("release") {
            isMinifyEnabled = true
            isShrinkResources = true
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
            // Signing configuration for release build
            signingConfig = signingConfigs.getByName("release")
        }
        getByName("debug") {
            // Signing configuration for debug build
            signingConfig = signingConfigs.getByName("debug2")
        }
    }
}

flutter {
    source = "../.."
}
