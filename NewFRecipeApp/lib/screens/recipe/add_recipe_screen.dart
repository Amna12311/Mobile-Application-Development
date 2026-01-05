import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../core/app_colors.dart';
import '../../services/auth_service.dart';

class AddRecipeScreen extends StatefulWidget {
  const AddRecipeScreen({super.key});

  @override
  State<AddRecipeScreen> createState() => _AddRecipeScreenState();
}

class _AddRecipeScreenState extends State<AddRecipeScreen> {
  final _titleCtrl = TextEditingController();
  final _ingredientsCtrl = TextEditingController();
  final _timeCtrl = TextEditingController();

  bool _loading = false;

  @override
  void dispose() {
    _titleCtrl.dispose();
    _ingredientsCtrl.dispose();
    _timeCtrl.dispose();
    super.dispose();
  }

  Future<void> _saveRecipe() async {
    final title = _titleCtrl.text.trim();
    final ingredients = _ingredientsCtrl.text.trim();
    final timeText = _timeCtrl.text.trim();

    if (title.isEmpty || ingredients.isEmpty || timeText.isEmpty) {
      _toast('Please fill all fields');
      return;
    }

    final timeMinutes = int.tryParse(timeText);
    if (timeMinutes == null || timeMinutes <= 0) {
      _toast('Time must be a number (minutes)');
      return;
    }

    setState(() => _loading = true);

    try {
      final user = AuthService.instance.currentUser;
      if (user == null) {
        _toast('Please sign in first');
        return;
      }

      final uid = user.uid;

      // ✅ No image logic at all (static image is UI only)
      await FirebaseFirestore.instance.collection('recipes').add({
        'title': title,
        'ingredientsText': ingredients,
        'timeMinutes': timeMinutes,
        'authorId': uid,
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;
      Navigator.pop(context);
    } catch (e) {
      _toast('Failed: $e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _toast(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), behavior: SnackBarBehavior.floating),
    );
  }

  @override
  Widget build(BuildContext context) {
    const staticImageUrl =
        'https://images.unsplash.com/photo-1490645935967-10de6ba17061?w=1200';

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // top
              Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back),
                  ),
                  const SizedBox(width: 6),
                  const Text(
                    'Add New Recipe',
                    style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
                  ),
                ],
              ),

              const SizedBox(height: 10),

              // ✅ Static image only
              ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: SizedBox(
                  width: double.infinity,
                  height: 190,
                  child: Image.network(
                    staticImageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      color: Colors.black.withOpacity(0.06),
                      alignment: Alignment.center,
                      child: const Icon(Icons.fastfood, size: 60),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              const Text(
                'Recipe Name:',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 10),
              _field(_titleCtrl, 'Name'),

              const SizedBox(height: 22),

              const Text(
                'Ingredients:',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 10),
              _field(_ingredientsCtrl, 'Add Ingredients', maxLines: 3),

              const SizedBox(height: 22),

              const Text(
                'Time (minutes):',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 10),
              _field(_timeCtrl, 'Required Time',
                  keyboard: TextInputType.number),

              const SizedBox(height: 34),

              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  onPressed: _loading ? null : _saveRecipe,
                  child: _loading
                      ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                      : const Text(
                    'Save',
                    style: TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _field(
      TextEditingController c,
      String hint, {
        TextInputType keyboard = TextInputType.text,
        int maxLines = 1,
      }) {
    return TextField(
      controller: c,
      keyboardType: keyboard,
      maxLines: maxLines,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Color(0xFFBDBDBD)),
        contentPadding:
        const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE6E6E6), width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.4),
        ),
      ),
    );
  }
}
