import 'dart:io';

import 'package:dio/dio.dart';
import 'package:smart_expense/models/result.dart';
import 'package:smart_expense/models/transaction.dart';
import 'package:smart_expense/resources/app_strings.dart';
import 'package:smart_expense/services/api.dart';
import 'package:smart_expense/services/api_routes.dart';
import 'package:smart_expense/services/transaction.dart';

class TransactionController {
  // Original create method (backward compatibility)
  static Future<Result<TransactionModel>> create(
    String account,
    double amount,
    String category,
    String description,
    String type,
    String transactionDate,
    String notes,
  ) async {
    // Call createWithFiles with empty file list for backward compatibility
    return createWithFiles(
      account,
      amount,
      category,
      description,
      type,
      transactionDate,
      notes,
      [],
    );
  }

  static Future<Result<TransactionModel>> createWithFiles(
    String account,
    double amount,
    String category,
    String description,
    String type,
    String transactionDate,
    String notes,
    List<File> files,
  ) async {
    try {
      // Check if files are provided
      if (files.isNotEmpty) {
        // Use multipart form data for file upload
        FormData formData = FormData.fromMap({
          'account': account,
          'amount': amount,
          'category': category,
          'description': description,
          'type': type,
          'transaction_date': transactionDate,
          'notes': notes,
        });

        // Add files to form data
        for (int i = 0; i < files.length; i++) {
          String fileName = files[i].path.split('/').last;
          formData.files.add(
            MapEntry(
              'attachments[]', // Use array notation for multiple files
              await MultipartFile.fromFile(files[i].path, filename: fileName),
            ),
          );
        }

        print('FormData prepared with ${formData.files.length} files');

        final response = await ApiService.postMultipart(
          ApiRoutes.transactionUrl,
          formData,
        );

        print('API Response received: ${response.statusCode}');

        // Check if response structure matches your backend
        if (response.data != null) {
          print('Response data: ${response.data}');

          // Adjust this based on your actual backend response structure
          final results = response.data['results'] ?? response.data['data'];
          final transactionData = results['transaction'] ?? results;

          final transaction = await TransactionService.create(transactionData);

          print('Transaction created with ${files.length} files: $transaction');

          return Result(
            isSuccess: true,
            message:
                response.data['message'] ?? 'Transaction created successfully',
            results: transaction,
          );
        } else {
          return Result(
            isSuccess: false,
            message: 'Invalid response from server',
          );
        }
      } else {
        // Use regular POST for transactions without files
        print('Creating transaction without files');

        final response = await ApiService.post(ApiRoutes.transactionUrl, {
          'account': account,
          'amount': amount,
          'category': category,
          'description': description,
          'type': type,
          'transaction_date': transactionDate,
          'notes': notes,
        });

        print('Regular POST response: ${response.statusCode}');

        // Adjust this based on your actual backend response structure
        final results = response.data['results'] ?? response.data['data'];
        final transactionData = results['transaction'] ?? results;

        final transaction = await TransactionService.create(transactionData);

        print('Transaction created: $transaction');

        return Result(
          isSuccess: true,
          message:
              response.data['message'] ?? 'Transaction created successfully',
          results: transaction,
        );
      }
    } on DioException catch (e) {
      print('DioException in createWithFiles: $e');
      final message = ApiService.errorMessage(e);
      final errors = e.response?.data?['errors'];
      return Result(isSuccess: false, message: message, errors: errors);
    } catch (e) {
      print('General error in createWithFiles: $e');
      return Result(isSuccess: false, message: 'An error occurred: $e');
    }
  }

  static Future<Result<List<TransactionModel>>> load() async {
    // Load accounts from hive
    final transactionBox = await TransactionService.getAll();
    // if (transactionBox != null) {
    //   return Result(
    //     isSuccess: true,
    //     results: transactionBox,
    //     message: AppStrings.dataRetrievedSuccess,
    //   );
    // }
    try {
      final response = await ApiService.get(ApiRoutes.transactionUrl, {});
      if (response.statusCode == 200) {
        final results = response.data['results'];

        final transactions = await TransactionService.createTransactions(
          results['transactions'],
        );

        return Result(
          isSuccess: true,
          message: response.data['message'],
          results: transactions,
        );
      } else {
        return Result(
          isSuccess: true,
          results: transactionBox,
          message: AppStrings.dataRetrievedSuccess,
        );
      }
    } on DioException catch (e) {
      final errors = e.response?.data['errors'];
      final message = ApiService.errorMessage(e);
      return Result(isSuccess: false, message: message, errors: errors);
    } catch (e) {
      return Result(
        isSuccess: false,
        message: AppStrings.anErrorOccurredTryAgain,
      );
    }
  }

  static Future<Result<TransactionModel>?> get(Map<String, dynamic> id) async {
    // print("Getting account with ID: ${id['id']} from local storage");
    // Get Transaction by id from local storage
    final transactionBox = await TransactionService.getById(id['id']);
    if (transactionBox != null) {
      // print("AccountB found in local storage: $accountBox");
      return Result(
        isSuccess: true,
        results: transactionBox,
        message: AppStrings.dataRetrievedSuccess,
      );
    }
    try {
      //Get account from server
      final response = await ApiService.get(
        "${ApiRoutes.transactionUrl}/${id['id']}",
        id,
      );
      if (response.statusCode == 200) {
        final result = response.data['results'];
        final transaction = result['transaction'];
        final transactionModel = TransactionModel.fromMap(transaction);
        // print("Account from server : $accountModel");
        return Result(
          isSuccess: true,
          results: transactionModel,
          message: response.data['message'],
        );
      } else {
        return Result(
          isSuccess: true,
          results: transactionBox,
          message: AppStrings.dataRetrievedSuccess,
        );
      }
    } on DioException catch (e) {
      final errors = e.response?.data['errors'];
      final message = ApiService.errorMessage(e);
      return Result(isSuccess: false, message: message, errors: errors);
    } catch (e) {
      return Result(
        isSuccess: false,
        message: AppStrings.anErrorOccurredTryAgain,
      );
    }
  }

  // Original update method (backward compatibility)
  static Future<Result<TransactionModel>> update(
    Map<String, dynamic> id,
    String category,
    String account,
    String type,
    double amount,
    String description,
    String notes,
    String transactionDate,
    int active,
  ) async {
    // Call updateWithFiles with empty file lists for backward compatibility
    return updateWithFiles(
      id,
      category,
      account,
      type,
      amount,
      description,
      notes,
      transactionDate,
      active,
      [], // newFiles
      [], // filesToDelete
    );
  }

  // New update method with file upload support
  static Future<Result<TransactionModel>> updateWithFiles(
    Map<String, dynamic> id,
    String category,
    String account,
    String type,
    double amount,
    String description,
    String notes,
    String transactionDate,
    int active,
    List<File> newFiles,
    List<String> filesToDelete,
  ) async {
    try {
      // Check if files are involved in the update
      if (newFiles.isNotEmpty || filesToDelete.isNotEmpty) {
        // Use multipart form data for file operations
        FormData formData = FormData.fromMap({
          'category': category,
          'account': account,
          'type': type,
          'amount': amount,
          'description': description,
          'notes': notes,
          'transaction_date': transactionDate,
          'active': active,
          '_method': 'PATCH', // Laravel method spoofing
        });

        // Add new files
        if (newFiles.isNotEmpty) {
          for (int i = 0; i < newFiles.length; i++) {
            String fileName = newFiles[i].path.split('/').last;
            formData.files.add(
              MapEntry(
                'new_attachments[]',
                await MultipartFile.fromFile(
                  newFiles[i].path,
                  filename: fileName,
                ),
              ),
            );
          }
        }

        // Add files to delete
        if (filesToDelete.isNotEmpty) {
          formData.fields.add(
            MapEntry('delete_attachments', filesToDelete.join(',')),
          );
        }

        final response = await ApiService.postMultipart(
          "${ApiRoutes.transactionUrl}/${id['id']}",
          formData,
        );

        final results = response.data['results'];
        final transactionModel = await TransactionService.create(
          results['transaction'],
        );

        print('Transaction updated with files: $transactionModel');

        return Result(
          isSuccess: true,
          results: transactionModel,
          message: response.data['message'],
        );
      } else {
        // Use regular PATCH for updates without files
        final response =
            await ApiService.patch("${ApiRoutes.transactionUrl}/${id['id']}", {
              'category': category,
              'account': account,
              'type': type,
              'amount': amount,
              'description': description,
              'notes': notes,
              'transaction_date': transactionDate,
              'active': active,
            }, id);

        final results = response.data['results'];
        final transactionModel = await TransactionService.create(
          results['transaction'],
        );

        print('Transaction updated: $transactionModel');

        return Result(
          isSuccess: true,
          results: transactionModel,
          message: response.data['message'],
        );
      }
    } on DioException catch (e) {
      final message = ApiService.errorMessage(e);
      final errors = e.response?.data['errors'];
      return Result(isSuccess: false, message: message, errors: errors);
    } catch (e) {
      print('Error updating transaction: $e');
      return Result(
        isSuccess: false,
        message: AppStrings.anErrorOccurredTryAgain,
      );
    }
  }

  static Future<Result<TransactionModel>> delete(
    Map<String, dynamic> id,
  ) async {
    try {
      final response = await ApiService.delete(
        "${ApiRoutes.transactionUrl}/${id['id']}",
        id,
      );
      await TransactionService.deleteById(id['id']);
      final message = response.data['message'];
      return Result(isSuccess: true, message: message);
    } on DioException catch (e) {
      final message = ApiService.errorMessage(e);
      final errors = e.response?.data['errors'];
      return Result(isSuccess: false, message: message, errors: errors);
    } catch (e) {
      return Result(
        isSuccess: false,
        message: AppStrings.anErrorOccurredTryAgain,
      );
    }
  }

  // New method to delete specific attachment
  static Future<Result<bool>> deleteAttachment(
    String transactionId,
    String attachmentId,
  ) async {
    try {
      final response = await ApiService.delete(
        "${ApiRoutes.transactionUrl}/$transactionId/attachments/$attachmentId",
        {},
      );

      return Result(
        isSuccess: true,
        message: response.data['message'],
        results: true,
      );
    } on DioException catch (e) {
      final message = ApiService.errorMessage(e);
      final errors = e.response?.data['errors'];
      return Result(isSuccess: false, message: message, errors: errors);
    } catch (e) {
      print('Error deleting attachment: $e');
      return Result(
        isSuccess: false,
        message: AppStrings.anErrorOccurredTryAgain,
      );
    }
  }

  // New method to download attachment
  static Future<Result<String>> downloadAttachment(
    String transactionId,
    String attachmentId,
  ) async {
    try {
      final response = await ApiService.get(
        "${ApiRoutes.transactionUrl}/$transactionId/attachments/$attachmentId/download",
        {},
      );
      // Return the download URL or file path
      return Result(
        isSuccess: true,
        message: 'File downloaded successfully',
        results: response.data['download_url'] ?? response.data['file_path'],
      );
    } on DioException catch (e) {
      final message = ApiService.errorMessage(e);
      final errors = e.response?.data['errors'];
      return Result(isSuccess: false, message: message, errors: errors);
    } catch (e) {
      print('Error downloading attachment: $e');
      return Result(
        isSuccess: false,
        message: AppStrings.anErrorOccurredTryAgain,
      );
    }
  }
}
