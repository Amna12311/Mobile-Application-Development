import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../reviews/reviews_screen.dart';
import 'edit_recipe_screen.dart';
import '../../core/app_colors.dart';

class RecipeDetailScreen extends StatelessWidget {
  final String recipeId;

  const RecipeDetailScreen({
    super.key,
    required this.recipeId,
  });

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;

    // ✅ Static image only (no Firebase Storage)
    const staticImageUrl =
        'https://images.unsplash.com/photo-1504674900247-0877df9cc836?w=1200';

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance
              .collection('recipes')
              .doc(recipeId)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (!snapshot.hasData || !snapshot.data!.exists) {
              return const Center(child: Text('Recipe not found'));
            }

            final data = snapshot.data!.data() as Map<String, dynamic>;
            final title = (data['title'] ?? 'Untitled').toString();
            final ingredients = (data['ingredientsText'] ?? '').toString();
            final mins = (data['timeMinutes'] ?? 0).toString();
            final isOwner = uid != null && (data['authorId']?.toString() == uid);

            return CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Container(
                    margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                    height: 230,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(22),
                      color: Colors.black.withOpacity(0.06),
                    ),
                    child: Stack(
                      children: [
                        Positioned.fill(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(22),
                            child: Image.network(
                              staticImageUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Container(
                                alignment: Alignment.center,
                                color: Colors.black.withOpacity(0.06),
                                child: const Icon(Icons.fastfood, size: 72),
                              ),
                            ),
                          ),
                        ),

                        Positioned(
                          left: 10,
                          top: 10,
                          child: _RoundIconBtn(
                            icon: Icons.arrow_back,
                            onTap: () => Navigator.pop(context),
                          ),
                        ),

                        Positioned(
                          right: 10,
                          top: 10,
                          child: Row(
                            children: [
                              if (isOwner)
                                _RoundIconBtn(
                                  icon: Icons.edit,
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => EditRecipeScreen(
                                          recipeId: recipeId,
                                          data: data,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              const SizedBox(width: 10),
                              _RoundIconBtn(
                                icon: Icons.bookmark_border,
                                onTap: () async {
                                  if (uid == null) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                          content: Text('Please login first')),
                                    );
                                    return;
                                  }

                                  await FirebaseFirestore.instance
                                      .collection('users')
                                      .doc(uid)
                                      .collection('saved')
                                      .doc(recipeId)
                                      .set({
                                    'recipeId': recipeId,
                                    'savedAt': FieldValue.serverTimestamp(),
                                  });

                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Recipe saved')),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),

                        Positioned(
                          left: 14,
                          bottom: 14,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(999),
                              boxShadow: [
                                BoxShadow(
                                  blurRadius: 18,
                                  offset: const Offset(0, 8),
                                  color: Colors.black.withOpacity(0.12),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.access_time,
                                    size: 16,
                                    color: Colors.black.withOpacity(0.65)),
                                const SizedBox(width: 6),
                                Text(
                                  '$mins min',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w900),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                              fontSize: 22, fontWeight: FontWeight.w900),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Recipe details and ingredients',
                          style: TextStyle(
                            color: Colors.black.withOpacity(0.50),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 18),

                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF7F7F7),
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(color: const Color(0xFFEFEFEF)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Text(
                                    'Ingredients',
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w900),
                                  ),
                                  const Spacer(),
                                  Icon(Icons.list_alt_rounded,
                                      color: Colors.black.withOpacity(0.45)),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Text(
                                ingredients.isEmpty
                                    ? 'No ingredients added.'
                                    : ingredients,
                                style: const TextStyle(
                                    height: 1.5, fontWeight: FontWeight.w500),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 16),

                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      ReviewsScreen(recipeId: recipeId),
                                ),
                              );
                            },
                            icon: const Icon(Icons.rate_review_outlined),
                            label: const Text(
                              'View / Add Reviews',
                              style: TextStyle(fontWeight: FontWeight.w900),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _RoundIconBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _RoundIconBtn({
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        borderRadius: BorderRadius.circular(999),
        onTap: onTap,
        child: SizedBox(
          width: 42,
          height: 42,
          child: Icon(icon, size: 20, color: Colors.black.withOpacity(0.80)),
        ),
      ),
    );
  }
}
