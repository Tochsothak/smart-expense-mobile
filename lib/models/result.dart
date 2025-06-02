import 'package:json_annotation/json_annotation.dart';

part 'result.g.dart';

@JsonSerializable(genericArgumentFactories: true)
class Result<T> {
  final String message;
  final bool isSuccess;
  T? result;

  Map<String, dynamic>? errors;

  Result({
    required this.message,
    this.result,
    required this.isSuccess,
    this.errors,
  });

  /// Connect the generated [_$ResponseFromJson] function to the `fromJson`
  /// factory.
  factory Result.fromJson(
    Map<String, dynamic> json,
    T Function(Object? json) fromJsonT,
  ) => _$ResultFromJson(json, fromJsonT);

  /// Connect the generated [_$ResponseToJson] function to the `toJson` method.
  Map<String, dynamic> toJson(Object Function(T value) toJsonT) =>
      _$ResultToJson(this, toJsonT);
}
