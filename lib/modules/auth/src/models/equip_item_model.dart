import 'package:freezed_annotation/freezed_annotation.dart';

part 'equip_item_model.freezed.dart';
part 'equip_item_model.g.dart';

@freezed
class equippedItemsResponse with _$EquipItemModel {
  const factory equippedItemsResponse({
    required Map<String, dynamic> background,
    required Map<String, dynamic> character,
    @Default([]) List<Map<String, dynamic>> clothes,
    @Default([]) List<Map<String, dynamic>> accessories,
  }) = _EquipItemModel;

  factory equippedItemsResponse.fromJson(Map<String, dynamic> json) =>
      _$EquipItemModelFromJson(json);
}
