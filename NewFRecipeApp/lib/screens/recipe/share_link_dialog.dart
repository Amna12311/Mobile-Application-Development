import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/app_colors.dart';
import 'package:flutter/services.dart';
class ShareLinkDialog extends StatelessWidget {
  final BuildContext parentContext;

  const ShareLinkDialog({
    super.key,
    required this.parentContext,
  });

  @override
  Widget build(BuildContext context) {
    final String link = 'https://myrecipeapp.com/recipe';
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 18),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Expanded(
                  child: Text(
                    'Recipe Link',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                  ),
                ),
                InkWell(
                  onTap: () => Navigator.pop(context),
                  child: const Icon(Icons.close, size: 18),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Copy recipe link and share your recipe link with\nfriends and family.',
              style: TextStyle(
                fontSize: 12,
                color: Colors.black.withValues(alpha: 0.5),
                height: 1.3,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 14),

            // UI icons (still UI only)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                _CircleIcon(text: 'M', bg: Color(0xFFFFEBEE), fg: Color(0xFFD32F2F)),
                _CircleIcon(text: 'f', bg: Color(0xFFE3F2FD), fg: Color(0xFF1976D2)),
                _CircleIcon(text: 'W', bg: Color(0xFFE8F5E9), fg: Color(0xFF2E7D32)),
                _CircleIcon(text: 'IG', bg: Color(0xFFF3E5F5), fg: Color(0xFF7B1FA2)),
                _CircleIcon(text: 'S', bg: Color(0xFFFFFDE7), fg: Color(0xFFF9A825)),
              ],
            ),

            const SizedBox(height: 14),

            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF2F2F2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      link,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                  SizedBox(
                    height: 38,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () async {
                        await Clipboard.setData(ClipboardData(text: link));
                        Navigator.pop(context);

                        ScaffoldMessenger.of(parentContext).showSnackBar(
                          SnackBar(
                            content: const Text('Link Copied'),
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      },

                      child: const Text('Copy Link', style: TextStyle(fontWeight: FontWeight.w800)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CircleIcon extends StatelessWidget {
  final String text;
  final Color bg;
  final Color fg;

  const _CircleIcon({required this.text, required this.bg, required this.fg});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
      child: Center(
        child: Text(text, style: TextStyle(color: fg, fontWeight: FontWeight.w900)),
      ),
    );
  }
}
