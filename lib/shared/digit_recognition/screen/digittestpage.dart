import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nansan_flutter/shared/digit_recognition/widgets/handwriting_recognition_zone_copy.dart';
import 'package:nansan_flutter/shared/widgets/appbar_widget.dart';
import 'package:nansan_flutter/shared/widgets/new_header_widget.dart';
import 'package:nansan_flutter/shared/widgets/new_question_text.dart';
import 'package:screenshot/screenshot.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:image/image.dart' as img;

class DigitTestPage extends ConsumerStatefulWidget {
  const DigitTestPage({super.key});

  @override
  ConsumerState createState() => DigitTestPageState();
}

class DigitTestPageState extends ConsumerState
    with TickerProviderStateMixin {
  final ScreenshotController _digitScreenshotController = ScreenshotController();
  late Interpreter _interpreter;
  String _recognizedDigit = '';
  double _confidence = 0.0;
  bool _isRecognizing = false;
  final GlobalKey<HandwritingRecognitionZoneTestState> _recognitionZoneKey = GlobalKey();


  @override
  void initState() {
    super.initState();
    _loadModel();
  }

  Future _loadModel() async {
    try {
      _interpreter = await Interpreter.fromAsset('assets/tflite/base_model.tflite');
      debugPrint('모델 로드 성공');

      // 모델의 입출력 정보 확인
      var inputTensor = _interpreter.getInputTensor(0);
      var outputTensor = _interpreter.getOutputTensor(0);
      debugPrint('입력 형식: ${inputTensor.shape}');
      debugPrint('출력 형식: ${outputTensor.shape}');
    } catch (e) {
      debugPrint('모델 로드 실패: $e');
    }
  }

  // 이미지를 Float32List로 변환하는 함수
  Future<Float32List> preprocessImage(Uint8List imageBytes) async {
    try {
      final img.Image? originalImage = img.decodeImage(imageBytes);

      if (originalImage == null) {
        throw Exception('이미지 디코딩 실패');
      }

      final img.Image resizedImage = img.copyResize(originalImage, width: 28, height: 28);
      final img.Image grayscaleImage = img.grayscale(resizedImage);

      final Float32List inputBuffer = Float32List(28 * 28);
      int pixelIndex = 0;

      for (int y = 0; y < 28; y++) {
        for (int x = 0; x < 28; x++) {
          // Pixel 객체에서 빨간 채널 값 추출
          final pixel = grayscaleImage.getPixel(x, y);
          final intensity = pixel.r.toDouble(); // r, g, b 중 아무 값이나 사용 가능

          inputBuffer[pixelIndex++] = intensity / 255.0;
        }
      }

      return inputBuffer;
    } catch (e) {
      debugPrint('이미지 전처리 실패: $e');
      throw Exception('이미지 전처리 실패: $e');
    }
  }


  // 모델로 추론 실행하는 함수
  Future<Map<String, dynamic>> runInference(Float32List inputBuffer) async {
    try {
      // 모델 입력 형식에 맞게 변형 (1, 28, 28, 1)
      final input = [inputBuffer];

      // 출력 버퍼 준비 (10개 클래스에 대한 확률)
      final List<double> output = List.filled(10, 0);

      // 모델 추론 실행
      _interpreter.run(input, output);

      // 가장 확률이 높은 숫자 찾기
      int maxIndex = 0;
      double maxProb = output[0];

      for (int i = 1; i < output.length; i++) {
        if (output[i] > maxProb) {
          maxProb = output[i];
          maxIndex = i;
        }
      }

      return {
        'digit': maxIndex.toString(),
        'confidence': maxProb,
      };
    } catch (e) {
      debugPrint('추론 실패: $e');
      throw Exception('추론 실패: $e');
    }
  }

  // 인식하기 버튼 클릭 처리 함수
  void recognizeDigit() async {
    if (_isRecognizing) return;

    setState(() {
      _isRecognizing = true;
    });

    try {
      // 스크린샷 캡처
      final Uint8List? capturedImage = await _digitScreenshotController.capture();

      if (capturedImage != null) {
        // 이미지 전처리
        final Float32List preprocessedImage = await preprocessImage(capturedImage);

        // 모델 추론
        final Map<String, dynamic> result = await runInference(preprocessedImage);

        setState(() {
          _recognizedDigit = result['digit'];
          _confidence = result['confidence'];
          _isRecognizing = false;
        });
      } else {
        setState(() {
          _isRecognizing = false;
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('스크린샷 캡처에 실패했습니다.')),
          );
        }
      }
    } catch (e) {
      setState(() {
        _isRecognizing = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('오류 발생: $e')),
        );
      }
    }
  }

  // 손글씨 초기화 함수
  void clearCanvas() {
    final handwritingState = _recognitionZoneKey.currentState;
    if (handwritingState != null) {
      handwritingState.clear();
    }
    setState(() {
      _recognizedDigit = '';
      _confidence = 0.0;
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppbarWidget(
        title: null,
        leading: IconButton(
          icon: const Icon(Icons.chevron_left, size: 40.0),
          onPressed: () => Modular.to.pop(),
        ),
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Container(
              color: Colors.white,
              child: Column(
                children: [
                  Container(
                    color: Colors.white,
                    child: Column(
                      children: [
                        NewHeaderWidget(
                          headerText: '주요학습활동',
                          headerTextSize: screenWidth * 0.028,
                          subTextSize: screenWidth * 0.018,
                        ),
                        SizedBox(height: screenHeight * 0.01),
                        NewQuestionTextWidget(
                          questionText: '회색 빈칸에 알맞은 1 작은 수를 나타내는 그림은 무엇일까요?',
                          questionTextSize: screenWidth * 0.03,
                        ),
                        SizedBox(height: screenHeight * 0.02),

                        // 손글씨 영역
                        HandwritingRecognitionZoneTest(
                          key: _recognitionZoneKey,
                          width: 200,
                          height: 200,
                          controller: _digitScreenshotController,
                        ),
                        SizedBox(height: screenHeight * 0.02),

                        // 버튼 영역
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ElevatedButton(
                              onPressed: _isRecognizing ? null : recognizeDigit,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue,
                                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                              ),
                              child: _isRecognizing
                                  ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  )
                              )
                                  : const Text('인식하기', style: TextStyle(color: Colors.white)),
                            ),
                            const SizedBox(width: 16),
                            ElevatedButton(
                              onPressed: clearCanvas,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.grey[300],
                                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                              ),
                              child: const Text('지우기'),
                            ),
                          ],
                        ),

                        SizedBox(height: screenHeight * 0.03),
                        // 결과 표시 영역
                        if (_recognizedDigit.isNotEmpty)
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.blue.shade50,
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey,
                                  spreadRadius: 1,
                                  blurRadius: 3,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Column(
                              children: [
                                const Text(
                                  '인식 결과',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  _recognizedDigit,
                                  style: const TextStyle(
                                    fontSize: 48,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blue,
                                  ),
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  '정확도: ${(_confidence * 100).toStringAsFixed(1)}%',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[700],
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _interpreter.close();
    super.dispose();
  }
}
