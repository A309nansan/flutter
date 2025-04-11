import 'package:freezed_annotation/freezed_annotation.dart';

part 'child_profile_model.freezed.dart';
part 'child_profile_model.g.dart';

@freezed
abstract class ChildProfileModel with _$ChildProfileModel {
  const factory ChildProfileModel({
      required int id,
      required String name,
      required String profileImageUrl,
      required String birthDate,
      required String grade,
      required String gender,
  }) = _ChildProfileModel;

  factory ChildProfileModel.fromJson(Map<String, dynamic> json) =>
      _$ChildProfileModelFromJson(json);
}