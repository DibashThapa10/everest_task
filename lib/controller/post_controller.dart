import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:everest_task/model/post_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final postControllerProvider = Provider((ref) => PostController());

class PostController extends StateNotifier<AsyncValue<List<PostModel>>> {
  final dio = Dio();
  PostController() : super(const AsyncValue.loading());

  Future<void> fetchPosts() async {
    final prefs = await SharedPreferences.getInstance();
    final String storedPosts = prefs.getString('stored_posts') ?? '[]';
    final List<dynamic> storedList = json.decode(storedPosts);

    if (storedList.isNotEmpty) {
      // state = storedList.map((post) => PostModel.fromJson(post)).toList();
      state = AsyncValue.data(
          storedList.map((post) => PostModel.fromJson(post)).toList());
    } else {
      try {
        final response =
            await dio.get('https://jsonplaceholder.typicode.com/posts');

        if (response.statusCode == 200) {
          final List<PostModel> posts = (response.data as List)
              .map((post) => PostModel.fromJson(post))
              .toList();

          await prefs.setString('stored_posts',
              json.encode(posts.map((post) => post.toJson()).toList()));

          state = AsyncValue.data(posts);
        } else {
          throw Exception('Failed to load posts: ${response.statusMessage}');
        }
      } on DioException catch (e) {
        // Handle Dio-specific errors
        switch (e.type) {
          case DioExceptionType.connectionTimeout:
            state = AsyncValue.error(
                'Connection timed out. Please try again later.',
                StackTrace.current);

          case DioExceptionType.receiveTimeout:
            state = AsyncValue.error(
                'Receive timeout. Please try again later.', StackTrace.current);
          case DioExceptionType.badResponse:
            state = AsyncValue.error(
                'Failed to load posts: ${e.response?.statusMessage ?? 'Unknown error'}',
                StackTrace.current);
          default:
            state = AsyncValue.error(
                'An unexpected error occurred: ${e.message}',
                StackTrace.current);
        }
      } catch (e) {
        state = AsyncValue.error(e, StackTrace.current);
      }
    }
  }

  // Show Add Post Dialog
  Future<void> showAddPostDialog(BuildContext context, WidgetRef ref) async {
    final GlobalKey<FormState> formKey = GlobalKey<FormState>();
    final titleController = TextEditingController();
    final bodyController = TextEditingController();

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Center(child: Text("Add New Post")),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: titleController,
                  decoration: InputDecoration(
                      labelText: "Title",
                      hintText: 'Enter title',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8)),
                      floatingLabelBehavior: FloatingLabelBehavior.always),
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Title cannot be empty';
                    }

                    return null;
                  },
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: bodyController,
                  decoration: InputDecoration(
                      labelText: "Description",
                      hintText: 'Enter description',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8)),
                      floatingLabelBehavior: FloatingLabelBehavior.always),
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Description cannot be empty';
                    }

                    return null;
                  },
                  maxLines: 3,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                "Cancel",
                style: TextStyle(color: Colors.red),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
              onPressed: () async {
                if (formKey.currentState!.validate()) {
                  final title = titleController.text;
                  final body = bodyController.text;

                  await ref
                      .read(postProvider.notifier)
                      .createPost(context, title, body);
                  Navigator.pop(context);
                }
              },
              child: const Text(
                "Submit",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  // Create Post API call
  Future<void> createPost(
      BuildContext context, String title, String body) async {
    try {
      final response = await dio.post(
        'https://jsonplaceholder.typicode.com/posts',
        data: {
          "title": title,
          "body": body,
          "userId": 1,
        },
      );

      if (response.statusCode == 201) {
        final newPost = PostModel.fromJson(response.data);
        final SharedPreferences prefs = await SharedPreferences.getInstance();
        final String storedPosts = prefs.getString('stored_posts') ?? '[]';
        final List<dynamic> postsList = json.decode(storedPosts);
        postsList.insert(0, newPost.toJson()); // Add new post at first

        await prefs.setString('stored_posts', json.encode(postsList));
        // state = [newPost, ...state];
        state = AsyncValue.data([newPost, ...state.value ?? []]);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Post created successfully.'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } on DioException catch (e) {
      // Show error message in UI
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error creating post: ${e.message}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}

final postProvider =
    StateNotifierProvider<PostController, AsyncValue<List<PostModel>>>((ref) {
  final controller = PostController();
  controller.fetchPosts();
  return controller;
});
