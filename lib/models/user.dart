import 'package:hive/hive.dart';

part 'user.g.dart';

@HiveType(typeId: 1)
class UserModel {
  @HiveField(0)
  late String id;

  @HiveField(1)
  late String name;

  @HiveField(2)
  late String email;

  @HiveField(3)
  DateTime? emailVerifiedAt;

  @HiveField(4)
  late DateTime createdAt;

  @HiveField(5)
  late DateTime updatedAt;

  @HiveField(6)
  late String token;

  @HiveField(7)
  String? pin;

  @HiveField(8)
  String? profileImage;

  @HiveField(9)
  String? profileImageUrl;

  bool get hasProfileImage =>
      profileImageUrl != null && profileImageUrl!.isNotEmpty;

  static UserModel fromMap(Map<String, dynamic> user) {
    try {
      var userModel = UserModel();

      userModel.id = user['id']?.toString() ?? '';
      userModel.name = user['name']?.toString() ?? '';
      userModel.email = user['email']?.toString() ?? '';
      // Handle email_verified_at safely
      userModel.emailVerifiedAt =
          user['email_verified_at'] != null
              ? DateTime.tryParse(user['email_verified_at'].toString())
              : null;
      // Handle profile image fields (might not exist in auth responses)
      userModel.profileImage = user['profile_image']?.toString();
      userModel.profileImageUrl = user['profile_image_url']?.toString();
      // Handle created_at safely
      if (user['created_at'] != null) {
        if (user['created_at'] is String) {
          userModel.createdAt =
              DateTime.tryParse(user['created_at']) ?? DateTime.now();
        } else if (user['created_at'] is DateTime) {
          userModel.createdAt = user['created_at'];
        } else {
          userModel.createdAt = DateTime.now();
        }
      } else {
        userModel.createdAt = DateTime.now();
      }
      // Handle updated_at safely
      if (user['updated_at'] != null) {
        if (user['updated_at'] is String) {
          userModel.updatedAt =
              DateTime.tryParse(user['updated_at']) ?? DateTime.now();
        } else if (user['updated_at'] is DateTime) {
          userModel.updatedAt = user['updated_at'];
        } else {
          userModel.updatedAt = DateTime.now();
        }
      } else {
        userModel.updatedAt = DateTime.now();
      }
      // FIXED: Handle token properly - it should be required for auth responses
      userModel.token = user['token']?.toString() ?? '';
      // If token is empty and this is supposed to be an auth response, that's an error
      if (userModel.token.isEmpty &&
          (user.containsKey('token') || user.containsKey('access_token'))) {
        userModel.token = user['access_token']?.toString() ?? '';
      }
      // Handle pin
      userModel.pin = user['pin']?.toString();
      return userModel;
    } catch (e) {
      rethrow;
    }
  }

  // Create a separate method for profile updates that doesn't require token
  static UserModel fromProfileMap(
    Map<String, dynamic> user, {
    String? existingToken,
  }) {
    try {
      var userModel = UserModel();

      userModel.id = user['id']?.toString() ?? '';
      userModel.name = user['name']?.toString() ?? '';
      userModel.email = user['email']?.toString() ?? '';

      // Handle email_verified_at safely
      userModel.emailVerifiedAt =
          user['email_verified_at'] != null
              ? DateTime.tryParse(user['email_verified_at'].toString())
              : null;

      // Handle profile image fields
      userModel.profileImage = user['profile_image']?.toString();
      userModel.profileImageUrl = user['profile_image_url']?.toString();

      // Handle dates
      userModel.createdAt =
          user['created_at'] != null
              ? DateTime.tryParse(user['created_at'].toString()) ??
                  DateTime.now()
              : DateTime.now();

      userModel.updatedAt =
          user['updated_at'] != null
              ? DateTime.tryParse(user['updated_at'].toString()) ??
                  DateTime.now()
              : DateTime.now();

      // Use existing token for profile updates
      userModel.token = existingToken ?? '';

      // Handle pin
      userModel.pin = user['pin']?.toString();
      return userModel;
    } catch (e) {
      rethrow;
    }
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'email_verified_at': emailVerifiedAt?.toIso8601String(),
      'profile_image': profileImage,
      'profile_image_url': profileImageUrl,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'token': token,
      'pin': pin,
    };
  }

  @override
  String toString() => name;

  static String userBox = 'users';
}
