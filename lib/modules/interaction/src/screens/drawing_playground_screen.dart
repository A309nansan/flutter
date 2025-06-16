import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:scribble/scribble.dart';
import 'package:value_notifier_tools/value_notifier_tools.dart';
import '../../../../shared/widgets/appbar_widget.dart';
import '../models/placed_image.dart';
import '../widgets/background_selector.dart';
import '../widgets/color_button.dart';
import '../widgets/draw_popup.dart';
import '../widgets/editable_image.dart';
import '../widgets/grid_image.dart';

class DrawingPlaygroundScreen extends StatefulWidget {
  const DrawingPlaygroundScreen({super.key});

  @override
  DrawingPlaygroundScreenState createState() => DrawingPlaygroundScreenState();
}

class DrawingPlaygroundScreenState extends State<DrawingPlaygroundScreen> with TickerProviderStateMixin {
  late ScribbleNotifier notifier;
  List<ui.Image> drawnImages = [];
  List<ui.Image> assetImages = [];
  List<PlacedImage> placedImages = [];

  late TabController _tabController;
  int selectedBackgroundIndex = 0;
  int currentTabIndex = 0;

  final List<String> backgroundPaths = [
    "assets/images/freelayout_background/farm.png",
    "assets/images/freelayout_background/ocean.png",
  ];

  @override
  void initState() {
    super.initState();
    notifier = ScribbleNotifier();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      setState(() {
        currentTabIndex = _tabController.index;
      });
    });
    // 토끼 asset 이미지들 로딩
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final paths = [
        "assets/images/freelayout_assets/rabbit1.png",
        "assets/images/freelayout_assets/rabbit2.png",
        "assets/images/freelayout_assets/rabbit3.png",
        "assets/images/freelayout_assets/rabbit4.png",
        "assets/images/freelayout_assets/rabbit5.png",
        "assets/images/freelayout_assets/rabbit6.png",
        "assets/images/freelayout_assets/rabbit7.png",
      ];
      for (final path in paths) {
        final image = await loadAssetAsUiImage(path);
        setState(() {
          assetImages.add(image);
        });
      }
    });
  }

  Future<ui.Image> loadAssetAsUiImage(String path) async {
    final data = await DefaultAssetBundle.of(context).load(path);
    final list = Uint8List.view(data.buffer);
    final codec = await ui.instantiateImageCodec(list);
    final frame = await codec.getNextFrame();
    return frame.image;
  }

  Future<ui.Image> byteDataToUiImage(ByteData byteData) async {
    final uint8list = byteData.buffer
        .asUint8List(byteData.offsetInBytes, byteData.lengthInBytes);
    final codec = await ui.instantiateImageCodec(uint8list);
    final frame = await codec.getNextFrame();
    return frame.image;
  }

  @override
  void dispose() {
    _tabController.dispose();
    notifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    final GlobalKey stackKey = GlobalKey();

    return Scaffold(
      appBar: AppbarWidget(
        title: Text(
          "나만의 그림판",
          style: TextStyle(
              fontSize: screenWidth * 0.02,
              fontWeight: FontWeight.bold
          ),
        ),
        isCenter: true,
        leading: IconButton(
          icon: Icon(Icons.chevron_left, size: screenWidth * 0.05),
          onPressed: () => Modular.to.pop(),
        ),
      ),
      floatingActionButton: currentTabIndex == 0 ?
      FloatingActionButton(
        onPressed: () => showDrawingPopup(
            context: context,
            notifier: notifier,
            byteDataToUiImage: byteDataToUiImage,
            onImageCreated: (image) {
              setState(() {
                drawnImages.add(image);
              });
            },
            strokeToolbar: _buildStrokeToolbar(context),
            eraserButton: _buildEraserButton(context)
        ),
        backgroundColor: Color(0xFFFFFAE1),
        child: Icon(Icons.brush, size: 30),
      ) : null,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          SizedBox(
            key: stackKey,
            height: screenHeight * 0.5,
            child: DragTarget<ui.Image>(
              onWillAcceptWithDetails: (_) => true,
              onAcceptWithDetails: (details) {
                final box = stackKey.currentContext!.findRenderObject() as RenderBox;
                final local = box.globalToLocal(details.offset);

                final imageSize = 100.0;
                final adjusted = local - Offset(imageSize / 2, imageSize / 2);

                setState(() {
                  placedImages.add(PlacedImage(image: details.data, position: adjusted));
                });
              },
              builder: (context, _, __) => Stack(
                children: [
                  Positioned.fill(
                      child: Image.asset(
                        backgroundPaths[selectedBackgroundIndex],
                        fit: BoxFit.cover,
                      )
                  ),
                  ...placedImages.map((e) => EditableImage(
                    placedImage: e,
                    onDelete: () {
                      setState(() {
                        placedImages.remove(e);
                      });
                    },
                  ))
                ],
              ),
            ),
          ),
          Expanded(
            child: Column(
              children: [
                TabBar(
                  controller: _tabController,
                  labelColor: Colors.black,
                  unselectedLabelColor: Colors.grey,
                  // Color(0xFFFFFAE1)
                  indicatorColor: Color(0xFF9C6A17),
                  indicatorWeight: 3,
                  indicatorSize: TabBarIndicatorSize.tab,
                  labelStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  unselectedLabelStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  tabs: const [
                    Tab(text: "내가 그린 그림"),
                    Tab(text: "기본 그림"),
                    Tab(text: "배경"),
                  ],
                ),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      GridImage(
                        images: drawnImages,
                        isFromDrawn: true,
                        onDelete: (index) {
                          setState(() {
                            drawnImages.removeAt(index);
                          });
                        },
                      ),
                      GridImage(
                          images: assetImages,
                          isFromDrawn: false
                      ),
                      BackgroundSelector(
                        backgroundPaths: backgroundPaths,
                        selectedIndex: selectedBackgroundIndex,
                        onBackgroundSelected: (index) {
                          setState(() {
                            selectedBackgroundIndex = index;
                          });
                        },
                      ),
                    ],

                  ),
                ),
              ],
            ),
          ),

        ],
      ),
    );
  }

  Widget _buildColorToolbar(BuildContext context) {
    return Row(
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

  Widget _buildColorButton(BuildContext context, {required Color color}) {
    return ValueListenableBuilder(
      valueListenable: notifier.select(
            (value) => value is Drawing && value.selectedColor == color.toARGB32(),
      ),
      builder: (context, value, _) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
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
      builder: (context, value, _) => ColorButton(
        color: Colors.transparent,
        outlineColor: Colors.black,
        isActive: value,
        onPressed: () => notifier.setEraser(),
        child: const Icon(Icons.cleaning_services, size: 28),
      ),
    );
  }

  Widget _buildStrokeToolbar(BuildContext context) {
    return ValueListenableBuilder<ScribbleState>(
      valueListenable: notifier,
      builder: (context, state, _) => Row(
        children: [
          for (final w in notifier.widths)
            _buildStrokeButton(context, strokeWidth: w, state: state),
        ],
      ),
    );
  }

  Widget _buildStrokeButton(BuildContext context,
      {required double strokeWidth, required ScribbleState state}) {
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
              borderRadius: BorderRadius.circular(50),
            ),
          ),
        ),
      ),
    );
  }
}