import 'package:flutter/material.dart';

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0.0,
        toolbarHeight: MediaQuery.of(context).size.width * 0.13,
        leading: IconButton(
          onPressed: () {
            debugPrint("메뉴 클릭했습니다.");
          },
          icon: Icon(Icons.menu, size: 28, color: Colors.white),
          // margin: EdgeInsets.only(left: 10),
        ),
        actions: [
          Padding(
            padding: EdgeInsets.only(right: 15),
            child: InkWell(
              onTap: () {
                debugPrint("프로필 클릭");
              },
              borderRadius: BorderRadius.circular(50),
              child: Container(
                width: 43,
                height: 43,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(50),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha((0.3 * 255).toInt()),
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
