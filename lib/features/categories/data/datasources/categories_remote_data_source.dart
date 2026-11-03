import 'package:tstore/core/constants/app_constants.dart';
import 'package:tstore/core/network/api_client.dart';
import 'package:tstore/features/categories/data/models/category_model.dart';

abstract class CategoriesRemoteDataSource {
  Future<List<CategoryModel>> getCategoriesTree();
}

class CategoriesRemoteDataSourceImpl implements CategoriesRemoteDataSource {
  final ApiClient _apiClient;

  CategoriesRemoteDataSourceImpl(this._apiClient);

  @override
  Future<List<CategoryModel>> getCategoriesTree() async {
    final response = await _apiClient.get('${AppConstants.categoriesEndpoint}/tree');
    final List data = response.data['categories'] as List;
    return data.map((json) => CategoryModel.fromJson(json as Map<String, dynamic>)).toList();
  }
}
