import 'package:flutter/material.dart';

class AchievementDef {
  const AchievementDef({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.xp,
  });
  final String id;
  final String title;
  final String description;
  final IconData icon;
  final int xp;
}

class Achievements {
  Achievements._();
  static const expertScore = 90;

  static const all = <AchievementDef>[
    AchievementDef(
      id: 'penjelajah_pemula',
      title: 'Penjelajah Pemula',
      description: 'Selesaikan bab pertama.',
      icon: Icons.explore,
      xp: 25,
    ),
    AchievementDef(
      id: 'pengenal_budaya',
      title: 'Pengenal Budaya',
      description: 'Selesaikan dua bab.',
      icon: Icons.menu_book,
      xp: 25,
    ),
    AchievementDef(
      id: 'penjelajah_lampung',
      title: 'Penjelajah Lampung',
      description: 'Selesaikan seluruh bab perjalanan.',
      icon: Icons.emoji_events,
      xp: 50,
    ),
    AchievementDef(
      id: 'ahli_budaya',
      title: 'Ahli Budaya',
      description: 'Raih nilai kuis minimal $expertScore.',
      icon: Icons.workspace_premium,
      xp: 50,
    ),
  ];

  static AchievementDef? byId(String id) {
    for (final a in all) {
      if (a.id == id) return a;
    }
    return null;
  }

  /// Lencana yang baru diperoleh (belum ada di [owned]).
  static List<AchievementDef> evaluate({
    required int completedCount,
    required int totalChapters,
    required int score,
    required Set<String> owned,
  }) {
    final earned = <String>{
      if (completedCount >= 1) 'penjelajah_pemula',
      if (completedCount >= 2) 'pengenal_budaya',
      if (totalChapters > 0 && completedCount >= totalChapters) 'penjelajah_lampung',
      if (score >= expertScore) 'ahli_budaya',
    };
    return all.where((a) => earned.contains(a.id) && !owned.contains(a.id)).toList();
  }
}
