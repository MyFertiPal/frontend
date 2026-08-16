import java.io.FileInputStream
import java.util.Properties

fun autoVersionCode(): Int {
    return try {
        // Use a simple timestamp-based version code for debug builds
        val versionCode = (System.currentTimeMillis() / 1000).toInt() % 1000000
        if (versionCode > 0) versionCode else 1
    } catch (_: Exception) {
        1
    }
}

plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
    id("com.google.gms.google-services")
}

val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
}

val releaseKeystoreFile = (keystoreProperties["storeFile"] as String?)?.let { rootProject.file(it) }
val releaseKeystoreConfigured =
    keystorePropertiesFile.exists() &&
        !((keystoreProperties["keyAlias"] as String?).orEmpty().isBlank()) &&
        !((keystoreProperties["keyPassword"] as String?).orEmpty().isBlank()) &&
        !((keystoreProperties["storePassword"] as String?).orEmpty().isBlank()) &&
        releaseKeystoreFile?.exists() == true

android {
    namespace = "com.myfertipall.app"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
        isCoreLibraryDesugaringEnabled = true
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.myfertipall.app"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = autoVersionCode()
        versionName = flutter.versionName
    }

    lint {
        checkReleaseBuilds = false
        abortOnError = false
    }

    signingConfigs {
        create("release") {
            keyAlias = keystoreProperties["keyAlias"] as String?
            keyPassword = keystoreProperties["keyPassword"] as String?
            storeFile = (keystoreProperties["storeFile"] as String?)?.let { rootProject.file(it) }
            storePassword = keystoreProperties["storePassword"] as String?
        }
    }

    buildTypes {
        release {
            isMinifyEnabled = false
            isShrinkResources = false
            if (!releaseKeystoreConfigured) {
                throw org.gradle.api.GradleException(
                        "Release signing is not configured. Add android/key.properties and android/app/permanent-upload-keystore.jks before building an AAB for Play Console."
                )
            }
            signingConfig = signingConfigs.getByName("release")
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
    implementation("co.paystack.android:paystack:3.1.3")
}
