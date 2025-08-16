import 'package:hive_flutter/hive_flutter.dart';
import 'package:smart_expense/models/category.dart';

class CategoryService {
  static Future<CategoryModel> create(Map<String, dynamic> category) async {
    final categoryBox = await Hive.openBox(CategoryModel.categoryBox);

    var categoryModel = CategoryModel.fromMap(category);
    await categoryBox.put(categoryModel.id, categoryModel);
    return categoryModel;
  }

  static Future<List<CategoryModel>?> getAll() async {
    final categoryBoxList = await Hive.openBox(CategoryModel.categoryBox);
    if (categoryBoxList.isEmpty) return null;
    List<CategoryModel> categoryList =
        categoryBoxList.values.cast<CategoryModel>().toList();
    return categoryList;
  }

  static Future<List<CategoryModel>> createCategories(List categories) async {
    final categoryBox = await Hive.openBox(CategoryModel.categoryBox);
    await categoryBox.clear();

    List<CategoryModel> categoryModels = [];

    for (var category in categories) {
      var categoryModel = CategoryModel.fromMap(category);

      await categoryBox.put(categoryModel.id, categoryModel);
      categoryModels.add(categoryModel);
    }
    return categoryModels;
  }
}
