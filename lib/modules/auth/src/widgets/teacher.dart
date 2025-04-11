import 'package:flutter/material.dart';

class Teacher extends StatelessWidget {
  final String teacherCode;
  final VoidCallback onRemove;
  final List<Map<String, String>> teacherList = const [
    {"code": "111", "name": "김성조 선생님"},
    {"code": "222", "name": "오지원 선생님"},
    {"code": "333", "name": "전성호 선생님"},
    {"code": "444", "name": "최지은 선생님"},
  ];

  const Teacher({super.key, required this.teacherCode, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    final teacher = teacherList.firstWhere(
          (teacher) => teacher['code'] == teacherCode,
      orElse: () => {"name": "알 수 없는 선생님"},
    );
    return Container(
      margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
      padding: EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade400, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(30),
            blurRadius: 5,
            spreadRadius: 1,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SizedBox(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  teacher['name']!,
                  style: TextStyle(
                    fontSize: MediaQuery.of(context).size.width * 0.023,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  "#$teacherCode",
                  style: TextStyle(
                    fontSize: MediaQuery.of(context).size.width * 0.018,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(Icons.remove_circle, color: Colors.red),
            onPressed: onRemove,
          ),
        ],
      ),
    );
  }
}