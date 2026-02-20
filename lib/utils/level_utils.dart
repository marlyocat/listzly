import 'dart:math';

class LevelUtils {
  LevelUtils._();

  static const int maxLevel = 999;
  static const double _c = 50.0;
  static const double _e = 1.305;

  /// Total XP required to reach [level].
  static int xpForLevel(int level) {
    if (level <= 0) return 0;
    if (level > maxLevel) return xpForLevel(maxLevel);
    return (_c * pow(level, _e)).floor();
  }

  /// Current level given [totalXp].
  static int levelFromXp(int totalXp) {
    if (totalXp < _c) return 1;
    int level = pow(totalXp / _c, 1.0 / _e).floor();
    while (level < maxLevel && xpForLevel(level + 1) <= totalXp) {
      level++;
    }
    while (level > 1 && xpForLevel(level) > totalXp) {
      level--;
    }
    return level.clamp(1, maxLevel);
  }

  /// Progress fraction (0.0 to 1.0) toward the next level.
  static double progressToNextLevel(int totalXp) {
    final currentLevel = levelFromXp(totalXp);
    if (currentLevel >= maxLevel) return 1.0;
    final currentLevelXp = xpForLevel(currentLevel);
    final nextLevelXp = xpForLevel(currentLevel + 1);
    final range = nextLevelXp - currentLevelXp;
    if (range <= 0) return 1.0;
    return ((totalXp - currentLevelXp) / range).clamp(0.0, 1.0);
  }

  /// XP remaining to reach the next level.
  static int xpToNextLevel(int totalXp) {
    final currentLevel = levelFromXp(totalXp);
    if (currentLevel >= maxLevel) return 0;
    return xpForLevel(currentLevel + 1) - totalXp;
  }
}
