import java.util.Properties
import java.io.File

plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

fun loadEnv(): Properties {
    val dotenv = Properties()
    val envFile = File("${rootProject.projectDir}/../.env") // .env 파일 경로
    if (envFile.exists()) {
        envFile.inputStream().use { dotenv.load(it) }
    } else {
        throw GradleException(".env file not found in project root")
    }
    return dotenv
}

// 환경 변수 로드
val dotenv = loadEnv()
val kakaoKey = dotenv.getProperty("KAKAO_NATIVE_APP_KEY") ?: ""
val defaultWebClientId = dotenv.getProperty("DEFAULT_WEB_CLIENT_ID") ?: ""
val appName = dotenv.getProperty("APP_NAME") ?: ""
val facebookAppId = dotenv.getProperty("FACEBOOK_APP_ID") ?: ""
val fbLoginProtocolScheme = dotenv.getProperty("FB_LOGIN_PROTOCOL_SCHEME") ?: ""
val facebookClientToken = dotenv.getProperty("FACEBOOK_CLIENT_TOKEN") ?: ""

android {
    namespace = "com.example.nansan_flutter"
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
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.example.nansan_flutter"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName

        if (kakaoKey.isEmpty()) throw GradleException("KAKAO_NATIVE_APP_KEY not found in .env file")
        if (defaultWebClientId.isEmpty()) throw GradleException("DEFAULT_WEB_CLIENT_ID not found in .env file")
        if (appName.isEmpty()) throw GradleException("APP_NAME not found in .env file")
        if (facebookAppId.isEmpty()) throw GradleException("FACEBOOK_APP_ID not found in .env file")
        if (fbLoginProtocolScheme.isEmpty()) throw GradleException("FB_LOGIN_PROTOCOL_SCHEME not found in .env file")
        if (facebookClientToken.isEmpty()) throw GradleException("FACEBOOK_CLIENT_TOKEN not found in .env file")

        // manifestPlaceholders에 환경 변수 추가
        manifestPlaceholders["KAKAO_NATIVE_APP_KEY"] = kakaoKey
        // `res/values/strings.xml`에 환경 변수 추가
        resValue("string", "kakao_api_key", kakaoKey)
        resValue("string", "default_web_client_id", defaultWebClientId)
        resValue("string", "app_name", appName)
        resValue("string", "facebook_app_id", facebookAppId)
        resValue("string", "fb_login_protocol_scheme", fbLoginProtocolScheme)
        resValue("string", "facebook_client_token", facebookClientToken)
    }

    buildTypes {
        debug {
            // TODO: Add your own signing config for the release build.
            // Signing with the debug keys for now, so `flutter run --release` works.
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}
