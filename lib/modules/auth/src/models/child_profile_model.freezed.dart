// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'child_profile_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

ChildProfileModel _$ChildProfileModelFromJson(Map<String, dynamic> json) {
  return _ChildProfileModel.fromJson(json);
}

/// @nodoc
mixin _$ChildProfileModel {
  int get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String get profileImageUrl => throw _privateConstructorUsedError;
  String get birthDate => throw _privateConstructorUsedError;
  String get grade => throw _privateConstructorUsedError;
  String get gender => throw _privateConstructorUsedError;
  equippedItemsResponse get equipItem => throw _privateConstructorUsedError;

  /// Serializes this ChildProfileModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ChildProfileModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ChildProfileModelCopyWith<ChildProfileModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ChildProfileModelCopyWith<$Res> {
  factory $ChildProfileModelCopyWith(
    ChildProfileModel value,
    $Res Function(ChildProfileModel) then,
  ) = _$ChildProfileModelCopyWithImpl<$Res, ChildProfileModel>;
  @useResult
  $Res call({
    int id,
    String name,
    String profileImageUrl,
    String birthDate,
    String grade,
    String gender,
    equippedItemsResponse equipItem,
  });

  $EquipItemModelCopyWith<$Res> get equipItem;
}

/// @nodoc
class _$ChildProfileModelCopyWithImpl<$Res, $Val extends ChildProfileModel>
    implements $ChildProfileModelCopyWith<$Res> {
  _$ChildProfileModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ChildProfileModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? profileImageUrl = null,
    Object? birthDate = null,
    Object? grade = null,
    Object? gender = null,
    Object? equipItem = null,
  }) {
    return _then(
      _value.copyWith(
            id:
                null == id
                    ? _value.id
                    : id // ignore: cast_nullable_to_non_nullable
                        as int,
            name:
                null == name
                    ? _value.name
                    : name // ignore: cast_nullable_to_non_nullable
                        as String,
            profileImageUrl:
                null == profileImageUrl
                    ? _value.profileImageUrl
                    : profileImageUrl // ignore: cast_nullable_to_non_nullable
                        as String,
            birthDate:
                null == birthDate
                    ? _value.birthDate
                    : birthDate // ignore: cast_nullable_to_non_nullable
                        as String,
            grade:
                null == grade
                    ? _value.grade
                    : grade // ignore: cast_nullable_to_non_nullable
                        as String,
            gender:
                null == gender
                    ? _value.gender
                    : gender // ignore: cast_nullable_to_non_nullable
                        as String,
            equipItem:
                null == equipItem
                    ? _value.equipItem
                    : equipItem // ignore: cast_nullable_to_non_nullable
                        as equippedItemsResponse,
          )
          as $Val,
    );
  }

  /// Create a copy of ChildProfileModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $EquipItemModelCopyWith<$Res> get equipItem {
    return $EquipItemModelCopyWith<$Res>(_value.equipItem, (value) {
      return _then(_value.copyWith(equipItem: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$ChildProfileModelImplCopyWith<$Res>
    implements $ChildProfileModelCopyWith<$Res> {
  factory _$$ChildProfileModelImplCopyWith(
    _$ChildProfileModelImpl value,
    $Res Function(_$ChildProfileModelImpl) then,
  ) = __$$ChildProfileModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    int id,
    String name,
    String profileImageUrl,
    String birthDate,
    String grade,
    String gender,
    equippedItemsResponse equipItem,
  });

  @override
  $EquipItemModelCopyWith<$Res> get equipItem;
}

/// @nodoc
class __$$ChildProfileModelImplCopyWithImpl<$Res>
    extends _$ChildProfileModelCopyWithImpl<$Res, _$ChildProfileModelImpl>
    implements _$$ChildProfileModelImplCopyWith<$Res> {
  __$$ChildProfileModelImplCopyWithImpl(
    _$ChildProfileModelImpl _value,
    $Res Function(_$ChildProfileModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ChildProfileModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? profileImageUrl = null,
    Object? birthDate = null,
    Object? grade = null,
    Object? gender = null,
    Object? equipItem = null,
  }) {
    return _then(
      _$ChildProfileModelImpl(
        id:
            null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                    as int,
        name:
            null == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                    as String,
        profileImageUrl:
            null == profileImageUrl
                ? _value.profileImageUrl
                : profileImageUrl // ignore: cast_nullable_to_non_nullable
                    as String,
        birthDate:
            null == birthDate
                ? _value.birthDate
                : birthDate // ignore: cast_nullable_to_non_nullable
                    as String,
        grade:
            null == grade
                ? _value.grade
                : grade // ignore: cast_nullable_to_non_nullable
                    as String,
        gender:
            null == gender
                ? _value.gender
                : gender // ignore: cast_nullable_to_non_nullable
                    as String,
        equipItem:
            null == equipItem
                ? _value.equipItem
                : equipItem // ignore: cast_nullable_to_non_nullable
                    as equippedItemsResponse,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ChildProfileModelImpl implements _ChildProfileModel {
  const _$ChildProfileModelImpl({
    required this.id,
    required this.name,
    required this.profileImageUrl,
    required this.birthDate,
    required this.grade,
    required this.gender,
    this.equipItem = const equippedItemsResponse(
      background: {"itemCode": 101},
      character: {"itemCode": 201},
      clothes: [],
      accessories: [],
    ),
  });

  factory _$ChildProfileModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$ChildProfileModelImplFromJson(json);

  @override
  final int id;
  @override
  final String name;
  @override
  final String profileImageUrl;
  @override
  final String birthDate;
  @override
  final String grade;
  @override
  final String gender;
  @override
  @JsonKey()
  final equippedItemsResponse equipItem;

  @override
  String toString() {
    return 'ChildProfileModel(id: $id, name: $name, profileImageUrl: $profileImageUrl, birthDate: $birthDate, grade: $grade, gender: $gender, equipItem: $equipItem)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ChildProfileModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.profileImageUrl, profileImageUrl) ||
                other.profileImageUrl == profileImageUrl) &&
            (identical(other.birthDate, birthDate) ||
                other.birthDate == birthDate) &&
            (identical(other.grade, grade) || other.grade == grade) &&
            (identical(other.gender, gender) || other.gender == gender) &&
            (identical(other.equipItem, equipItem) ||
                other.equipItem == equipItem));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    name,
    profileImageUrl,
    birthDate,
    grade,
    gender,
    equipItem,
  );

  /// Create a copy of ChildProfileModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ChildProfileModelImplCopyWith<_$ChildProfileModelImpl> get copyWith =>
      __$$ChildProfileModelImplCopyWithImpl<_$ChildProfileModelImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$ChildProfileModelImplToJson(this);
  }
}

abstract class _ChildProfileModel implements ChildProfileModel {
  const factory _ChildProfileModel({
    required final int id,
    required final String name,
    required final String profileImageUrl,
    required final String birthDate,
    required final String grade,
    required final String gender,
    final equippedItemsResponse equipItem,
  }) = _$ChildProfileModelImpl;

  factory _ChildProfileModel.fromJson(Map<String, dynamic> json) =
      _$ChildProfileModelImpl.fromJson;

  @override
  int get id;
  @override
  String get name;
  @override
  String get profileImageUrl;
  @override
  String get birthDate;
  @override
  String get grade;
  @override
  String get gender;
  @override
  equippedItemsResponse get equipItem;

  /// Create a copy of ChildProfileModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ChildProfileModelImplCopyWith<_$ChildProfileModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
