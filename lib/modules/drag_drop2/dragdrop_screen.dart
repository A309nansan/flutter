import 'package:flutter/material.dart';

// --- 데이터 모델 ---
class ImageCardData {
  final String id;
  final String imageUrl;

  ImageCardData({required this.id, required this.imageUrl});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ImageCardData &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}

// --- 드롭 영역 모델 ---
class DropZoneData {
  final String id;
  final List<ImageCardData> cards = [];

  DropZoneData({required this.id});
}

// --- 메인 화면 ---
class DragDropDemoScreen extends StatefulWidget {
  const DragDropDemoScreen({super.key});

  @override
  State<DragDropDemoScreen> createState() => _DragDropDemoScreenState();
}

class _DragDropDemoScreenState extends State<DragDropDemoScreen> {
  // 원본 카드
  final ImageCardData sourceCard = ImageCardData(
    id: 'source_card',
    imageUrl: 'https://picsum.photos/seed/1/100',
  );

  // 드롭 영역 목록
  final List<DropZoneData> _dropZones = [];
  int _dropZoneCounter = 0;
  int _cardCounter = 0;

  // 카드 및 드롭 영역 크기
  final double cardWidth = 80.0;
  final double cardHeight = 80.0;
  final double dropZoneWidth = 470.0;
  final double dropZoneHeight = 200.0; // 고정 높이
  final double rowGap = 12.0; // Row 간격

  // 최대 카드 개수x
  final int maxCardsPerZone = 10;

  @override
  void initState() {
    super.initState();
    // 초기 드롭 영역 하나 생성
    _addNewDropZone();
  }

  // 새 드롭 영역 추가
  void _addNewDropZone() {
    setState(() {
      _dropZones.add(DropZoneData(id: 'zone_${_dropZoneCounter++}'));
    });
  }

  // 상태 초기화
  void _resetState() {
    setState(() {
      for (var zone in _dropZones) {
        zone.cards.clear();
      }
    });
  }

  // 카드 시각적 요소
  Widget _buildCardVisual(String imageUrl, {double opacity = 1.0}) {
    return Opacity(
      opacity: opacity,
      child: Container(
        width: cardWidth,
        height: cardHeight,
        margin: const EdgeInsets.symmetric(horizontal: 4.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2 * opacity),
              spreadRadius: 1,
              blurRadius: 3,
              offset: const Offset(0, 2),
            ),
          ],
          image: DecorationImage(
            image: NetworkImage(imageUrl),
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }

  // 카드 리스트를 5개씩 분할
  List<List<ImageCardData>> _chunkCards(
    List<ImageCardData> cards,
    int chunkSize,
  ) {
    List<List<ImageCardData>> chunks = [];
    for (int i = 0; i < cards.length; i += chunkSize) {
      int end = (i + chunkSize < cards.length) ? i + chunkSize : cards.length;
      chunks.add(cards.sublist(i, end));
    }
    return chunks;
  }

  // 드롭 영역 위젯
  Widget _buildDropZone(DropZoneData zone) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            '드롭 영역 ${zone.id.split('_').last} | 카드 개수: ${zone.cards.length}/$maxCardsPerZone',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          DragTarget<ImageCardData>(
            builder: (context, candidateData, rejectedData) {
              final isFull = zone.cards.length >= maxCardsPerZone;
              return Container(
                width: dropZoneWidth,
                height: dropZoneHeight,
                decoration: BoxDecoration(
                  color:
                      isFull
                          ? Colors.red[100]
                          : candidateData.isNotEmpty
                          ? Colors.lightBlueAccent.withOpacity(0.3)
                          : Colors.grey[200],
                  border: Border.all(
                    color:
                        isFull
                            ? Colors.red
                            : candidateData.isNotEmpty
                            ? Colors.blue
                            : Colors.grey,
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child:
                    zone.cards.isEmpty
                        ? Center(
                          child: Text(
                            isFull
                                ? '최대 개수 도달 (더 이상 추가 불가)'
                                : '여기에 카드 놓기 (최대 10개)',
                            style: TextStyle(
                              color: isFull ? Colors.red : Colors.black54,
                              fontSize: 16,
                            ),
                          ),
                        )
                        : Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: SingleChildScrollView(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                for (
                                  int i = 0;
                                  i < _chunkCards(zone.cards, 5).length;
                                  i++
                                ) ...[
                                  Row(
                                    children:
                                        _chunkCards(zone.cards, 5)[i]
                                            .map(
                                              (card) => GestureDetector(
                                                onTap: () {
                                                  setState(() {
                                                    zone.cards.remove(card);
                                                  });
                                                },
                                                child: _buildCardVisual(
                                                  card.imageUrl,
                                                ),
                                              ),
                                            )
                                            .toList(),
                                  ),

                                  if (i < _chunkCards(zone.cards, 5).length - 1)
                                    SizedBox(height: rowGap), // Row 간 간격
                                ],
                              ],
                            ),
                          ),
                        ),
              );
            },
            onWillAcceptWithDetails: (data) {
              // 최대 카드 개수 체크
              return zone.cards.length < maxCardsPerZone;
            },
            onAcceptWithDetails: (data) {
              setState(() {
                // 원본 카드면 새 카드 추가
                if (data.data.id == sourceCard.id) {
                  final newCard = ImageCardData(
                    id: 'card_${_cardCounter++}',
                    imageUrl: sourceCard.imageUrl,
                  );
                  zone.cards.add(newCard);
                }
              });
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('드래그 앤 드롭 - 카드 추가 & 삭제')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 드래그 원본 카드
            const Text(
              '드래그 할 카드 (원본):',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Draggable<ImageCardData>(
              data: sourceCard,
              feedback: Material(
                elevation: 4.0,
                color: Colors.transparent,
                child: Opacity(
                  opacity: 0.7,
                  child: _buildCardVisual(sourceCard.imageUrl),
                ),
              ),
              childWhenDragging: _buildCardVisual(
                sourceCard.imageUrl,
                opacity: 0.5,
              ),
              child: _buildCardVisual(sourceCard.imageUrl),
            ),
            const SizedBox(height: 20),

            // 드롭 영역들
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [..._dropZones.map((zone) => _buildDropZone(zone))],
                ),
              ),
            ),

            // 버튼 영역
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: _addNewDropZone,
                  child: const Text('드롭 영역 추가'),
                ),
                const SizedBox(width: 20),
                ElevatedButton(
                  onPressed: _resetState,
                  child: const Text('초기화'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
