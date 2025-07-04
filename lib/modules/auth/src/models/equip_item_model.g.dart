// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'equip_item_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$EquipItemModelImpl _$$EquipItemModelImplFromJson(Map<String, dynamic> json) =>
    _$EquipItemModelImpl(
      background: json['background'] as Map<String, dynamic>,
      character: json['character'] as Map<String, dynamic>,
      clothes:
          (json['clothes'] as List<dynamic>?)
              ?.map((e) => e as Map<String, dynamic>)
              .toList() ??
          const [],
      accessories:
          (json['accessories'] as List<dynamic>?)
              ?.map((e) => e as Map<String, dynamic>)
              .toList() ??
          const [],
    );

Map<String, dynamic> _$$EquipItemModelImplToJson(
  _$EquipItemModelImpl instance,
) => <String, dynamic>{
  'background': instance.background,
  'character': instance.character,
  'clothes': instance.clothes,
  'accessories': instance.accessories,
};
