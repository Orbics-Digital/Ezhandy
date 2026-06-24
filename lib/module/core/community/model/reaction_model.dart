import 'package:flutter/material.dart';

class Reaction {
  final String label;
  final IconData icon;
  final Color color;
  final String? type;

  Reaction(this.label, this.icon, this.color, {this.type});
}

class CommunityReactionTypes {
  CommunityReactionTypes._();

  static const thumb = 'thumb';
  static const heart = 'heart';
  static const smile = 'smile';

  static final List<Reaction> reactions = [
    Reaction('Like', Icons.thumb_up, Colors.blue, type: thumb),
    Reaction('Love', Icons.favorite, Colors.red, type: heart),
    Reaction('Haha', Icons.emoji_emotions, Colors.orange, type: smile),
  ];

  static Reaction? fromType(String? type) {
    if (type == null) return null;
    for (final reaction in reactions) {
      if (reaction.type == type) return reaction;
    }
    return null;
  }
}
