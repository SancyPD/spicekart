# Stripe ProGuard Rules to fix R8 build errors
-dontwarn com.stripe.android.pushProvisioning.**

# Optional but recommended for Stripe/Flutter compatibility
-keep class com.stripe.android.** { *; }
-keep class com.reactnativestripesdk.** { *; }
