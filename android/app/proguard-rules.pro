# Flutter Local Notifications Proguard Keep Rules
-keep class com.dexterous.flutterlocalnotifications.** { *; }
-keepclassmembers class com.dexterous.flutterlocalnotifications.** { *; }

# Audio Service & Just Audio Proguard Keep Rules
-keep class com.ryanheise.audioservice.** { *; }
-keepclassmembers class com.ryanheise.audioservice.** { *; }
-keep class com.ryanheise.just_audio.** { *; }

# Timezone Data Proguard Keep Rules
-keep class timezone.** { *; }
-keep class com.timezone.** { *; }
