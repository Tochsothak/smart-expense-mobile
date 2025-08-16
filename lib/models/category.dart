import 'package:hive/hive.dart';

part 'category.g.dart';

@HiveType(typeId: 5)
class CategoryModel {
  @HiveField(0)
  late String id;

  @HiveField(1)
  late String name;

  @HiveField(2)
  late String code;

  @HiveField(3)
  late String colourCode;

  @HiveField(4)
  late String description;

  @HiveField(5)
  late String icon;

  @HiveField(6)
  int? active;

  static String categoryBox = "categories";

  static fromMap(Map<String, dynamic> category) {
    var categoryModel = CategoryModel();
    categoryModel.id = category['id'];
    categoryModel.name = category['name'];
    categoryModel.code = category['code'];
    categoryModel.description = category['description'];
    categoryModel.colourCode = category['colour_code'];
    categoryModel.icon = category['icon'];
    categoryModel.active = int.parse(category['active'].toString());
    return categoryModel;
  }

  bool isEqual(CategoryModel model) {
    return id == model.id;
  }

  @override
  String toString() => name;
}
