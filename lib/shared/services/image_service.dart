import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:http_parser/http_parser.dart';
import 'package:uuid/uuid.dart';
import 'package:image/image.dart' as img;

import 'dio_api_client.dart';

class ImageService {
  /// 캡처한 이미지 바이트를 WebP 형식으로 무손실 압축 후 서버에 업로드합니다.
  /// [childId]와 [localDateTime] 정보도 함께 전송하며, 서버에서 반환하는 파일명을 리턴합니다.
  static Future<void> uploadImage({
    required Uint8List imageBytes,
    required int? childId,
    required DateTime localDateTime,
  }) async {
    try {
      // ✅ 비동기 formDataBuilder
      Future<FormData> formDataBuilder() async {
        final compressed = await FlutterImageCompress.compressWithList(
          imageBytes,
          format: CompressFormat.webp,
          quality: 80,
        );

        final fileName = "${const Uuid().v4()}.webp";

        return FormData.fromMap({
          "childId": childId,
          "localDateTime": localDateTime.toIso8601String(),
          "file": MultipartFile.fromBytes(
            compressed,
            filename: fileName,
            contentType: MediaType("image", "webp"),
          ),
        });
      }

      await ApiClient.dio.post(
        "/image/upload",
        data: await formDataBuilder(), // 초기 요청 시에도 await
        options: Options(
          contentType: 'multipart/form-data',
          extra: {"formDataBuilder": formDataBuilder},
        ),
      );
    } catch (e) {
      debugPrint("❌ Image upload failed: $e");
    }
  }

  // 이미지와 관련된 데이터를 받아서 FormData로 변환
  static FormData buildUploadFormData({
    required Uint8List imageBytes,
    required int? childId,
    required DateTime localDateTime,
  }) {
    final fileName = "${const Uuid().v4()}.webp";

    return FormData.fromMap({
      "childId": childId,
      "localDateTime": localDateTime.toIso8601String(),
      "file": MultipartFile.fromBytes(
        imageBytes,
        filename: fileName,
        contentType: MediaType("image", "webp"),
      ),
    });
  }

  static Future<Uint8List> fixUpsideDown(Uint8List originalBytes) async {
    final decodedImage = img.decodeImage(originalBytes);
    if (decodedImage == null) return originalBytes;

    final flipped = img.flipVertical(decodedImage); // 상하 반전
    return Uint8List.fromList(img.encodePng(flipped));
  }
}
