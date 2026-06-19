// lib/theme/tokens.dart
import 'package:flutter/material.dart';

class Tokens {
  // Brand
  static const seed = Color(0xFF0098DB); // primary seed (you can read from storage later)

  // Spacing
  static const space2  = 2.0;
  static const space4  = 4.0;
  static const space8  = 8.0;
  static const space12 = 12.0;
  static const space16 = 16.0;
  static const space20 = 20.0;
  static const space24 = 24.0;
  static const space32 = 32.0;

  // Radii
  static const radius8  = 8.0;
  static const radius12 = 12.0;
  static const radius16 = 16.0;
  static const radius24 = 24.0;

  // Elevation
  static const elev0 = 0.0;
  static const elev1 = 1.0;
  static const elev3 = 3.0;
  static const elev6 = 6.0;

  // Durations
  static const fast = Duration(milliseconds: 120);
  static const normal = Duration(milliseconds: 220);
  static const slow = Duration(milliseconds: 360);

  // Typography (you can wire a custom font here)
  static const fontFamily = 'Montserrat';
}
