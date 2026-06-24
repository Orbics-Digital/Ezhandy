import 'package:ezhandy_user/module/core/community/model/reaction_model.dart';
import 'package:flutter/material.dart';

class FacebookReactionButton extends StatefulWidget {
  final void Function()? onTap;
  final void Function(String reactionType)? onReactionSelected;
  final String? selectedReactionType;
  final bool communityMode;

  FacebookReactionButton({
    this.onTap,
    this.onReactionSelected,
    this.selectedReactionType,
    this.communityMode = false,
    super.key,
  });

  @override
  State<FacebookReactionButton> createState() =>
      _FacebookReactionButtonState();
}

class _FacebookReactionButtonState extends State<FacebookReactionButton> {
  final GlobalKey _key = GlobalKey();
  Reaction? selectedReaction;
  OverlayEntry? overlayEntry;

  final List<Reaction> reactions = [
    Reaction("Like", Icons.thumb_up, Colors.blue),
    Reaction("Love", Icons.favorite, Colors.red),
    Reaction("Haha", Icons.emoji_emotions, Colors.orange),
    Reaction("Wow", Icons.sentiment_satisfied, Colors.amber),
    Reaction("Sad", Icons.sentiment_dissatisfied, Colors.blueGrey),
    Reaction("Angry", Icons.sentiment_very_dissatisfied, Colors.redAccent),
  ];

  List<Reaction> get _availableReactions =>
      widget.communityMode ? CommunityReactionTypes.reactions : reactions;

  @override
  void initState() {
    super.initState();
    selectedReaction =
        CommunityReactionTypes.fromType(widget.selectedReactionType);
  }

  @override
  void didUpdateWidget(covariant FacebookReactionButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedReactionType != oldWidget.selectedReactionType) {
      selectedReaction =
          CommunityReactionTypes.fromType(widget.selectedReactionType);
    }
  }

  void _selectReaction(Reaction reaction) {
    setState(() {
      selectedReaction = reaction;
    });
    overlayEntry?.remove();
    overlayEntry = null;

    if (reaction.type != null) {
      widget.onReactionSelected?.call(reaction.type!);
    }
  }

  void showReactions() {
    final renderBox = _key.currentContext!.findRenderObject() as RenderBox;
    final position = renderBox.localToGlobal(Offset.zero);

    overlayEntry = OverlayEntry(
      builder: (_) => Positioned(
        left: position.dx - 20,
        top: position.dy - 55,
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(30),
              boxShadow: const [
                BoxShadow(
                  blurRadius: 10,
                  color: Colors.black26,
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: _availableReactions.map((reaction) {
                return GestureDetector(
                  onTap: () => _selectReaction(reaction),
                  child: Padding(
                    padding: const EdgeInsets.all(6),
                    child: Icon(
                      reaction.icon,
                      color: reaction.color,
                      size: 26,
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ),
    );

    Overlay.of(context).insert(overlayEntry!);
  }

  @override
  void dispose() {
    hideReactions();
    super.dispose();
  }

  void hideReactions() {
    overlayEntry?.remove();
    overlayEntry = null;
  }

  @override
  Widget build(BuildContext context) {
    final usesCommunityApi = widget.onReactionSelected != null;

    return GestureDetector(
      key: _key,
      onTap: usesCommunityApi
          ? () {
              final reaction = selectedReaction ?? _availableReactions.first;
              _selectReaction(reaction);
            }
          : widget.onTap ??
              () {
                setState(() {
                  selectedReaction =
                      selectedReaction == null ? reactions[0] : null;
                });
              },
      onLongPress: usesCommunityApi ? showReactions : widget.onTap ?? showReactions,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            selectedReaction?.icon ?? Icons.thumb_up_off_alt,
            color: selectedReaction?.color ?? Colors.grey,
            size: 18,
          ),
          const SizedBox(width: 6),
          Text(
            selectedReaction?.label ?? "Like",
            style: TextStyle(
              color: selectedReaction?.color ?? Colors.grey,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
