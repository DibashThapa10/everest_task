import 'package:everest_task/controller/post_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PostView extends ConsumerWidget {
  const PostView({super.key});

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
      body: 
      
      postAsyncValue.when(
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
                    title: Text(
                      post.title,
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: s * 0.9, color: Colors.blue),
                    ),
                    contentPadding: EdgeInsets.symmetric(horizontal: w * 0.02),
                    subtitle: Text(
                      post.body,
                      style: TextStyle(fontSize: s * 0.7),
                    ),
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
                    // Retry button re-fetches posts
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
