// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'equip_item_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

equippedItemsResponse _$EquipItemModelFromJson(Map<String, dynamic> json) {
  return _EquipItemModel.fromJson(json);
}

/// @nodoc
mixin _$EquipItemModel {
  Map<String, dynamic> get background => throw _privateConstructorUsedError;
  Map<String, dynamic> get character => throw _privateConstructorUsedError;
  List<Map<String, dynamic>> get clothes => throw _privateConstructorUsedError;
  List<Map<String, dynamic>> get accessories =>
      throw _privateConstructorUsedError;

  /// Serializes this EquipItemModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of EquipItemModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $EquipItemModelCopyWith<equippedItemsResponse> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $EquipItemModelCopyWith<$Res> {
  factory $EquipItemModelCopyWith(
    equippedItemsResponse value,
    $Res Function(equippedItemsResponse) then,
  ) = _$EquipItemModelCopyWithImpl<$Res, equippedItemsResponse>;
  @useResult
  $Res call({
    Map<String, dynamic> background,
    Map<String, dynamic> character,
    List<Map<String, dynamic>> clothes,
    List<Map<String, dynamic>> accessories,
  });
}

/// @nodoc
class _$EquipItemModelCopyWithImpl<$Res, $Val extends equippedItemsResponse>
    implements $EquipItemModelCopyWith<$Res> {
  _$EquipItemModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of EquipItemModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? background = null,
    Object? character = null,
    Object? clothes = null,
    Object? accessories = null,
  }) {
    return _then(
      _value.copyWith(
            background:
                null == background
                    ? _value.background
                    : background // ignore: cast_nullable_to_non_nullable
                        as Map<String, dynamic>,
            character:
                null == character
                    ? _value.character
                    : character // ignore: cast_nullable_to_non_nullable
                        as Map<String, dynamic>,
            clothes:
                null == clothes
                    ? _value.clothes
                    : clothes // ignore: cast_nullable_to_non_nullable
                        as List<Map<String, dynamic>>,
            accessories:
                null == accessories
                    ? _value.accessories
                    : accessories // ignore: cast_nullable_to_non_nullable
                        as List<Map<String, dynamic>>,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$EquipItemModelImplCopyWith<$Res>
    implements $EquipItemModelCopyWith<$Res> {
  factory _$$EquipItemModelImplCopyWith(
    _$EquipItemModelImpl value,
    $Res Function(_$EquipItemModelImpl) then,
  ) = __$$EquipItemModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    Map<String, dynamic> background,
    Map<String, dynamic> character,
    List<Map<String, dynamic>> clothes,
    List<Map<String, dynamic>> accessories,
  });
}

/// @nodoc
class __$$EquipItemModelImplCopyWithImpl<$Res>
    extends _$EquipItemModelCopyWithImpl<$Res, _$EquipItemModelImpl>
    implements _$$EquipItemModelImplCopyWith<$Res> {
  __$$EquipItemModelImplCopyWithImpl(
    _$EquipItemModelImpl _value,
    $Res Function(_$EquipItemModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of EquipItemModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? background = null,
    Object? character = null,
    Object? clothes = null,
    Object? accessories = null,
  }) {
    return _then(
      _$EquipItemModelImpl(
        background:
            null == background
                ? _value._background
                : background // ignore: cast_nullable_to_non_nullable
                    as Map<String, dynamic>,
        character:
            null == character
                ? _value._character
                : character // ignore: cast_nullable_to_non_nullable
                    as Map<String, dynamic>,
        clothes:
            null == clothes
                ? _value._clothes
                : clothes // ignore: cast_nullable_to_non_nullable
                    as List<Map<String, dynamic>>,
        accessories:
            null == accessories
                ? _value._accessories
                : accessories // ignore: cast_nullable_to_non_nullable
                    as List<Map<String, dynamic>>,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$EquipItemModelImpl implements _EquipItemModel {
  const _$EquipItemModelImpl({
    required final Map<String, dynamic> background,
    required final Map<String, dynamic> character,
    final List<Map<String, dynamic>> clothes = const [],
    final List<Map<String, dynamic>> accessories = const [],
  }) : _background = background,
       _character = character,
       _clothes = clothes,
       _accessories = accessories;

  factory _$EquipItemModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$EquipItemModelImplFromJson(json);

  final Map<String, dynamic> _background;
  @override
  Map<String, dynamic> get background {
    if (_background is EqualUnmodifiableMapView) return _background;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_background);
  }

  final Map<String, dynamic> _character;
  @override
  Map<String, dynamic> get character {
    if (_character is EqualUnmodifiableMapView) return _character;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_character);
  }

  final List<Map<String, dynamic>> _clothes;
  @override
  @JsonKey()
  List<Map<String, dynamic>> get clothes {
    if (_clothes is EqualUnmodifiableListView) return _clothes;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_clothes);
  }

  final List<Map<String, dynamic>> _accessories;
  @override
  @JsonKey()
  List<Map<String, dynamic>> get accessories {
    if (_accessories is EqualUnmodifiableListView) return _accessories;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_accessories);
  }

  @override
  String toString() {
    return 'EquipItemModel(background: $background, character: $character, clothes: $clothes, accessories: $accessories)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$EquipItemModelImpl &&
            const DeepCollectionEquality().equals(
              other._background,
              _background,
            ) &&
            const DeepCollectionEquality().equals(
              other._character,
              _character,
            ) &&
            const DeepCollectionEquality().equals(other._clothes, _clothes) &&
            const DeepCollectionEquality().equals(
              other._accessories,
              _accessories,
            ));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    const DeepCollectionEquality().hash(_background),
    const DeepCollectionEquality().hash(_character),
    const DeepCollectionEquality().hash(_clothes),
    const DeepCollectionEquality().hash(_accessories),
  );

  /// Create a copy of EquipItemModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$EquipItemModelImplCopyWith<_$EquipItemModelImpl> get copyWith =>
      __$$EquipItemModelImplCopyWithImpl<_$EquipItemModelImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$EquipItemModelImplToJson(this);
  }
}

abstract class _EquipItemModel implements equippedItemsResponse {
  const factory _EquipItemModel({
    required final Map<String, dynamic> background,
    required final Map<String, dynamic> character,
    final List<Map<String, dynamic>> clothes,
    final List<Map<String, dynamic>> accessories,
  }) = _$EquipItemModelImpl;

  factory _EquipItemModel.fromJson(Map<String, dynamic> json) =
      _$EquipItemModelImpl.fromJson;

  @override
  Map<String, dynamic> get background;
  @override
  Map<String, dynamic> get character;
  @override
  List<Map<String, dynamic>> get clothes;
  @override
  List<Map<String, dynamic>> get accessories;

  /// Create a copy of EquipItemModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$EquipItemModelImplCopyWith<_$EquipItemModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
