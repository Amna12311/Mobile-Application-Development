import 'package:flutter/material.dart';
import '../../core/app_colors.dart';

class RateRecipeDialog extends StatefulWidget {
  const RateRecipeDialog({super.key});

  @override
  State<RateRecipeDialog> createState() => _RateRecipeDialogState();
}

class _RateRecipeDialogState extends State<RateRecipeDialog> {
  int stars = 0;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Rate recipe', style: TextStyle(fontWeight: FontWeight.w800)),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (i) {
                final index = i + 1;
                return IconButton(
                  onPressed: () => setState(() => stars = index),
                  icon: Icon(Icons.star, color: index <= stars ? AppColors.orange : Colors.black26),
                );
              }),
            ),
            const SizedBox(height: 4),
            SizedBox(
              height: 32,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: stars == 0 ? Colors.black12 : AppColors.orange,
                  foregroundColor: stars == 0 ? Colors.black38 : Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                onPressed: stars == 0 ? null : () => Navigator.pop(context),
                child: const Text('Send', style: TextStyle(fontWeight: FontWeight.w800)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
