# Add project specific ProGuard rules here.
# You can control the set of applied configuration files using the
# proguardFiles setting in build.gradle.
#
# For more details, see
#   http://developer.android.com/guide/developing/tools/proguard.html

# If your project uses WebView with JS, uncomment the following
# and specify the fully qualified class name to the JavaScript interface
# class:
#-keepclassmembers class fqcn.of.javascript.interface.for.webview {
#   public *;
#}

# Uncomment this to preserve the line number information for
# debugging stack traces.
#-keepattributes SourceFile,LineNumberTable

# If you keep the line number information, uncomment this to
# hide the original source file name.
#-renamesourcefileattribute SourceFile

# Flutter specific rules (see https://github.com/flutter/flutter/wiki/Android-Project-Migration).
# Do NOT add a blanket `-keep class io.flutter.** { *; }`: it pins every embedding class, including
# `FlutterPlayStoreSplitApplication` / `PlayStoreDeferredComponentManager`, which reference Google Play
# Core (split install). F-Droid's APK scanner rejects those dex entries. R8 then keeps only code
# reachable from your manifest / `MainActivity` → `FlutterActivity`.
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.plugins.** { *; }

# Hive specific rules
-keep class * extends com.google.protobuf.GeneratedMessageLite { *; }
-keep class * implements androidx.annotation.Keep { *; }
-keep @androidx.annotation.Keep class * { *; }
-keepclassmembers class * {
    @androidx.annotation.Keep *;
}

# Sonic (Apache 2.0) — time/pitch processing used by offline export
-keep class sonic.Sonic { *; }
-dontwarn sonic.**

