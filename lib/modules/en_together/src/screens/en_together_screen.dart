import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:easy_pdf_viewer/easy_pdf_viewer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:liquid_progress_indicator_v2/liquid_progress_indicator.dart';
import '../../../../shared/widgets/appbar_widget.dart';
import '../models/drawing_point.dart';
import '../widgets/color_picker_dialog.dart';
import '../widgets/drawing_painter.dart';
import '../widgets/eraser_guide_painter.dart';
import '../widgets/eraser_preview_painter.dart';
import '../widgets/stroke_preview_painter.dart';

class EnTogetherScreen extends StatefulWidget {
  final String chapterCode;

  const EnTogetherScreen({super.key, required this.chapterCode});

  @override
  EnTogetherState createState() => EnTogetherState();
}

class EnTogetherState extends State<EnTogetherScreen> {
  String? localFilePath;
  List<List<DrawingPoint>> lines = [];
  List<List<DrawingPoint>> undoneLines = [];
  List<DrawingPoint> currentLine = [];

  Color selectedColor = Colors.red;
  double strokeWidth = 10.0;
  bool isEraser = false;
  double eraserRadius = 15.0;
  Offset? pointerPosition;
  bool isDragging = false;
  bool showStrokeToolbar = false;
  bool showEraserToolbar = false;

  final GlobalKey _gestureKey = GlobalKey();

  bool isEditing = false;

  PDFDocument? document;
  double _progress = 0.0;
  bool _isDownloading = false;
  bool _isLoaded = false;

  String pdfUrl = 'https://minio.nansan.site/nansan/4차시_교사.pdf';

  @override
  void initState() {
    super.initState();
    loadDocument();
    // clearPdfCache(pdfUrl).then((_) {
    //   loadDocument();
    // });
  }

  Future<void> clearPdfCache(String pdfUrl) async {
    final cacheManager = DefaultCacheManager();
    await cacheManager.removeFile(pdfUrl);
  }

  Future<void> loadDocument() async {
    final cached = await DefaultCacheManager().getFileFromCache(pdfUrl);

    if (cached != null && cached.file.existsSync()) {
      final doc = await PDFDocument.fromFile(cached.file);
      setState(() {
        document = doc;
        _isLoaded = true;
        _isDownloading = false;
      });
    } else {
      setState(() {
        _isDownloading = true;
        _isLoaded = false;
      });

      PDFDocument.fromURLWithDownloadProgress(
        pdfUrl,
        downloadProgress: (progress) {
          setState(() {
            _progress = progress.progress ?? 0.0;
          });
        },
        onDownloadComplete: (doc) {
          setState(() {
            document = doc;
            _isLoaded = true;
            _isDownloading = false;
          });
        },
        // cacheManager: NoExpiryCacheManager()
      );
    }
  }

  Offset _getLocal(Offset global) {
    final box = _gestureKey.currentContext!.findRenderObject() as RenderBox;
    return box.globalToLocal(global);
  }

  Paint _getPaint() => Paint()
    ..color = selectedColor
    ..strokeWidth = strokeWidth
    ..style = PaintingStyle.stroke
    ..strokeCap = StrokeCap.round
    ..isAntiAlias = true;

  Paint _getEraserPaint() => Paint()
    ..blendMode = BlendMode.clear
    ..strokeWidth = eraserRadius
    ..style = PaintingStyle.stroke
    ..strokeCap = StrokeCap.round
    ..isAntiAlias = true;

  @override
  Widget build(BuildContext context) {
    var screenWidth = MediaQuery.of(context).size.width;
    var screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppbarWidget(
        title: null,
        leading: IconButton(
          icon: const Icon(Icons.chevron_left, size: 40.0),
          onPressed: () => Modular.to.pop(),
        ),
      ),
        body: _isDownloading ?
        Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: screenWidth * 0.25,
                height: screenWidth * 0.25,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(40),
                      spreadRadius: 2,
                      blurRadius: 4,
                      offset: Offset(2, 4),
                    ),
                  ],
                ),
                child: ClipOval(
                  child: LiquidCircularProgressIndicator(
                    value: _progress,
                    valueColor: AlwaysStoppedAnimation(Colors.blue),
                    backgroundColor: Color(0xE6E4F0FF),
                    borderColor: Colors.blueAccent.withAlpha(0),
                    borderWidth: 0.0,
                    direction: Axis.vertical,
                    center: Text(
                      "${(_progress * 100).toStringAsFixed(0)}%",
                      style: TextStyle(
                        fontSize: screenWidth * 0.035,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 35),
              DefaultTextStyle(
                style: const TextStyle(
                    fontSize: 24.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                    shadows: [
                      Shadow(
                          blurRadius: 3,
                          offset: Offset(0, 2),
                          color: Colors.black12
                      )
                    ]
                ),
                child: AnimatedTextKit(
                  animatedTexts: [
                    WavyAnimatedText(
                      '자료를 다운로드하고 있습니다...',
                      speed: const Duration(milliseconds: 300),
                    ),
                  ],
                  isRepeatingAnimation: true,
                  repeatForever: true,
                ),
              ),

              // Container(
              //   margin: const EdgeInsets.symmetric(vertical: 20),
              //   width: screenWidth * 0.4,
              //   height: 30,
              //   decoration: BoxDecoration(
              //     borderRadius: BorderRadius.circular(16),
              //     boxShadow: [
              //       BoxShadow(
              //         color: Colors.black.withAlpha(40),
              //         spreadRadius: 2,
              //         blurRadius: 4,
              //         offset: Offset(2, 4),
              //       ),
              //     ],
              //   ),
              //   child: ClipRRect(
              //     borderRadius: BorderRadius.circular(16),
              //     child: LiquidLinearProgressIndicator(
              //       value: _progress,
              //       valueColor: AlwaysStoppedAnimation(Colors.blue),
              //       backgroundColor: Color(0xE6E4F0FF),
              //       borderColor: Colors.blueAccent.withAlpha(0),
              //       borderWidth: 0.0,
              //       direction: Axis.horizontal,
              //       center: Text(
              //         "${(_progress * 100).toStringAsFixed(0)}%",
              //         style: TextStyle(
              //           fontSize: screenWidth * 0.02,
              //           color: Colors.white,
              //           fontWeight: FontWeight.bold,
              //         ),
              //       ),
              //     ),
              //   ),
              // ),
            ],
          ),
        ) :

        (!_isLoaded || document == null) ? const Center(child: CircularProgressIndicator()) :

        Stack(
          children: [

            /// PDF Viewer
            Positioned.fill(
              child: PDFViewer(
                document: document!,
                lazyLoad: false,
                zoomSteps: 1,
                showPicker: false,
                showIndicator: false,
                navigationBuilder:
                    (context, page, totalPages, jumpToPage, animateToPage) {
                  return Container(
                    color: Colors.white,
                    padding: const EdgeInsets.all(20.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Container(
                          width: screenWidth * 0.18,
                          height: screenHeight * 0.04,
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFFAE1),
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withAlpha(20),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              IconButton(
                                icon: Icon(Icons.arrow_back_ios_rounded),
                                onPressed: () {
                                  animateToPage(page: page! - 2);
                                },
                              ),
                              Text(
                                "$page / $totalPages",
                                style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold
                                ),
                              ),
                              IconButton(
                                icon: Icon(Icons.arrow_forward_ios_rounded),
                                onPressed: () {
                                  animateToPage(page: page);
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            /// Drawing Layer
            Positioned.fill(
              child: isEditing
                  ? GestureDetector(
                key: _gestureKey,
                onPanStart: (details) {
                  final localPos = _getLocal(details.globalPosition);
                  setState(() {
                    pointerPosition = localPos;
                    isDragging = true;

                    currentLine = [
                      DrawingPoint(
                        localPos,
                        isEraser ? _getEraserPaint() : _getPaint(),
                      )
                    ];
                    undoneLines.clear();
                  });
                },
                onPanUpdate: (details) {
                  final localPos = _getLocal(details.globalPosition);
                  setState(() {
                    pointerPosition = localPos;

                    currentLine.add(
                      DrawingPoint(
                        localPos,
                        isEraser ? _getEraserPaint() : _getPaint(),
                      ),
                    );
                  });
                },
                onPanEnd: (_) {
                  setState(() {
                    if (currentLine.isNotEmpty) {
                      lines.add(currentLine);
                    }
                    currentLine = [];
                    pointerPosition = null;
                    isDragging = false;
                  });
                },
                child: Stack(
                  children: [
                    RepaintBoundary(
                      child: CustomPaint(
                        size: Size.infinite,
                        painter: DrawingPainter([...lines, currentLine]),
                        child: Container(),
                      ),
                    ),
                    RepaintBoundary(
                      child: CustomPaint(
                        size: Size.infinite,
                        painter: EraserGuidePainter(
                          pointerPosition: pointerPosition,
                          radius: eraserRadius / 2,
                          isVisible: isEraser && isDragging,
                        ),
                      ),
                    ),
                  ],
                ),
              )
                  : Container(),
            ),

            /// Tool Bar
            AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut,
              right: isEditing ? 15 : -100,
              top: 120,
              // top: isEditing ? 0 : -150,
              child: Container(
                // color: const Color(0xFFFFFAE1),
                padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 40),
                width: screenWidth * 0.10,
                height: screenHeight * 0.5,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFFAE1),
                  borderRadius: BorderRadius.circular(100),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(30),
                      blurRadius: 100,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    /// 상단 툴들
                    Column(
                      children: [
                        GestureDetector(
                          onTap: () {
                            showColorPickerDialog(
                              context: context,
                              selectedColor: selectedColor,
                              onColorChanged: (color) {
                                setState(() {
                                  selectedColor = color;
                                });
                              },
                            );
                          },
                          child: Icon(Icons.palette_rounded, size: 45, color: selectedColor),
                        ),
                        const SizedBox(height: 30),
                        GestureDetector(
                          onTap: () => setState(() {
                            isEraser = false;
                            showStrokeToolbar = !showStrokeToolbar;
                            showEraserToolbar = false;
                          }),
                          child: Column(
                            children: [
                              Image.asset(
                                "assets/images/pen.png",
                                width: 40,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 30),
                        GestureDetector(
                          onTap: () => setState(() {
                            isEraser = !isEraser;
                            if(isEraser) showStrokeToolbar = false;
                            if(!isEraser) showEraserToolbar = false;
                          }),
                          child: Column(
                            children: [
                              !isEraser ?
                              Image.asset(
                                "assets/images/eraser.png",
                                width: 40,
                              )
                                  : Icon(
                                Icons.edit_outlined,
                                size: 45,
                              )

                            ],
                          ),
                        ),
                        const SizedBox(height: 30),
                        if (isEraser)
                          GestureDetector(
                            onTap: () => setState(() {
                              showEraserToolbar = !showEraserToolbar;
                              showStrokeToolbar = false;
                            }),
                            child: Column(
                              children: const [
                                Icon(Icons.circle_outlined, size: 40),
                              ],
                            ),
                          ),
                      ],
                    ),

                    /// 항상 아래 고정된 닫기 버튼
                    Column(
                      children: [
                        IconButton(
                          icon: Icon(Icons.undo_rounded, size: 35),
                          onPressed: lines.isNotEmpty
                              ? () {
                            setState(() {
                              final last = lines.removeLast();
                              undoneLines.add(last);
                            });
                          }
                              : null,
                        ),
                        IconButton(
                          icon: Icon(Icons.redo_rounded, size: 35),
                          onPressed: undoneLines.isNotEmpty
                              ? () {
                            setState(() {
                              final restored = undoneLines.removeLast();
                              lines.add(restored);
                            });
                          }
                              : null,
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_rounded, size: 35),
                          onPressed: () {
                            setState(() {
                              lines.clear();
                              undoneLines.clear();
                            });
                          },
                        ),
                        const SizedBox(height: 30),
                        IconButton(
                          icon: const Icon(Icons.close_rounded, size: 40),
                          onPressed: () {
                            setState(() {
                              isEditing = false;
                              showEraserToolbar = false;
                              showStrokeToolbar = false;
                            });
                          },
                        ),
                      ],
                    ),
                  ],
                ),

              ),
            ),

            /// 펜 두께
            if (showStrokeToolbar)
              Positioned(
                top: 160,
                right: screenWidth * 0.10 + 30,
                child: Container(
                  padding: const EdgeInsets.all(12),
                  width: 100,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [BoxShadow(blurRadius: 10, color: Colors.black26)],
                  ),
                  child: Column(
                    children: [
                      Container(
                        width: 50,
                        height: 50,
                        padding: EdgeInsets.only(top: 10),
                        child: CustomPaint(
                          painter: StrokePreviewPainter(strokeWidth, selectedColor),
                        ),
                      ),
                      RotatedBox(
                        quarterTurns: -1,
                        child: Slider(
                          min: 1,
                          max: 40,
                          divisions: 9,
                          value: strokeWidth,
                          // label: strokeWidth.toStringAsFixed(1),
                          onChanged: (value) {
                            setState(() => strokeWidth = value);
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            /// 지우개 두께 툴바
            if (showEraserToolbar)
              Positioned(
                top: 160,
                right: screenWidth * 0.10 + 30,
                child: Container(
                  padding: const EdgeInsets.all(12),
                  width: 100,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [BoxShadow(blurRadius: 10, color: Colors.black26)],
                  ),
                  child: Column(
                    children: [
                      Container(
                        width: 50,
                        height: 50,
                        child: CustomPaint(
                          painter: EraserPreviewPainter(eraserRadius),
                        ),
                      ),
                      RotatedBox(
                        quarterTurns: -1,
                        child: Slider(
                          min: 5,
                          max: 40,
                          divisions: 7,
                          value: eraserRadius,
                          onChanged: (value) {
                            final rounded = (value / 5).round() * 5;
                            setState(() => eraserRadius = rounded.toDouble());
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            /// 편집 버튼
            AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              top: 120,
              right: isEditing ? -100 : 0,
              child: RawMaterialButton(
                onPressed: () {
                  setState(() => isEditing = true);
                },
                fillColor: const Color(0xFFFFFAE1),
                constraints: const BoxConstraints.tightFor(width: 80, height: 70),
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(40),
                    bottomLeft: Radius.circular(40),
                    topRight: Radius.circular(0),
                    bottomRight: Radius.circular(0),
                  ),
                ),
                elevation: 6,
                child: const Icon(Icons.edit, color: Colors.black, size: 35),
              ),
            ),
          ],
        ),
    );
  }
}