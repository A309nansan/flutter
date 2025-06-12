import 'dart:convert';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:easy_pdf_viewer/easy_pdf_viewer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:liquid_progress_indicator_v2/liquid_progress_indicator.dart';
import 'package:scribble/scribble.dart';
import 'package:value_notifier_tools/value_notifier_tools.dart';
import '../../../../shared/widgets/appbar_widget.dart';
import '../models/drawing_point.dart';

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


  String pdfUrlPrefix = 'https://minio.nansan.site/nansan/pdf/';
  late String chapterCode;
  late String pdfUrl;

  late ScribbleNotifier notifier;

  @override
  void initState() {
    super.initState();
    notifier = ScribbleNotifier();
    setPdfUrl();
    if (pdfUrl.isNotEmpty) loadDocument();
    // clearPdfCache(pdfUrl).then((_) {
    //   loadDocument();
    // });
  }

  Future<void> clearPdfCache(String pdfUrl) async {
    final cacheManager = DefaultCacheManager();
    await cacheManager.removeFile(pdfUrl);
  }

  void setPdfUrl() {
    chapterCode = widget.chapterCode;
    pdfUrl = "$pdfUrlPrefix$chapterCode.pdf";
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

  Paint _getPaint() =>
      Paint()
        ..color = selectedColor
        ..strokeWidth = strokeWidth
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..isAntiAlias = true;

  Paint _getEraserPaint() =>
      Paint()
        ..blendMode = BlendMode.clear
        ..strokeWidth = eraserRadius
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..isAntiAlias = true;

  @override
  Widget build(BuildContext context) {
    var screenWidth = MediaQuery
        .of(context)
        .size
        .width;
    var screenHeight = MediaQuery
        .of(context)
        .size
        .height;

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
          ],
        ),
      ) :

      (!_isLoaded || document == null) ? const Center(
          child: CircularProgressIndicator()) :

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

          Positioned.fill(
            child: isEditing ? Scribble(
              notifier: notifier,
              drawPen: true,
            ) : Container(),
          ),

          AnimatedPositioned(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
            right: isEditing ? 15 : -100,
            top: 120,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildColorToolbar(context),
                const SizedBox(height: 30),
                _buildStrokeToolbar(context),
                const SizedBox(height: 30),
                ValueListenableBuilder(
                  valueListenable: notifier,
                  builder: (context, value, child) => IconButton(
                    icon: child as Icon,
                    tooltip: "Undo",
                    onPressed: notifier.canUndo ? notifier.undo : null,
                  ),
                  child: const Icon(Icons.undo, size: 32),
                ),
                ValueListenableBuilder(
                  valueListenable: notifier,
                  builder: (context, value, child) => IconButton(
                    icon: child as Icon,
                    tooltip: "Redo",
                    onPressed: notifier.canRedo ? notifier.redo : null,
                  ),
                  child: const Icon(Icons.redo, size: 32),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_rounded, size: 28),
                  tooltip: "Clear",
                  onPressed: notifier.clear,
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
                // _buildPointerModeSwitcher(context),
              ],
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

  Widget _buildPointerModeSwitcher(BuildContext context) {
    return ValueListenableBuilder(
        valueListenable: notifier.select(
              (value) => value.allowedPointersMode,
        ),
        builder: (context, value, child) {
          return SegmentedButton<ScribblePointerMode>(
            multiSelectionEnabled: false,
            emptySelectionAllowed: false,
            onSelectionChanged: (v) => notifier.setAllowedPointersMode(v.first),
            segments: const [
              ButtonSegment(
                value: ScribblePointerMode.all,
                icon: Icon(Icons.draw),
              ),
              ButtonSegment(
                value: ScribblePointerMode.penOnly,
                icon: Icon(Icons.back_hand_rounded),
              ),
            ],
            selected: {value},
          );
        });
  }

  Widget _buildColorToolbar(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        _buildColorButton(context, color: Colors.black),
        _buildColorButton(context, color: Colors.red),
        _buildColorButton(context, color: Colors.green),
        _buildColorButton(context, color: Colors.blue),
        _buildColorButton(context, color: Colors.yellow),
        _buildEraserButton(context),
      ],
    );
  }

  Widget _buildColorButton(
      BuildContext context, {
        required Color color,
      }) {
    return ValueListenableBuilder(
      valueListenable: notifier.select((value) =>
      value is Drawing && value.selectedColor == color.toARGB32()),
      builder: (context, value, child) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: ColorButton(
          color: color,
          isActive: value,
          onPressed: () => notifier.setColor(color),
        ),
      ),
    );
  }

  Widget _buildEraserButton(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: notifier.select((value) => value is Erasing),
      builder: (context, value, child) => ColorButton(
        color: Colors.transparent,
        outlineColor: Colors.black,
        isActive: value,
        onPressed: () => notifier.setEraser(),
        child: const Icon(Icons.cleaning_services),
      ),
    );
  }

  List<Widget> _buildActions(context) {
    return [
      ValueListenableBuilder(
        valueListenable: notifier,
        builder: (context, value, child) => IconButton(
          icon: child as Icon,
          tooltip: "Undo",
          onPressed: notifier.canUndo ? notifier.undo : null,
        ),
        child: const Icon(Icons.undo, size: 32),
      ),
      ValueListenableBuilder(
        valueListenable: notifier,
        builder: (context, value, child) => IconButton(
          icon: child as Icon,
          tooltip: "Redo",
          onPressed: notifier.canRedo ? notifier.redo : null,
        ),
        child: const Icon(Icons.redo, size: 32),
      ),
      IconButton(
        icon: const Icon(Icons.delete_rounded, size: 28),
        tooltip: "Clear",
        onPressed: notifier.clear,
      ),
      // IconButton(
      //   icon: const Icon(Icons.image),
      //   tooltip: "Show PNG Image",
      //   onPressed: () => _showImage(context),
      // ),
      // IconButton(
      //   icon: const Icon(Icons.data_object),
      //   tooltip: "Show JSON",
      //   onPressed: () => _showJson(context),
      // ),
    ];
  }

  void _showImage(BuildContext context) async {
    final image = notifier.renderImage();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Generated Image"),
        content: SizedBox.expand(
          child: FutureBuilder(
            future: image,
            builder: (context, snapshot) => snapshot.hasData
                ? Image.memory(snapshot.data!.buffer.asUint8List())
                : const Center(child: CircularProgressIndicator()),
          ),
        ),
        actions: [
          TextButton(
            onPressed: Navigator.of(context).pop,
            child: const Text("Close"),
          )
        ],
      ),
    );
  }

  void _showJson(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Sketch as JSON"),
        content: SizedBox.expand(
          child: SelectableText(
            jsonEncode(notifier.currentSketch.toJson()),
            autofocus: true,
          ),
        ),
        actions: [
          TextButton(
            onPressed: Navigator.of(context).pop,
            child: const Text("Close"),
          )
        ],
      ),
    );
  }

  Widget _buildStrokeToolbar(BuildContext context) {
    return ValueListenableBuilder<ScribbleState>(
      valueListenable: notifier,
      builder: (context, state, _) => Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          for (final w in notifier.widths)
            _buildStrokeButton(
              context,
              strokeWidth: w,
              state: state,
            ),
        ],
      ),
    );
  }

  Widget _buildStrokeButton(
      BuildContext context, {
        required double strokeWidth,
        required ScribbleState state,
      }) {
    final selected = state.selectedWidth == strokeWidth;
    return Padding(
      padding: const EdgeInsets.all(4),
      child: Material(
        elevation: selected ? 4 : 0,
        shape: const CircleBorder(),
        child: InkWell(
          onTap: () => notifier.setStrokeWidth(strokeWidth),
          customBorder: const CircleBorder(),
          child: AnimatedContainer(
            duration: kThemeAnimationDuration,
            width: strokeWidth * 2,
            height: strokeWidth * 2,
            decoration: BoxDecoration(
                color: state.map(
                  drawing: (s) => Color(s.selectedColor),
                  erasing: (_) => Colors.transparent,
                ),
                border: state.map(
                  drawing: (_) => null,
                  erasing: (_) => Border.all(width: 1),
                ),
                borderRadius: BorderRadius.circular(50.0)),
          ),
        ),
      ),
    );
  }
}

class ColorButton extends StatelessWidget {
  const ColorButton({
    required this.color,
    required this.isActive,
    required this.onPressed,
    this.outlineColor,
    this.child,
    super.key,
  });

  final Color color;
  final Color? outlineColor;
  final bool isActive;
  final VoidCallback onPressed;
  final Icon? child;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: kThemeAnimationDuration,
      decoration: ShapeDecoration(
        shape: CircleBorder(
          side: BorderSide(
            color: switch (isActive) {
              true => outlineColor ?? color,
              false => Colors.transparent,
            },
            width: 2,
          ),
        ),
      ),
      child: IconButton(
        style: FilledButton.styleFrom(
          backgroundColor: color,
          shape: const CircleBorder(),
          side: isActive
              ? const BorderSide(color: Colors.white, width: 2)
              : const BorderSide(color: Colors.transparent),
        ),
        onPressed: onPressed,
        icon: child ?? const SizedBox(),
      ),
    );
  }
}