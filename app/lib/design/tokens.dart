//Settings of Flutter opening files

import 'package:flutter/material.dart';

// 1) RENKLER: Light ve dark için iki set.
@immutable
class AppColors {
  const AppColors({
    required this.primary,
    required this.surface,
    required this.onSurface,
    required this.muted,
    required this.success,
    required this.danger,
  });


    final Color primary;   // ana marka rengi (buton, vurgu)
    final Color surface;   // arka plan
    final Color onSurface; // arka plan üstündeki yazı
    final Color muted;     // ikincil yazı
    final Color success;   // doğru cevap
    final Color danger;    // yanlış cevap / hata


    static const light = AppColors(
    primary: Color(0xFF6C4CF5),
    surface: Color(0xFFFFFFFF),
    onSurface: Color(0xFF14121F),
    muted: Color(0xFF8A879A),
    success: Color(0xFF1DB954),
    danger: Color(0xFFE5484D),
  );

    static const dark = AppColors(
    primary: Color(0xFF8B73FF),
    surface: Color(0xFF14121F),
    onSurface: Color(0xFFF4F3F8),
    muted: Color(0xFF9C99AD),
    success: Color(0xFF3DDC84),
    danger: Color(0xFFFF6B6F),
  );


    // İki renk seti arasında t (0..1) oranında ara değer üretir.
  // Tema değişirken renkler aniden değil, yumuşakça geçer.
  static AppColors lerp(AppColors a, AppColors b, double t) => AppColors(
        primary: Color.lerp(a.primary, b.primary, t)!,
        surface: Color.lerp(a.surface, b.surface, t)!,
        onSurface: Color.lerp(a.onSurface, b.onSurface, t)!,
        muted: Color.lerp(a.muted, b.muted, t)!,
        success: Color.lerp(a.success, b.success, t)!,
        danger: Color.lerp(a.danger, b.danger, t)!,
      );
}


// 2) SPACING: 4pt grid. Tüm boşluklar 4'ün katı.
@immutable
class AppSpacing {
  const AppSpacing();
  final double xs = 4;
  final double sm = 8;
  final double md = 16;
  final double lg = 24;
  final double xl = 32;
}


// 3) RADIUS: köşe yuvarlaklıkları.
@immutable
class AppRadius {
  const AppRadius();
  final double sm = 8;
  final double md = 12;
  final double lg = 20;
}

// 4) HEPSİNİ TEMAYA BAĞLAYAN SINIF.
@immutable
class AppTokens extends ThemeExtension<AppTokens> {
  const AppTokens({
    required this.colors,
    this.spacing = const AppSpacing(),
    this.radius = const AppRadius(),
  });

  final AppColors colors;
  final AppSpacing spacing;
  final AppRadius radius;

  static const light = AppTokens(colors: AppColors.light);
  static const dark = AppTokens(colors: AppColors.dark);

// ThemeExtension bunu zorunlu tutar: bir alanı değiştirip kopya üretmek için.
  @override
  AppTokens copyWith({AppColors? colors, AppSpacing? spacing, AppRadius? radius}) =>
      AppTokens(
        colors: colors ?? this.colors,
        spacing: spacing ?? this.spacing,
        radius: radius ?? this.radius,
      );

  // ThemeExtension bunu da zorunlu tutar: tema geçiş animasyonu için.
  @override
  AppTokens lerp(ThemeExtension<AppTokens>? other, double t) {
    if (other is! AppTokens) return this;
    return copyWith(colors: AppColors.lerp(colors, other.colors, t));
  }
}

// 5) KISAYOL: her widget'ta `context.tokens.colors.primary` diyebilmek için.
extension TokensX on BuildContext {
  AppTokens get tokens => Theme.of(this).extension<AppTokens>()!;
}
