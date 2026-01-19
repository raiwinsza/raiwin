plugins {
    id("com.android.application")

    // START: FlutterFire Configuration
    id("com.google.gms.google-services") // เปิดใช้งาน plugin ที่ app-level
    // END: FlutterFire Configuration

    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.company.raiwin"
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
        applicationId = "com.company.raiwin"  // ต้องตรงกับ Firebase
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

dependencies {
    // Firebase BoM
    implementation(platform("com.google.firebase:firebase-bom:34.7.0"))

    // Firebase Analytics ตัวอย่าง
    implementation("com.google.firebase:firebase-analytics")

    // ถ้าต้องการ SDK อื่น ๆ เช่น Firestore, Auth, Messaging
    // implementation("com.google.firebase:firebase-firestore")
    // implementation("com.google.firebase:firebase-auth")
    // implementation("com.google.firebase:firebase-messaging")
}

flutter {
    source = "../.."
}
