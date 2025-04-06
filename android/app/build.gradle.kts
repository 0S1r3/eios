import com.android.build.gradle.internal.utils.ATTR_ENABLE_CORE_LIBRARY_DESUGARING

plugins {
    id("com.android.application")
    id("org.jetbrains.kotlin.android")
    // Плагин Flutter должен применяться после Android и Kotlin плагинов.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.eios"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = "27.0.12077973"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
        isCoreLibraryDesugaringEnabled = true  // В Kotlin DSL используется isCoreLibraryDesugaringEnabled
    }

    kotlinOptions {
        jvmTarget = "11"
    }

    defaultConfig {
        applicationId = "com.example.eios"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        getByName("release") {
            // Для сборки release используется debug подпись (только для теста)
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

dependencies {
    // Добавляем зависимость для десугаринга с использованием метода add
    add("coreLibraryDesugaring", "com.android.tools:desugar_jdk_libs:2.0.3")
}

flutter {
    source = "../.."
}
