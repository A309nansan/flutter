import 'package:flutter/material.dart';

class FeedbackAnimatorService {
  static final FeedbackAnimatorService _instance = FeedbackAnimatorService._internal();
  factory FeedbackAnimatorService() => _instance;

  FeedbackAnimatorService._internal();

  final ValueNotifier<String?> currentAsset = ValueNotifier(null); // 애니메이션 트리거

  void setAnimatorStatus(String asset) {
    currentAsset.value = asset;
    Future.delayed(const Duration(milliseconds: 1200), () {
      currentAsset.value = null;
    });
  }

  void clear() {
    currentAsset.value = null;
  }
}