import 'package:dio/dio.dart';
import '../models/product_model.dart';

class ApiService {
  static const String _baseUrl = 'https://fakestoreapi.com';
  
  final Dio _dio;

  ApiService()
      : _dio = Dio(
          BaseOptions(
            baseUrl: _baseUrl,
            connectTimeout: const Duration(seconds: 10),
            receiveTimeout: const Duration(seconds: 10),
          ),
        );

  /// Fetch all products
  Future<List<Product>> fetchProducts() async {
    try {
      final response = await _dio.get('/products');
      if (response.statusCode == 200) {
        final List data = response.data;
        return data.map((json) => Product.fromJson(json)).toList();
      }
      throw Exception('Failed to fetch products: ${response.statusCode}');
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// Fetch products by category
  Future<List<Product>> fetchProductsByCategory(String category) async {
    try {
      final response = await _dio.get('/products/category/$category');
      if (response.statusCode == 200) {
        final List data = response.data;
        return data.map((json) => Product.fromJson(json)).toList();
      }
      throw Exception('Failed to fetch products by category');
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// Fetch all categories
  Future<List<String>> fetchCategories() async {
    try {
      final response = await _dio.get('/products/categories');
      if (response.statusCode == 200) {
        return List<String>.from(response.data);
      }
      throw Exception('Failed to fetch categories');
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// Fetch single product by ID
  Future<Product> fetchProductById(int id) async {
    try {
      final response = await _dio.get('/products/$id');
      if (response.statusCode == 200) {
        return Product.fromJson(response.data);
      }
      throw Exception('Product not found');
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Exception _handleDioError(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.receiveTimeout:
        return Exception('Connection timed out. Please check your internet.');
      case DioExceptionType.connectionError:
        return Exception('No internet connection.');
      default:
        return Exception(e.message ?? 'Something went wrong.');
    }
  }
}