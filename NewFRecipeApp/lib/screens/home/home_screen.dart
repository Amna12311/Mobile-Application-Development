import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../core/app_colors.dart';
import '../../app_routes.dart';
import '../../services/auth_service.dart';
import '../auth/auth_gate.dart';
import '../recipe/recipe_detail_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  Future<void> _handleLogout(BuildContext context) async {
    await AuthService.instance.signOut();
    if (!context.mounted) return;

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const AuthGate()),
          (route) => false,
    );
  }

  // ✅ fetch author name from users collection
  Future<String> _getAuthorName(String uid) async {
    try {
      final doc =
      await FirebaseFirestore.instance.collection('users').doc(uid).get();
      final data = doc.data() as Map<String, dynamic>?;
      final name = (data?['name'] ?? '').toString().trim();
      return name.isEmpty ? 'Unknown' : name;
    } catch (_) {
      return 'Unknown';
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUid = FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
      backgroundColor: Colors.white,

      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        onPressed: () => Navigator.pushNamed(context, AppRoutes.addRecipe),
        child: const Icon(Icons.add, color: Colors.white),
      ),

      bottomNavigationBar: _BottomNav(
        onTapHome: () {},
        onTapSaved: () => Navigator.pushNamed(context, AppRoutes.saved),
        onTapBell: () => Navigator.pushNamed(context, AppRoutes.notifications),
        onTapProfile: () => Navigator.pushNamed(context, AppRoutes.profile),
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // =========================
              // Top row: Logout + Avatar (clickable)
              // =========================
              Row(
                children: [
                  InkWell(
                    onTap: () => _handleLogout(context),
                    child: const Row(
                      children: [
                        Icon(Icons.arrow_back, size: 18),
                        SizedBox(width: 6),
                        Text('Logout',
                            style: TextStyle(fontWeight: FontWeight.w700)),
                      ],
                    ),
                  ),
                  const Spacer(),

                  // ✅ avatar opens profile
                  InkWell(
                    borderRadius: BorderRadius.circular(10),
                    onTap: () => Navigator.pushNamed(context, AppRoutes.profile),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.network(
                        'https://images.unsplash.com/photo-1500530855697-b586d89ba3ee?w=200',
                        width: 36,
                        height: 36,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 14),

              // =========================
              // Hello username (dynamic)
              // =========================
              if (currentUid != null)
                StreamBuilder<DocumentSnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('users')
                      .doc(currentUid)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const Text(
                        'Hello',
                        style: TextStyle(
                            fontSize: 22, fontWeight: FontWeight.w800),
                      );
                    }
                    final data =
                    snapshot.data!.data() as Map<String, dynamic>?;
                    final name = (data?['name'] ?? '').toString();

                    return Text(
                      name.isEmpty ? 'Hello' : 'Hello $name',
                      style: const TextStyle(
                          fontSize: 22, fontWeight: FontWeight.w800),
                    );
                  },
                )
              else
                const Text(
                  'Hello',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
                ),

              const SizedBox(height: 4),
              Text(
                'What are you cooking today?',
                style: TextStyle(
                  color: Colors.black.withValues(alpha: 0.45),
                  fontWeight: FontWeight.w600,
                ),
              ),

              const SizedBox(height: 16),

              // =========================
              // ✅ SEARCH (FIXED)
              // Tap search bar -> open SearchScreen
              // =========================
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      borderRadius: BorderRadius.circular(14),
                      onTap: () => Navigator.pushNamed(context, AppRoutes.search),
                      child: Container(
                        height: 46,
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: const Color(0xFFE8E8E8)),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.search,
                                color: Colors.black.withValues(alpha: 0.35)),
                            const SizedBox(width: 8),
                            Expanded(
                              // readOnly so keyboard won’t pop here
                              child: IgnorePointer(
                                ignoring: true,
                                child: TextField(
                                  readOnly: true,
                                  decoration: InputDecoration(
                                    hintText: 'Search recipe',
                                    hintStyle: TextStyle(
                                      color:
                                      Colors.black.withValues(alpha: 0.30),
                                    ),
                                    border: InputBorder.none,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  InkWell(
                    borderRadius: BorderRadius.circular(14),
                    onTap: () => Navigator.pushNamed(context, AppRoutes.filter),
                    child: Container(
                      width: 46,
                      height: 46,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(Icons.tune, color: Colors.white),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 18),

              // =========================
              // FEATURED CARDS (static UI)
              // =========================
              SizedBox(
                height: 250,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: const [
                    SizedBox(width: 2),
                    _FeaturedCard(
                      title: 'Classic Greek\nSalad',
                      timeText: '15 Mins',
                      rating: 4.5,
                      imageUrl:
                      'https://images.unsplash.com/photo-1540189549336-e6e99c3679fe?w=1200',
                    ),
                    SizedBox(width: 14),
                    _FeaturedCard(
                      title: 'Crunchy Nut\nColeslaw',
                      timeText: '10 Mins',
                      rating: 3.5,
                      imageUrl:
                      'https://images.unsplash.com/photo-1512621776951-a57141f2eefd?w=1200',
                    ),
                    SizedBox(width: 14),
                  ],
                ),
              ),

              const SizedBox(height: 18),

              const Text(
                'New Recipes',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
              ),

              const SizedBox(height: 12),

              // =========================
              // New recipes from Firestore
              // =========================
              SizedBox(
                height: 96,
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('recipes')
                      .orderBy('createdAt', descending: true)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      );
                    }

                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return Center(
                        child: Text(
                          'No recipes yet',
                          style: TextStyle(
                            color: Colors.black.withValues(alpha: 0.45),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      );
                    }

                    final docs = snapshot.data!.docs;

                    return ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: docs.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 12),
                      itemBuilder: (context, i) {
                        final data = docs[i].data() as Map<String, dynamic>;
                        final title = (data['title'] ?? '').toString();
                        final mins = (data['timeMinutes'] ?? 0).toString();
                        final authorId = (data['authorId'] ?? '').toString();

                        return FutureBuilder<String>(
                          future: authorId.isEmpty
                              ? Future.value('Unknown')
                              : _getAuthorName(authorId),
                          builder: (context, nameSnap) {
                            final authorName = nameSnap.data ?? 'Unknown';

                            return _NewRecipeCard(
                              title:
                              title.isEmpty ? 'Untitled recipe' : title,
                              mins: mins,
                              author: 'By $authorName',
                              stars: 4.0,
                              imageUrl:
                              'https://images.unsplash.com/photo-1550547660-d9450f859349?w=1200',
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        RecipeDetailScreen(recipeId: docs[i].id),
                                  ),
                                );
                              },
                            );
                          },
                        );
                      },
                    );
                  },
                ),
              ),

              const SizedBox(height: 90),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------- Widgets ----------

class _FeaturedCard extends StatelessWidget {
  final String title;
  final String timeText;
  final double rating;
  final String imageUrl;

  const _FeaturedCard({
    required this.title,
    required this.timeText,
    required this.rating,
    required this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 165,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        children: [
          Stack(
            children: [
              Center(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: Image.network(
                    imageUrl,
                    width: 120,
                    height: 120,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Positioned(
                right: 0,
                top: 6,
                child: Container(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFE8C7),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.star, size: 14, color: Colors.orange),
                      const SizedBox(width: 4),
                      Text(
                        rating.toStringAsFixed(1),
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
          ),
          const SizedBox(height: 10),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Time',
              style: TextStyle(
                color: Colors.black.withValues(alpha: 0.35),
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ),
          const SizedBox(height: 2),
          Row(
            children: [
              Text(
                timeText,
                style:
                const TextStyle(fontWeight: FontWeight.w800, fontSize: 12),
              ),
              const Spacer(),
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.bookmark_border,
                  color: AppColors.primary.withValues(alpha: 0.9),
                  size: 18,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _NewRecipeCard extends StatelessWidget {
  final String title;
  final String mins;
  final String author;
  final double stars;
  final String imageUrl;
  final VoidCallback onTap;

  const _NewRecipeCard({
    required this.title,
    required this.mins,
    required this.author,
    required this.stars,
    required this.imageUrl,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Container(
        width: 260,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              blurRadius: 18,
              offset: const Offset(0, 8),
              color: Colors.black.withValues(alpha: 0.06),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: List.generate(
                      5,
                          (i) => Icon(
                        i < stars.round() ? Icons.star : Icons.star_border,
                        size: 14,
                        color: Colors.orange,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Container(
                        width: 22,
                        height: 22,
                        decoration: BoxDecoration(
                          color: Colors.green.withValues(alpha: 0.25),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          author,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colors.black.withValues(alpha: 0.45),
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      const Spacer(),
                      Icon(Icons.access_time,
                          size: 16, color: Colors.black.withValues(alpha: 0.35)),
                      const SizedBox(width: 4),
                      Text(
                        '$mins mins',
                        style: TextStyle(
                          color: Colors.black.withValues(alpha: 0.45),
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: Image.network(
                imageUrl,
                width: 56,
                height: 56,
                fit: BoxFit.cover,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BottomNav extends StatelessWidget {
  final VoidCallback onTapHome;
  final VoidCallback onTapSaved;
  final VoidCallback onTapBell;
  final VoidCallback onTapProfile;

  const _BottomNav({
    required this.onTapHome,
    required this.onTapSaved,
    required this.onTapBell,
    required this.onTapProfile,
  });

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      height: 70,
      color: Colors.white,
      surfaceTintColor: Colors.white,
      elevation: 10,
      shape: const CircularNotchedRectangle(),
      notchMargin: 10,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _navIcon(Icons.home_outlined, true, onTapHome),
            _navIcon(Icons.bookmark_border, false, onTapSaved),
            const SizedBox(width: 40),
            _navIcon(Icons.notifications_none, false, onTapBell),
            _navIcon(Icons.person_outline, false, onTapProfile),
          ],
        ),
      ),
    );
  }

  Widget _navIcon(IconData icon, bool active, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: SizedBox(
        width: 44,
        height: 44,
        child: Icon(
          icon,
          color: active ? AppColors.primary : Colors.black.withValues(alpha: 0.35),
        ),
      ),
    );
  }
}
