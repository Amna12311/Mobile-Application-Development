import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../core/app_colors.dart';
import '../recipe/recipe_detail_screen.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  int tab = 0; // 0 = All, 1 = Read, 2 = Unread

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;

    if (uid == null) {
      return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          title: const Text('Notifications', style: TextStyle(fontWeight: FontWeight.w800)),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: const Center(child: Text('Please login first')),
      );
    }

    final notifQuery = FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('notifications')
        .orderBy('createdAt', descending: true);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        title: const Text('Notifications', style: TextStyle(fontWeight: FontWeight.w800)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18),
        child: Column(
          children: [
            const SizedBox(height: 10),

            // Tabs
            Row(
              children: [
                Expanded(child: _tabBtn('All', 0)),
                const SizedBox(width: 10),
                Expanded(child: _tabBtn('Read', 1)),
                const SizedBox(width: 10),
                Expanded(child: _tabBtn('Unread', 2)),
              ],
            ),

            const SizedBox(height: 18),

            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: notifQuery.snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return Center(child: Text(snapshot.error.toString()));
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return Center(
                      child: Text(
                        'No notifications yet',
                        style: TextStyle(color: Colors.black.withValues(alpha: 0.45)),
                      ),
                    );
                  }

                  final docs = snapshot.data!.docs;

                  // Filter by tab
                  final filtered = docs.where((doc) {
                    final d = doc.data() as Map<String, dynamic>;
                    final read = (d['read'] ?? false) == true;
                    if (tab == 0) return true;
                    if (tab == 1) return read;
                    return !read;
                  }).toList();

                  if (filtered.isEmpty) {
                    return Center(
                      child: Text(
                        tab == 1 ? 'No read notifications' : 'No unread notifications',
                        style: TextStyle(color: Colors.black.withValues(alpha: 0.45)),
                      ),
                    );
                  }

                  return ListView.separated(
                    itemCount: filtered.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, i) {
                      final doc = filtered[i];
                      final data = doc.data() as Map<String, dynamic>;

                      final title = (data['title'] ?? '').toString();
                      final body = (data['body'] ?? '').toString();
                      final recipeId = (data['recipeId'] ?? '').toString();
                      final isRead = (data['read'] ?? false) == true;

                      return InkWell(
                        borderRadius: BorderRadius.circular(16),
                        onTap: () async {
                          // mark as read
                          await doc.reference.update({'read': true});

                          // open recipe if exists
                          if (recipeId.isNotEmpty && context.mounted) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => RecipeDetailScreen(recipeId: recipeId),
                              ),
                            );
                          }
                        },
                        child: _notifCard(
                          title: title.isEmpty ? 'Notification' : title,
                          message: body,
                          isRead: isRead,
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

  Widget _tabBtn(String text, int index) {
    final active = tab == index;
    return InkWell(
      onTap: () => setState(() => tab = index),
      borderRadius: BorderRadius.circular(14),
      child: Container(
        height: 42,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: active ? AppColors.primary : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: active ? Colors.transparent : const Color(0xFFE6E6E6),
          ),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: active ? Colors.white : AppColors.primary,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }

  Widget _notifCard({
    required String title,
    required String message,
    required bool isRead,
  }) {
    final bg = isRead ? const Color(0xFFF2F2F2) : const Color(0xFFEAF8F3);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.w800)),
                const SizedBox(height: 6),
                Text(
                  message,
                  style: TextStyle(
                    color: Colors.black.withValues(alpha: 0.45),
                    fontWeight: FontWeight.w600,
                    height: 1.25,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: const Color(0xFFFFE7C6),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.notifications_none,
              color: AppColors.orange,
              size: 18,
            ),
          ),
        ],
      ),
    );
  }
}
