import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../core/app_colors.dart';

class ReviewsScreen extends StatefulWidget {
  final String recipeId;

  const ReviewsScreen({super.key, required this.recipeId});

  @override
  State<ReviewsScreen> createState() => _ReviewsScreenState();
}

class _ReviewsScreenState extends State<ReviewsScreen> {
  final _commentCtrl = TextEditingController();
  double _rating = 5;
  bool _sending = false;

  @override
  void dispose() {
    _commentCtrl.dispose();
    super.dispose();
  }

  Future<void> _sendReview() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please login first')),
      );
      return;
    }

    final comment = _commentCtrl.text.trim();
    if (comment.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Write a comment')),
      );
      return;
    }

    setState(() => _sending = true);

    try {
      await FirebaseFirestore.instance
          .collection('recipes')
          .doc(widget.recipeId)
          .collection('reviews')
          .add({
        'userId': uid,
        'rating': _rating,
        'comment': comment,
        'createdAt': FieldValue.serverTimestamp(),
      });

      // 🔔 Create notification for recipe owner
      final recipeDoc = await FirebaseFirestore.instance
          .collection('recipes')
          .doc(widget.recipeId)
          .get();

      final recipeData = recipeDoc.data() as Map<String, dynamic>?;
      final ownerUid = recipeData?['authorId']?.toString();

      if (ownerUid != null && ownerUid.isNotEmpty && ownerUid != uid) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(ownerUid)
            .collection('notifications')
            .add({
          'title': 'New Review',
          'body': '⭐ ${_rating.toStringAsFixed(0)}/5 — $comment',
          'recipeId': widget.recipeId,
          'fromUserId': uid,
          'toUserId': ownerUid,
          'createdAt': FieldValue.serverTimestamp(),
          'read': false,
          'type': 'review',
        });
      }

      _commentCtrl.clear();
      setState(() => _rating = 5);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Review added')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    const headerImage =
        'https://images.unsplash.com/photo-1512621776951-a57141f2eefd?w=1200';

    final reviewsQuery = FirebaseFirestore.instance
        .collection('recipes')
        .doc(widget.recipeId)
        .collection('reviews')
        .orderBy('createdAt', descending: true);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        title:
        const Text('Reviews', style: TextStyle(fontWeight: FontWeight.w800)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ✅ Static image header (UI only)
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: SizedBox(
                width: double.infinity,
                height: 140,
                child: Image.network(
                  headerImage,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    color: Colors.black.withValues(alpha: 0.06),
                    alignment: Alignment.center,
                    child: const Icon(Icons.fastfood, size: 52),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Rating selector
            const Text('Your rating',
                style: TextStyle(fontWeight: FontWeight.w700)),
            const SizedBox(height: 6),
            Row(
              children: [
                Expanded(
                  child: Slider(
                    value: _rating,
                    min: 1,
                    max: 5,
                    divisions: 4,
                    label: _rating.toStringAsFixed(0),
                    onChanged: (v) => setState(() => _rating = v),
                  ),
                ),
                Text(_rating.toStringAsFixed(0),
                    style: const TextStyle(fontWeight: FontWeight.w800)),
              ],
            ),

            const SizedBox(height: 10),

            // Comment input + send
            const Text('Leave a comment',
                style: TextStyle(fontWeight: FontWeight.w700)),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFFE6E6E6)),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _commentCtrl,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: 'Say something...',
                        hintStyle: TextStyle(
                          color: Colors.black.withValues(alpha: 0.25),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 38,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: _sending ? null : _sendReview,
                      child: _sending
                          ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white),
                      )
                          : const Text('Send',
                          style: TextStyle(fontWeight: FontWeight.w800)),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            const Text('All reviews',
                style: TextStyle(fontWeight: FontWeight.w800)),
            const SizedBox(height: 10),

            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: reviewsQuery.snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return Center(
                      child: Text(
                        'No reviews yet',
                        style: TextStyle(color: Colors.black.withValues(alpha: 0.45)),
                      ),
                    );
                  }

                  final docs = snapshot.data!.docs;

                  return ListView.separated(
                    itemCount: docs.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, i) {
                      final d = docs[i].data() as Map<String, dynamic>;
                      final rating = (d['rating'] ?? 0).toString();
                      final comment = (d['comment'] ?? '').toString();

                      final reviewUserId = (d['userId'] ?? '').toString();
                      final canDelete =
                          FirebaseAuth.instance.currentUser?.uid == reviewUserId;

                      return Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF6F6F6),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Rating: $rating/5',
                                      style: const TextStyle(
                                          fontWeight: FontWeight.w800)),
                                  const SizedBox(height: 6),
                                  Text(comment),
                                ],
                              ),
                            ),
                            if (canDelete)
                              IconButton(
                                icon: const Icon(Icons.delete_outline),
                                onPressed: () async {
                                  await docs[i].reference.delete();
                                },
                              ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
