import 'package:flutter/material.dart';

class ExampleContainer extends StatelessWidget {
  const ExampleContainer({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 600,
      height: 300,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.amber, width: 2),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.amber,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(10),
                bottomRight: Radius.circular(10),
              ),
            ),
            child: const Padding(
              padding: EdgeInsets.all(4.0),
              child: Text(' <보기> ', style: TextStyle(fontSize: 18)),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildStaticContainer('1'),
              _buildStaticContainer(''),
              _buildStaticContainer('3'),
              _buildStaticContainer('O'),
              _buildStaticContainer('5'),
            ],
          ),
          const SizedBox(height: 120),
          _buildStaticContainer('4'),
        ],
      ),
    );
  }

  // Helper method to build a static container
  Widget _buildStaticContainer(String text) {
    return Container(
      alignment: Alignment.center,
      width: 100,
      height: 50,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black),
        color: Colors.amber.shade100,
      ),
      child: Text(text, style: const TextStyle(fontSize: 25)),
    );
  }
}
