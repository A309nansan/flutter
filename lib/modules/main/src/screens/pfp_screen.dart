import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nansan_flutter/shared/widgets/appbar_widget.dart';
import 'package:nansan_flutter/shared/widgets/new_header_widget.dart';
import 'package:nansan_flutter/shared/widgets/new_question_text.dart';

enum LayerType { base, layer1, layer2 }

class ProfileLayer {
  final LayerType type;
  final String label;
  final String folderName;
  List<String> assetPaths;
  String? selectedAsset;

  ProfileLayer({
    required this.type,
    required this.label,
    required this.folderName,
    this.assetPaths = const [],
    this.selectedAsset,
  });
}

class ProfilePicPage extends ConsumerStatefulWidget {
  const ProfilePicPage({super.key});

  @override
  ConsumerState createState() => _ProfilePicPageState();
}

class _ProfilePicPageState extends ConsumerState<ProfilePicPage> {
  List<ProfileLayer> layers = [];
  int selectedTabIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadAssets();
  }

  Future<void> _loadAssets() async {
    final manifestContent = await rootBundle.loadString('AssetManifest.json');
    final Map<String, dynamic> manifestMap = json.decode(manifestContent);

    List<ProfileLayer> loadedLayers = [
      ProfileLayer(
        type: LayerType.base,
        label: 'Base',
        folderName: 'base',
      ),
      ProfileLayer(
        type: LayerType.layer1,
        label: 'Layer 1',
        folderName: 'layer1',
      ),
      ProfileLayer(
        type: LayerType.layer2,
        label: 'Layer 2',
        folderName: 'layer2',
      ),
    ];

    for (var layer in loadedLayers) {
      final pathPrefix = 'assets/images/profile/${layer.folderName}/';
      final layerAssets = manifestMap.keys
          .where((key) => key.startsWith(pathPrefix))
          .toList();

      layer.assetPaths = layerAssets;
      if (layer.assetPaths.isNotEmpty) {
        layer.selectedAsset = layer.assetPaths.first;
      }
    }

    setState(() {
      layers = loadedLayers;
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
      body: layers.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            NewQuestionTextWidget(
              questionText: '프로필 사진 변경',
              questionTextSize: screenWidth * 0.03,
            ),
            SizedBox(height: screenHeight * 0.02),

            // === PREVIEW BOX ===
            Container(
              width: 200,
              height: 200,
              color: Colors.grey[300],
              child: Stack(
                alignment: Alignment.center,
                children: layers
                    .where((layer) => layer.selectedAsset != null)
                    .map((layer) => Image.asset(layer.selectedAsset!))
                    .toList(),
              ),
            ),
            const SizedBox(height: 16),

            // === TABS ===
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(layers.length, (index) {
                final isSelected = selectedTabIndex == index;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6.0),
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        selectedTabIndex = index;
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                      isSelected ? Colors.blue : Colors.grey,
                    ),
                    child: Text(layers[index].label),
                  ),
                );
              }),
            ),

            const SizedBox(height: 8),

            // === IMAGE GRID ===
            Expanded(
              child: GridView.count(
                crossAxisCount: 3,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
                children: [
                  // NONE option
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        layers[selectedTabIndex].selectedAsset = null;
                      });
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: layers[selectedTabIndex].selectedAsset == null
                              ? Colors.blue
                              : Colors.transparent,
                          width: 3,
                        ),
                        borderRadius: BorderRadius.circular(8),
                        color: Colors.grey[200],
                      ),
                      child: const Center(
                        child: Text(
                          '없음',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Image options
                  ...layers[selectedTabIndex].assetPaths.map((path) {
                    final isSelected = layers[selectedTabIndex].selectedAsset == path;
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          layers[selectedTabIndex].selectedAsset = path;
                        });
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: isSelected ? Colors.blue : Colors.transparent,
                            width: 3,
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(5),
                          child: Image.asset(
                            path,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
