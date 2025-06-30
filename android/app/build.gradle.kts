import java.util.Properties
import java.io.File
import java.io.FileInputStream

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

//val keystoreProperties = Properties().apply {
//    val keystoreFile = rootProject.file("app/key.properties")
//    if (keystoreFile.exists()) {
//        load(FileInputStream(keystoreFile))
//    }
//}

android {
    namespace = "com.ssafy.soonamu"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = "29.0.13113456 rc1"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.ssafy.soonamu"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = 29
        targetSdk = flutter.targetSdkVersion
        versionCode = 37
        versionName = "1.1.37"

        if (kakaoKey.isEmpty()) throw GradleException("KAKAO_NATIVE_APP_KEY not found in .env file")
        if (defaultWebClientId.isEmpty()) throw GradleException("DEFAULT_WEB_CLIENT_ID not found in .env file")
        if (appName.isEmpty()) throw GradleException("APP_NAME not found in .env file")

        // manifestPlaceholders에 환경 변수 추가
        manifestPlaceholders["KAKAO_NATIVE_APP_KEY"] = kakaoKey
        // `res/values/strings.xml`에 환경 변수 추가
        resValue("string", "kakao_api_key", kakaoKey)
        resValue("string", "default_web_client_id", defaultWebClientId)
        resValue("string", "app_name", appName)

    }

    signingConfigs {
        create("release") {
//            keyAlias = keystoreProperties["keyAlias"] as String?
//            keyPassword = keystoreProperties["keyPassword"] as String?
//            storeFile = file(keystoreProperties["storeFile"] as String?)
//            storePassword = keystoreProperties["storePassword"] as String?
        }
    }

    buildTypes {
        getByName("release") {
            signingConfig = signingConfigs.getByName("release")
            isMinifyEnabled = true
            isShrinkResources = true
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    implementation("org.tensorflow:tensorflow-lite-gpu-api:+")
}