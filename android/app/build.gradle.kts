import java.util.Properties
import java.io.FileInputStream

plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

// Load keystore properties from key.properties file
val keystorePropertiesFile = rootProject.file("key.properties")
val keystoreProperties = Properties()
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
}

android {
    namespace = "com.onecharge"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = "28.2.13676358"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        // Application ID for Google Play Store
        applicationId = "com.onecharge"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
        
        ndk {
            // Specify the architectures you want to support
            abiFilters += listOf("armeabi-v7a", "arm64-v8a", "x86_64")
        }
    }
    
    packagingOptions {
        // Exclude debug symbols from the release build
        jniLibs {
            useLegacyPackaging = false
        }
    }

    signingConfigs {
        // Only create release signing config if key.properties exists and has required properties
        val hasKeystore = keystorePropertiesFile.exists() && 
            keystoreProperties.containsKey("storeFile") && 
            keystoreProperties.containsKey("keyAlias")
        
        if (hasKeystore) {
            create("release") {
                keyAlias = keystoreProperties["keyAlias"] as String?
                keyPassword = keystoreProperties["keyPassword"] as String?
                storeFile = keystoreProperties["storeFile"]?.let { rootProject.file(it as String) }
                storePassword = keystoreProperties["storePassword"] as String?
            }
        }
    }

    buildTypes {
        release {
            // Only use release signing config if it exists, otherwise use debug signing for development
            val hasKeystore = keystorePropertiesFile.exists() && 
                keystoreProperties.containsKey("storeFile") && 
                keystoreProperties.containsKey("keyAlias")
            
            if (hasKeystore) {
                signingConfig = signingConfigs.getByName("release")
            } else {
                // Use debug signing for development builds when key.properties is not present
                signingConfig = signingConfigs.getByName("debug")
            }
            isMinifyEnabled = false
            isShrinkResources = false
        }
    }
}

flutter {
    source = "../.."
}
