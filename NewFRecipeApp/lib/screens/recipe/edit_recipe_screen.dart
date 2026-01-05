import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/app_colors.dart';

class EditRecipeScreen extends StatefulWidget {
  final String recipeId;
  final Map<String, dynamic> data;

  const EditRecipeScreen({
    super.key,
    required this.recipeId,
    required this.data,
  });

  @override
  State<EditRecipeScreen> createState() => _EditRecipeScreenState();
}

class _EditRecipeScreenState extends State<EditRecipeScreen> {
  late TextEditingController _titleCtrl;
  late TextEditingController _ingredientsCtrl;
  late TextEditingController _timeCtrl;

  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _titleCtrl = TextEditingController(text: (widget.data['title'] ?? '').toString());
    _ingredientsCtrl =
        TextEditingController(text: (widget.data['ingredientsText'] ?? '').toString());
    _timeCtrl = TextEditingController(text: (widget.data['timeMinutes'] ?? '').toString());
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _ingredientsCtrl.dispose();
    _timeCtrl.dispose();
    super.dispose();
  }

  Future<void> _updateRecipe() async {
    final title = _titleCtrl.text.trim();
    final ingredients = _ingredientsCtrl.text.trim();
    final timeText = _timeCtrl.text.trim();

    if (title.isEmpty || ingredients.isEmpty || timeText.isEmpty) {
      _toast('Please fill all fields');
      return;
    }

    final timeMinutes = int.tryParse(timeText);
    if (timeMinutes == null || timeMinutes <= 0) {
      _toast('Time must be a valid number');
      return;
    }

    setState(() => _loading = true);

    try {
      await FirebaseFirestore.instance.collection('recipes').doc(widget.recipeId).update({
        'title': title,
        'ingredientsText': ingredients,
        'timeMinutes': timeMinutes,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;
      Navigator.pop(context);
    } catch (e) {
      _toast('Update failed: $e');
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
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Edit Recipe',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(18, 10, 18, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top info card (UI only)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF7F7F7),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: const Color(0xFFEAEAEA)),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(Icons.edit, color: AppColors.primary),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        'Update your recipe details',
                        style: TextStyle(fontWeight: FontWeight.w800),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 18),

              // Form card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF7F7F7),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: const Color(0xFFEAEAEA)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const _Label('Recipe Name'),
                    const SizedBox(height: 8),
                    _field(_titleCtrl, 'e.g., Chicken Biryani'),

                    const SizedBox(height: 16),

                    const _Label('Ingredients'),
                    const SizedBox(height: 8),
                    _field(
                      _ingredientsCtrl,
                      'Write ingredients here...',
                      maxLines: 4,
                    ),

                    const SizedBox(height: 16),

                    const _Label('Time (minutes)'),
                    const SizedBox(height: 8),
                    _field(
                      _timeCtrl,
                      'e.g., 30',
                      keyboard: TextInputType.number,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 18),

              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  onPressed: _loading ? null : _updateRecipe,
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
                    'Update Recipe',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
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
      TextEditingController ctrl,
      String hint, {
        int maxLines = 1,
        TextInputType keyboard = TextInputType.text,
      }) {
    return TextField(
      controller: ctrl,
      maxLines: maxLines,
      keyboardType: keyboard,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.black.withValues(alpha: 0.35)),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFE6E6E6)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.4),
        ),
      ),
    );
  }
}

class _Label extends StatelessWidget {
  final String text;
  const _Label(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w800,
      ),
    );
  }
}
