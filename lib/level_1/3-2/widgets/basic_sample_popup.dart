import 'package:flutter/material.dart';

class BasicSamplePopup extends StatelessWidget {
  final Animation<double> scaleAnimation;
  final VoidCallback onClose;
  final String desc;

  const BasicSamplePopup({
    super.key,
    required this.scaleAnimation,
    required this.onClose,
    required this.desc
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
              Text(
                "문제 예시",
                style: TextStyle(
                  fontSize: MediaQuery.of(context).size.width * 0.035,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 30),
              Text(
                desc,
                style: TextStyle(
                  fontSize: MediaQuery.of(context).size.width * 0.025,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 5),
              SizedBox(
                height: 450,
                child: Image.asset("assets/images/level1_3_2_basic_sample.png"),
              ),
              const SizedBox(height: 20),
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.04,
                width: MediaQuery.of(context).size.width * 0.2,
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
                  child: Text(
                    "닫기",
                    style: TextStyle(
                      fontSize: MediaQuery.of(context).size.width * 0.023,
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