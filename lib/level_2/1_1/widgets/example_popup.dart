import 'package:flutter/material.dart';

class ExamplePopup extends StatelessWidget {
  final Animation<double> scaleAnimation;
  final VoidCallback onClose;

  const ExamplePopup({
    super.key,
    required this.scaleAnimation,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ScaleTransition(
        scale: scaleAnimation,
        alignment: Alignment.center,
        child: Container(
          width: MediaQuery.of(context).size.width * 0.8,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: const [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 10,
                offset: Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "💡 문제 예시",
                style: TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 15),
              SizedBox(
                height: 450,
                child: Image.asset("assets/images/level2_main_sample.png"),
              ),
              const SizedBox(height: 20),
              SizedBox(
                height: 55,
                width: 150,
                child: ElevatedButton(
                  onPressed: onClose,   // 팝업 닫기
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFFFAE1),
                    foregroundColor: const Color.fromARGB(255, 249, 241, 196),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: EdgeInsets.zero,
                    minimumSize: Size.zero,
                    elevation: 3,
                  ),
                  child: const Text(
                    "닫기",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}