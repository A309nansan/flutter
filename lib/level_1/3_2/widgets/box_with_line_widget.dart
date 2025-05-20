import 'package:flutter/material.dart';
import 'package:nansan_flutter/modules/drag_drop2/controllers/draggable2_controller.dart';
import 'package:nansan_flutter/modules/drag_drop2/models/draggable2_drop_zone.dart';
import 'package:nansan_flutter/modules/drag_drop2/models/draggable2_image_card.dart';
import 'package:nansan_flutter/modules/drag_drop2/widgets/draggable2_drop_zone_widget.dart';

class BoxWithLineWidget extends StatefulWidget {
  final void Function(int selectedValue)? onSelected;
  final double screenWidth;
  final double screenHeight;
  final List data;
  final Draggable2DropZone leftZone;
  final Draggable2DropZone rightZone;
  final DragDrop2Controller controller;

  const BoxWithLineWidget({
    super.key,
    required this.screenWidth,
    required this.screenHeight,
    required this.data,
    this.onSelected,
    required this.leftZone,
    required this.rightZone,
    required this.controller
  });

  @override
  State<BoxWithLineWidget> createState() => _BoxWithLineWidgetState();
}



class _BoxWithLineWidgetState extends State<BoxWithLineWidget> {
  int? _selectedIndex; // 선택된 인덱스 저장

  //드래그 앤 드랍2 관련 로직
  void _resetState(Draggable2DropZone zone) {
    setState(() {
      widget.controller.resetState(zone.id);
    });
  }

  void _onCardRemoved(Draggable2DropZone zone, Draggable2ImageCard card) {
    setState(() {
      widget.controller.removeCardFromZone(zone, card);
    });
  }

  void _onCardAdded(Draggable2DropZone zone) {
    setState(() {
      widget.controller.addCardToZone(zone);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: widget.screenWidth * 0.3,
              height: widget.screenHeight * 0.15,
              decoration: BoxDecoration(
                border: Border.all(width: 2, color: Colors.lightBlue),
                borderRadius: BorderRadius.circular(10),
              ),
                child: SizedBox(
                  width: widget.screenWidth * 0.3,
                  height: widget.screenWidth * 0.15,
                  child: Draggable2DropzoneWidget(
                    zone: widget.leftZone,
                    controller: widget.controller,
                    onReset: _resetState,
                    onCardRemoved: _onCardRemoved,
                    onCardAdded: _onCardAdded,
                    width: widget.screenWidth * 0.3,
                    height: widget.screenWidth * 0.15,
                    cardSize: widget.screenWidth * 0.05,
                  ),
                )
            ),
            SizedBox(width: widget.screenWidth * 0.1),
            Container(
              width: widget.screenWidth * 0.3,
              height: widget.screenHeight * 0.15,
              decoration: BoxDecoration(
                border: Border.all(width: 2, color: Colors.lightBlue),
                borderRadius: BorderRadius.circular(10),
              ),
                child: SizedBox(
                  width: widget.screenWidth * 0.3,
                  height: widget.screenWidth * 0.15,
                  child: Draggable2DropzoneWidget(
                    zone: widget.rightZone,
                    controller: widget.controller,
                    onReset: _resetState,
                    onCardRemoved: _onCardRemoved,
                    onCardAdded: _onCardAdded,
                    width: widget.screenWidth * 0.3,
                    height: widget.screenWidth * 0.15,
                    cardSize: widget.screenWidth * 0.05,
                  ),
                )
            ),
          ],
        ),
        SizedBox(
          width: widget.screenWidth * 0.7,
          height: widget.screenHeight * 0.04,
          child: Stack(
            children: [
              Positioned(
                left: widget.screenWidth * 0.15,
                top: 0,
                bottom: 0,
                child: Container(
                  width: widget.screenHeight * 0.002,
                  color: Colors.red,
                ),
              ),
              Positioned(
                right: widget.screenWidth * 0.15,
                top: 0,
                bottom: 0,
                child: Container(
                  width: widget.screenHeight * 0.002,
                  color: Colors.red,
                ),
              ),
              Positioned(
                right: 0,
                top: widget.screenHeight * 0.02,
                child: Container(
                  width: widget.screenWidth * 0.7,
                  height: widget.screenHeight * 0.002,
                  color: Colors.red,
                ),
              ),
              Positioned(
                left: 0,
                top: widget.screenHeight * 0.02 - 4,
                child: Transform.rotate(
                  angle: -3.14 / 4,
                  child: Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      border: Border(
                        top: BorderSide(width: 2, color: Colors.red),
                        left: BorderSide(width: 2, color: Colors.red),
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                right: 0,
                top: widget.screenHeight * 0.02 - 4,
                child: Transform.rotate(
                  angle: 3.14 / 4,
                  child: Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      border: Border(
                        top: BorderSide(width: 2, color: Colors.red),
                        right: BorderSide(width: 2, color: Colors.red),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: () {
                setState(() {
                  _selectedIndex = 0;
                });
                if (widget.onSelected != null) {
                  widget.onSelected!(widget.data[0]);
                }
              },
              child: Container(
                width: widget.screenWidth * 0.3,
                height: widget.screenHeight * 0.1,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.lightBlue),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Text(
                      '${widget.data[0]}',
                      style: TextStyle(fontSize: widget.screenHeight * 0.06),
                    ),
                    if (_selectedIndex == 0) Icon(Icons.circle_outlined, size: widget.screenWidth * 0.15, color: Colors.lightBlue,)
                  ],
                ),
              ),
            ),
            SizedBox(width: widget.screenWidth * 0.1),
            GestureDetector(
              onTap: () {
                setState(() {
                  _selectedIndex = 1;
                });
                if (widget.onSelected != null) {
                  widget.onSelected!(widget.data[1]);
                }
                // setState()로 상태 변경 가능
              },
              child: Container(
                alignment: Alignment.center,
                width: widget.screenWidth * 0.3,
                height: widget.screenHeight * 0.1,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.lightBlue),
                  borderRadius: BorderRadius.circular(10),
                ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Text(
                        '${widget.data[1]}',
                        style: TextStyle(fontSize: widget.screenHeight * 0.06),
                      ),
                      if (_selectedIndex == 1) Icon(Icons.circle_outlined, size: widget.screenWidth * 0.15, color: Colors.lightBlue,)
                    ],
                  ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
