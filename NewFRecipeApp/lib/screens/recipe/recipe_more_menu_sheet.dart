import 'package:flutter/material.dart';

class RecipeMoreMenuSheet extends StatelessWidget {
  final VoidCallback onShare;
  final VoidCallback onRate;
  final VoidCallback onReview;
  final VoidCallback onUnsave;

  const RecipeMoreMenuSheet({
    super.key,
    required this.onShare,
    required this.onRate,
    required this.onReview,
    required this.onUnsave,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topRight,
      child: Padding(
        padding: const EdgeInsets.only(top: 70, right: 18),
        child: Material(
          borderRadius: BorderRadius.circular(12),
          color: Colors.white,
          child: SizedBox(
            width: 220,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _item(icon: Icons.share_outlined, text: 'share', onTap: onShare),
                _item(icon: Icons.star_border, text: 'Rate Recipe', onTap: onRate),
                _item(icon: Icons.chat_bubble_outline, text: 'Review', onTap: onReview),
                _item(icon: Icons.bookmark_remove_outlined, text: 'Unsave', onTap: onUnsave, divider: false),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _item({
    required IconData icon,
    required String text,
    required VoidCallback onTap,
    bool divider = true,
  }) {
    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              children: [
                Icon(icon, size: 20),
                const SizedBox(width: 12),
                Text(text, style: const TextStyle(fontWeight: FontWeight.w600)),
              ],
            ),
          ),
          if (divider) const Divider(height: 1),
        ],
      ),
    );
  }
}
