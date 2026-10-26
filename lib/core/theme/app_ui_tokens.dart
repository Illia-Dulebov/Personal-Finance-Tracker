import 'package:flutter/material.dart';

import 'app_theme.dart';

abstract final class AppSpacing {
  static const xs = 4.0;
  static const sm = 8.0;
  static const md = 12.0;
  static const lg = 16.0;
  static const xl = 20.0;
  static const xxl = 24.0;
}

abstract final class AppRadii {
  static const field = 10.0;
  static const chip = 16.0;
}

abstract final class AppTextStyles {
  static const amount = TextStyle(
    fontFamily: 'Fraunces',
    fontSize: 40,
    fontWeight: FontWeight.w500,
    color: AppTheme.ink,
  );

  static const amountSmall = TextStyle(
    fontFamily: 'Fraunces',
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: AppTheme.ink,
  );

  static const fieldLabel = TextStyle(color: AppTheme.muted, fontSize: 11);
  static const fieldValue = TextStyle(fontSize: 14);
  static const chip = TextStyle(fontSize: 12);
  static const caption = TextStyle(color: AppTheme.muted, fontSize: 11);
  static const lockedValue = TextStyle(
    color: AppTheme.muted,
    fontSize: 13,
    fontStyle: FontStyle.italic,
  );
  static const action = TextStyle(fontSize: 14, fontWeight: FontWeight.w500);
  static const deleteAction = TextStyle(
    color: AppTheme.rust,
    fontWeight: FontWeight.w400,
    fontSize: 13,
  );
}
