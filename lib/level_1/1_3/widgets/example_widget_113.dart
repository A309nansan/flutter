import 'package:flutter/material.dart';

class ExampleWidget113 extends StatelessWidget {
  const ExampleWidget113({super.key, required this.exampleData});

  final String exampleData;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 600,
      height: 200,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.amber, width: 3),
        borderRadius: BorderRadius.all(Radius.circular(10)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                decoration: BoxDecoration(color: Colors.amber),
                child: Text(
                  '  <보기>  ',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                alignment: Alignment.center,
                width: 200,
                height: 150,
                decoration: BoxDecoration(
                  border: Border.all(width: 2, color: Colors.black),
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                ),
                child: Image.network(exampleData),
              ),
              SizedBox(width: 30),
              Column(
                children: [
                  Row(
                    children: [
                      Container(
                        alignment: Alignment.center,
                        width: 50,
                        height: 60,
                        decoration: BoxDecoration(
                          border: Border.all(width: 1, color: Colors.black),
                        ),
                        child: Text(
                          'O',
                          style: TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Container(
                        alignment: Alignment.center,
                        width: 50,
                        height: 60,
                        decoration: BoxDecoration(
                          border: Border.all(width: 1, color: Colors.black),
                        ),
                        child: Text(
                          'O',
                          style: TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Container(
                        width: 50,
                        height: 60,
                        decoration: BoxDecoration(
                          border: Border.all(width: 1, color: Colors.black),
                        ),
                      ),
                      Container(
                        width: 50,
                        height: 60,
                        decoration: BoxDecoration(
                          border: Border.all(width: 1, color: Colors.black),
                        ),
                      ),
                      Container(
                        width: 50,
                        height: 60,
                        decoration: BoxDecoration(
                          border: Border.all(width: 1, color: Colors.black),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Container(
                        width: 50,
                        height: 60,
                        decoration: BoxDecoration(
                          border: Border.all(width: 1, color: Colors.black),
                        ),
                      ),
                      Container(
                        width: 50,
                        height: 60,
                        decoration: BoxDecoration(
                          border: Border.all(width: 1, color: Colors.black),
                        ),
                      ),
                      Container(
                        width: 50,
                        height: 60,
                        decoration: BoxDecoration(
                          border: Border.all(width: 1, color: Colors.black),
                        ),
                      ),
                      Container(
                        width: 50,
                        height: 60,
                        decoration: BoxDecoration(
                          border: Border.all(width: 1, color: Colors.black),
                        ),
                      ),
                      Container(
                        width: 50,
                        height: 60,
                        decoration: BoxDecoration(
                          border: Border.all(width: 1, color: Colors.black),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
