import 'package:flutter/material.dart';

extension LocalizedNumber on int {
  String toLocalizedNumber(
    BuildContext context, {
    bool? forceEnglish,
    bool? forceUrdu,
  }) {
    // Agar ForceEnglish True Hai To Seedha English Mein Return Karo, Koi Aur Check Nahi
    if (forceEnglish == true) return toString();

    // Agar ForceUrdu True Hai To Locale Check Kiye Baghair Urdu Mein Convert Karo
    if (forceUrdu == true) return _toUrduNumbers(this);

    // Hum Localizations.localeOf(context) Use Kar Rahe Hain Jo Flutter Ka Standard Tarika Hai
    // AppSettings Riverpod Mein Hain, Isliye Extension Mein Context Se Locale Lena Behtar Hai
    final locale = Localizations.localeOf(context);

    // Default: Maujuda Locale Ko Follow Karo
    if (locale.languageCode == 'ur') {
      return _toUrduNumbers(this);
    }

    // Agar Locale Urdu Nahi Hai To English Digits Return Karo
    return toString();
  }

  String _toUrduNumbers(int input) {
    // English Aur Urdu Digits Ki Lists Jo Replacement Ke Liye Use Hongi
    const english = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];
    const urdu = ['۰', '۱', '۲', '۳', '۴', '۵', '۶', '۷', '۸', '۹'];

    // Pehle Number Ko String Mein Badlo Phir Har English Digit Ko Urdu Se Replace Karo
    String result = input.toString();
    for (int i = 0; i < english.length; i++) {
      result = result.replaceAll(english[i], urdu[i]);
    }
    return result;
  }
}
