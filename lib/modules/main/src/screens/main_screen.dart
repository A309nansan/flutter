import 'package:flutter/material.dart';

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0.0,
        toolbarHeight: 80,
        leading: IconButton(
          onPressed: () {
            debugPrint("메뉴 클릭했습니다.");
          },
          icon: Icon(Icons.menu, size: 38, color: Colors.white),
          padding: EdgeInsets.only(left: 20),
        ),
        actions: [
          Padding(
            padding: EdgeInsets.only(right: 15),
            child: GestureDetector(
              onTap: () {
                debugPrint("프로필 클릭");
              },
              child: Container(
                width: 55,
                height: 55,
                margin: EdgeInsets.only(right: 15),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(50),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(
                        (0.3 * 255).toInt(),
                      ), // 그림자 색상
                      blurRadius: 1,
                      spreadRadius: 1,
                      offset: Offset(1.5, 1.5),
                    ),
                  ],
                ),
                child: CircleAvatar(
                  backgroundImage: AssetImage("assets/images/icon_img.jpg"),
                ),
              ),
            ),
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [const Text("샘플")],
        ),
      ),
    );
  }
}
