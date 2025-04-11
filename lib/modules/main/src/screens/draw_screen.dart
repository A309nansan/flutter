import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'dart:ui';

class DrawScreen extends StatefulWidget {
  const DrawScreen({super.key});

  @override
  DrawScreenState createState() => DrawScreenState();
}

class DrawScreenState extends State<DrawScreen> {
  String? localFilePath;
  Color selectedColor = Colors.black;
  Color pickerColor = Colors.black;
  double strokeWidth = 3.0;
  List<DrawingPoints?> points = [];
  bool showBottomList = false;
  double opacity = 1.0;
  StrokeCap strokeCap = (Platform.isAndroid) ? StrokeCap.butt : StrokeCap.round;
  SelectedMode selectedMode = SelectedMode.StrokeWidth;
  List<Color> colors = [
    Colors.red,
    Colors.green,
    Colors.blue,
    Colors.amber,
    Colors.black,
  ];

  @override
  void initState() {
    super.initState();
    _copyPdfAndLoad();
  }

  // assets 폴더의 PDF 파일을 내부 저장소로 복사 후 로드
  Future<void> _copyPdfAndLoad() async {
    try {
      Directory dir = await getApplicationDocumentsDirectory();
      String path = '${dir.path}/sample_pdf.pdf'; // 내부 저장소에 저장될 경로

      if (!(await File(path).exists())) {
        // assets에서 PDF 파일을 불러와 내부 저장소로 복사
        ByteData data = await rootBundle.load('assets/images/sample_pdf.pdf');
        List<int> bytes = data.buffer.asUint8List();
        await File(path).writeAsBytes(bytes);
      }

      setState(() {
        localFilePath = path;
      });
    } catch (e) {
      debugPrint('error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Show PDF & Draw")),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Container(
          padding: const EdgeInsets.only(left: 8.0, right: 8.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(50.0),
            color: Colors.greenAccent,
          ),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    IconButton(
                      icon: Icon(Icons.album),
                      onPressed: () {
                        setState(() {
                          if (selectedMode == SelectedMode.StrokeWidth) {
                            showBottomList = !showBottomList;
                          }
                          selectedMode = SelectedMode.StrokeWidth;
                        });
                      },
                    ),
                    IconButton(
                      icon: Icon(Icons.opacity),
                      onPressed: () {
                        setState(() {
                          if (selectedMode == SelectedMode.Opacity) {
                            showBottomList = !showBottomList;
                          }
                          selectedMode = SelectedMode.Opacity;
                        });
                      },
                    ),
                    IconButton(
                      icon: Icon(Icons.color_lens),
                      onPressed: () {
                        setState(() {
                          if (selectedMode == SelectedMode.Color) {
                            showBottomList = !showBottomList;
                          }
                          selectedMode = SelectedMode.Color;
                        });
                      },
                    ),
                    IconButton(
                      icon: Icon(Icons.clear),
                      onPressed: () {
                        setState(() {
                          showBottomList = false;
                          points.clear();
                        });
                      },
                    ),
                  ],
                ),
                Visibility(
                  visible: showBottomList,
                  child:
                      (selectedMode == SelectedMode.Color)
                          ? Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: getColorList(),
                          )
                          : Slider(
                            value:
                                (selectedMode == SelectedMode.StrokeWidth)
                                    ? strokeWidth
                                    : opacity,
                            max:
                                (selectedMode == SelectedMode.StrokeWidth)
                                    ? 50.0
                                    : 1.0,
                            min: 0.0,
                            onChanged: (val) {
                              setState(() {
                                if (selectedMode == SelectedMode.StrokeWidth) {
                                  strokeWidth = val;
                                } else {
                                  opacity = val;
                                }
                              });
                            },
                          ),
                ),
              ],
            ),
          ),
        ),
      ),
      body:
          localFilePath == null
              ? Center(child: CircularProgressIndicator())
              : Stack(
                children: [
                  /// PDF Viewer
                  Positioned.fill(
                    child: PDFView(
                      filePath: localFilePath!,
                      enableSwipe: true,
                      autoSpacing: false,
                      pageFling: true,
                      fitPolicy: FitPolicy.BOTH,
                    ),
                  ),

                  Positioned.fill(
                    child: GestureDetector(
                      onPanUpdate: (details) {
                        setState(() {
                          RenderBox renderBox =
                              context.findRenderObject() as RenderBox;
                          points.add(
                            DrawingPoints(
                              points: renderBox.globalToLocal(
                                details.globalPosition,
                              ),
                              paint:
                                  Paint()
                                    ..strokeCap = strokeCap
                                    ..isAntiAlias = true
                                    ..color = selectedColor.withValues(
                                      alpha: opacity,
                                    )
                                    ..strokeWidth = strokeWidth,
                            ),
                          );
                        });
                      },
                      onPanStart: (details) {
                        setState(() {
                          RenderBox renderBox =
                              context.findRenderObject() as RenderBox;
                          points.add(
                            DrawingPoints(
                              points: renderBox.globalToLocal(
                                details.globalPosition,
                              ),
                              paint:
                                  Paint()
                                    ..strokeCap = strokeCap
                                    ..isAntiAlias = true
                                    ..color = selectedColor.withValues(
                                      alpha: opacity,
                                    )
                                    ..strokeWidth = strokeWidth,
                            ),
                          );
                        });
                      },
                      onPanEnd: (details) {
                        setState(() {
                          points.add(null);
                        });
                      },
                      child: CustomPaint(
                        size: Size.infinite,
                        painter: DrawingPainter(pointsList: points),
                      ),
                    ),
                  ),
                ],
              ),
    );
  }

  getColorList() {
    List<Widget> listWidget = [];
    for (Color color in colors) {
      listWidget.add(colorCircle(color));
    }
    Widget colorPicker = GestureDetector(
      onTap: () {
        showDialog(
          context: context,
          builder:
              (context) => AlertDialog(
                title: const Text(
                  '색상 선택',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 23),
                ),
                content: SingleChildScrollView(
                  child: ColorPicker(
                    pickerColor: pickerColor,
                    onColorChanged: (color) {
                      pickerColor = color;
                    },
                    labelTypes: [ColorLabelType.rgb, ColorLabelType.hex],
                    pickerAreaHeightPercent: 0.8,
                  ),
                ),
                actions: <Widget>[
                  TextButton(
                    child: Text(
                      '저장',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: Colors.black,
                      ),
                    ),
                    onPressed: () {
                      setState(() => selectedColor = pickerColor);
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              ),
        );
      },
      child: ClipOval(
        child: Container(
          padding: const EdgeInsets.only(bottom: 16.0),
          height: 36,
          width: 36,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.red, Colors.green, Colors.blue],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
    );
    listWidget.add(colorPicker);
    return listWidget;
  }

  Widget colorCircle(Color color) {
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedColor = color;
        });
      },
      child: ClipOval(
        child: Container(
          padding: const EdgeInsets.only(bottom: 16.0),
          height: 36,
          width: 36,
          color: color,
        ),
      ),
    );
  }
}

class DrawingPainter extends CustomPainter {
  DrawingPainter({required this.pointsList});
  List<DrawingPoints?> pointsList;
  List<Offset> offsetPoints = [];
  @override
  void paint(Canvas canvas, Size size) {
    for (int i = 0; i < pointsList.length - 1; i++) {
      if (pointsList[i] != null && pointsList[i + 1] != null) {
        canvas.drawLine(
          pointsList[i]!.points,
          pointsList[i + 1]!.points,
          pointsList[i]!.paint,
        );
      } else if (pointsList[i] != null && pointsList[i + 1] == null) {
        offsetPoints.clear();
        offsetPoints.add(pointsList[i]!.points);
        offsetPoints.add(
          Offset(
            pointsList[i]!.points.dx + 0.1,
            pointsList[i]!.points.dy + 0.1,
          ),
        );
        canvas.drawPoints(PointMode.points, offsetPoints, pointsList[i]!.paint);
      }
    }
  }

  @override
  bool shouldRepaint(DrawingPainter oldDelegate) => true;
}

class DrawingPoints {
  final Paint paint;
  final Offset points;
  DrawingPoints({required this.points, required this.paint});
}

enum SelectedMode { StrokeWidth, Opacity, Color }
