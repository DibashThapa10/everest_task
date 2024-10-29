import 'dart:convert';
import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:everest_task/model/post_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final postControllerProvider = Provider((ref) => PostController());

class PostController extends StateNotifier<List<PostModel>> {
  final dio = Dio();
  PostController() : super([]);



 
  Future<void> fetchPosts() async {
    final prefs = await SharedPreferences.getInstance();
    final String storedPosts = prefs.getString('stored_posts') ?? '[]';
    final List<dynamic> storedList = json.decode(storedPosts);

    log('stored posts $storedList');
    if (storedList.isNotEmpty) {
      // Return cached posts if available
      state = storedList.map((post) => PostModel.fromJson(post)).toList();
    } else {
      try {
        final response =
            await dio.get('https://jsonplaceholder.typicode.com/posts');

        // Check if response is successful
        if (response.statusCode == 200) {
          log('enter');
          final List<PostModel> posts = (response.data as List)
              .map((post) => PostModel.fromJson(post))
              .toList();

          // Cache the posts
          await prefs.setString('stored_posts',
              json.encode(posts.map((post) => post.toJson()).toList()));
          state = posts;
         
         
          
        } else {
          throw Exception('Failed to load posts: ${response.statusMessage}');
        }
      } on DioException catch (e) {
        // Handle Dio-specific errors
        switch (e.type) {
          case DioExceptionType.connectionTimeout:
            throw Exception('Connection timed out. Please try again later.');
          case DioExceptionType.receiveTimeout:
            throw Exception('Receive timeout. Please try again later.');
          case DioExceptionType.badResponse:
            throw Exception(
                'Failed to load posts: ${e.response?.statusMessage ?? 'Unknown error'}');
          default:
            throw Exception('An unexpected error occurred: ${e.message}');
        }
      } catch (e) {
        // Handle any other exceptions
        throw Exception('Failed to load posts: $e');
      }
    }
  }

  // Show Add Post Dialog
  Future<void> showAddPostDialog(BuildContext context, WidgetRef ref) async {
    final titleController = TextEditingController();
    final bodyController = TextEditingController();

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Add New Post"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(labelText: "Title"),
              ),
              TextField(
                controller: bodyController,
                decoration: const InputDecoration(labelText: "Body"),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () async {
                final title = titleController.text;
                final body = bodyController.text;

                if (title.isNotEmpty && body.isNotEmpty) {
                  await ref
                      .read(postProvider.notifier)
                      .createPost(context, title, body);
                  Navigator.pop(context); // Close dialog after submission
                }
              },
              child: const Text("Submit"),
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
        // postsList.insert(0, newPost.toJson());
        postsList.add(newPost.toJson()); // Add the new post to the list

        await prefs.setString('stored_posts', json.encode(postsList));
        state = [newPost, ...state];

       
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
    StateNotifierProvider<PostController, List<PostModel>>((ref) {
  return PostController()..fetchPosts(); // Fetch initial posts
});

