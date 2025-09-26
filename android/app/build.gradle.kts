plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
    // Google services plugin for Firebase
    id("com.google.gms.google-services")
    id("com.google.firebase.crashlytics")
}

android {
    namespace = "com.sa3eed.oscar"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = "27.0.12077973"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        applicationId = "com.sa3eed.oscar"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
        
        // Add these for faster builds
        multiDexEnabled = true
    }

    signingConfigs {
        create("release") {
            // Use environment variables or gradle.properties for signing
            // Set these in your local.properties or environment:
            // OSCAR_KEYSTORE_PATH=/path/to/your/keystore.jks
            // OSCAR_KEYSTORE_PASSWORD=your_keystore_password
            // OSCAR_KEY_ALIAS=your_key_alias
            // OSCAR_KEY_PASSWORD=your_key_password
            
            val keystorePath = project.findProperty("OSCAR_KEYSTORE_PATH") as String?
            val keystorePassword = project.findProperty("OSCAR_KEYSTORE_PASSWORD") as String?
            val keyAlias = project.findProperty("OSCAR_KEY_ALIAS") as String?
            val keyPassword = project.findProperty("OSCAR_KEY_PASSWORD") as String?
            
            if (keystorePath != null && keystorePassword != null && keyAlias != null && keyPassword != null) {
                storeFile = file(keystorePath)
                storePassword = keystorePassword
                keyAlias = keyAlias
                keyPassword = keyPassword
            } else {
                // Fallback to debug signing if release signing is not configured
                storeFile = file("debug.keystore")
                storePassword = "android"
                keyAlias = "androiddebugkey"
                keyPassword = "android"
            }
        }
    }

    buildTypes {
        debug {
            // Optimize debug builds
            isMinifyEnabled = false
            isShrinkResources = false
            isDebuggable = true
        }
        release {
            signingConfig = signingConfigs.getByName("release")
            isMinifyEnabled = true
            isShrinkResources = true
            isDebuggable = false
        }
    }
    
    // Add build optimizations
    packagingOptions {
        resources {
            excludes += listOf(
                "META-INF/DEPENDENCIES",
                "META-INF/LICENSE",
                "META-INF/LICENSE.txt",
                "META-INF/NOTICE",
                "META-INF/NOTICE.txt"
            )
        }
    }
}

flutter {
    source = "../.."
}
