import 'package:flutter/material.dart';
import 'package:pesca_app/core/theme/app_theme.dart';

class CatchAndReleaseBadge extends StatelessWidget {
  final bool isReleased;
  final bool isLarge;

  const CatchAndReleaseBadge({
    super.key,
    required this.isReleased,
    this.isLarge = false,
  });

  @override
  Widget build(BuildContext context) {
    if (isReleased) {
      return Container(
        padding: EdgeInsets.symmetric(
          horizontal: isLarge ? 12 : 8,
          vertical: isLarge ? 6 : 3,
        ),
        decoration: BoxDecoration(
          color: AppTheme.primaryGreen.withValues(alpha: 0.18),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppTheme.primaryGreen, width: 1.5),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.eco_rounded, size: isLarge ? 18 : 14, color: AppTheme.primaryGreen),
            const SizedBox(width: 4),
            Text(
              'Pescou & Soltou 🌿',
              style: TextStyle(
                color: AppTheme.primaryGreen,
                fontWeight: FontWeight.bold,
                fontSize: isLarge ? 14 : 11,
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isLarge ? 12 : 8,
        vertical: isLarge ? 6 : 3,
      ),
      decoration: BoxDecoration(
        color: Colors.redAccent.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.redAccent.withValues(alpha: 0.5), width: 1.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.phishing_rounded, size: isLarge ? 18 : 14, color: Colors.redAccent),
          const SizedBox(width: 4),
          Text(
            'Retido 🎣',
            style: TextStyle(
              color: Colors.redAccent,
              fontWeight: FontWeight.bold,
              fontSize: isLarge ? 14 : 11,
            ),
          ),
        ],
      ),
    );
  }
}
