// Inject dummy jcenter method to RepositoryHandler class for Groovy scripts
try {
    val shell = groovy.lang.GroovyShell()
    shell.evaluate("""
        org.gradle.api.artifacts.dsl.RepositoryHandler.metaClass.jcenter = { ->
            delegate.mavenCentral()
        }
    """)
    println("Successfully mocked jcenter() for Groovy subprojects!")
} catch (e: Exception) {
    println("Failed to mock jcenter(): ${e.message}")
}

pluginManagement {
    val flutterSdkPath =
        run {
            val properties = java.util.Properties()
            file("local.properties").inputStream().use { properties.load(it) }
            val flutterSdkPath = properties.getProperty("flutter.sdk")
            require(flutterSdkPath != null) { "flutter.sdk not set in local.properties" }
            flutterSdkPath
        }

    includeBuild("$flutterSdkPath/packages/flutter_tools/gradle")

    repositories {
        google()
        mavenCentral()
        gradlePluginPortal()
    }
}

plugins {
    id("dev.flutter.flutter-plugin-loader") version "1.0.0"
    id("com.android.application") version "8.11.1" apply false
    id("org.jetbrains.kotlin.android") version "2.3.20" apply false
}

include(":app")
