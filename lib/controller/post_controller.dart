import 'package:dio/dio.dart';
import 'package:everest_task/model/post_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final dio = Dio();

// Define a provider that calls the `fetchPosts` method
final postProvider = FutureProvider<List<PostModel>>((ref) async {
  return fetchPosts();
});

Future<List<PostModel>> fetchPosts() async {
  try {
    final response = await dio.get('https://jsonplaceholder.typicode.com/posts');
    
    // Check if response is successful
    if (response.statusCode == 200) {
      return (response.data as List)
          .map((json) => PostModel.fromJson(json))
          .toList();
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
        throw Exception('Failed to load posts: ${e.response?.statusMessage ?? 'Unknown error'}');
      default:
        throw Exception('An unexpected error occurred: ${e.message}');
    }
  } catch (e) {
    // Handle any other exceptions
    throw Exception('Failed to load posts: $e');
  }
}