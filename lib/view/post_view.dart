import 'package:everest_task/controller/post_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PostView extends ConsumerWidget {
  const PostView({super.key});

  Future<void> _showDeleteConfirmationDialog(
      BuildContext context, WidgetRef ref, int postId) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Center(child: Text("Delete Post")),
          content: const Text("Are you sure you want to delete this post?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text(
                "Yes",
              ),
            ),
          ],
        );
      },
    );

    if (shouldDelete == true) {
      await ref.read(postProvider.notifier).deletePost(context, postId);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final postAsyncValue = ref.watch(postProvider);
    final postController = ref.read(postControllerProvider);
    final h = MediaQuery.sizeOf(context).height;
    final w = MediaQuery.sizeOf(context).width;
    final s = w * 0.05;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Posts',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: Colors.blue,
      ),
      body: postAsyncValue.when(
        data: (posts) {
          return ListView.builder(
            itemCount: posts.length,
            itemBuilder: (context, index) {
              final post = posts[index];
              return Padding(
                padding: EdgeInsets.symmetric(
                    horizontal: w * 0.04, vertical: h * 0.01),
                child: Card(
                  elevation: 2,
                  child: ListTile(
                    title: Row(
                      children: [
                        Expanded(
                          child: Text(
                            post.title,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontSize: s * 0.9, color: Colors.blue),
                          ),
                        ),
                        PopupMenuButton(itemBuilder: (context) {
                          return [
                            PopupMenuItem(
                                onTap: () async {
                                  // await ref
                                  //     .read(postProvider.notifier)
                                  //     .deletePost(context, post.id);
                                  await _showDeleteConfirmationDialog(
                                      context, ref, post.id);
                                },
                                child: const Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    Icon(
                                      Icons.delete_forever,
                                      color: Colors.red,
                                      size: 18,
                                    ),
                                    Text(
                                      'Delete',
                                      style: TextStyle(
                                        color: Colors.red,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ))
                          ];
                        })
                      ],
                    ),
                    contentPadding: EdgeInsets.symmetric(horizontal: w * 0.02),
                    subtitle: Text(
                      post.body,
                      style: TextStyle(fontSize: s * 0.7),
                    ),

                    // IconButton(
                    //   icon: const Icon(Icons.delete, color: Colors.red),
                    //   onPressed: () async {

                    //     await ref
                    //         .read(postProvider.notifier)
                    //         .deletePost(context, post.id);
                    //   },
                    // ),
                  ),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) {
          final errorMessage = error.toString();
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error, color: Colors.red, size: 60),
                const SizedBox(height: 10),
                const Text(
                  'Failed to load posts',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    errorMessage,
                    style: const TextStyle(color: Colors.grey),
                    textAlign: TextAlign.center,
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    ref.refresh(postProvider);
                  },
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.green,
        onPressed: () => postController.showAddPostDialog(context, ref),
        child: const Icon(Icons.add),
      ),
    );
  }
}
