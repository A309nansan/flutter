import 'package:flutter/material.dart';

class ExampleWidget113 extends StatelessWidget {
  const ExampleWidget113({
    super.key,
    required this.exampleData,
    required this.width,
    required this.height,
  });

  final String exampleData;
  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width * 0.85,
      height: height * 0.18,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.amber, width: 2),
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
                  style: TextStyle(
                    fontSize: width * 0.02,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: height * 0.01),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                alignment: Alignment.center,
                width: width * 0.28,
                height: height * 0.12,
                decoration: BoxDecoration(
                  border: Border.all(width: 2, color: Colors.lightBlue),
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                ),
                child: Image.network(exampleData),
                // child: Image.asset('assets/images/number/$fruit/2')
              ),
              SizedBox(width: width * 0.1),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black, width: 1),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Container(
                          alignment: Alignment.center,
                          width: width * 0.08,
                          height: width * 0.1,
                          decoration: BoxDecoration(
                            border: Border.all(width: 1, color: Colors.black),
                          ),
                          child: Text(
                            'O',
                            style: TextStyle(
                              fontSize: width * 0.05,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Container(
                          alignment: Alignment.center,
                          width: width * 0.08,
                          height: width * 0.1,
                          decoration: BoxDecoration(
                            border: Border.all(width: 1, color: Colors.black),
                          ),
                          child: Text(
                            'O',
                            style: TextStyle(
                              fontSize: width * 0.05,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Container(
                          width: width * 0.08,
                          height: width * 0.1,
                          decoration: BoxDecoration(
                            border: Border.all(width: 1, color: Colors.black),
                          ),
                        ),
                        Container(
                          width: width * 0.08,
                          height: width * 0.1,
                          decoration: BoxDecoration(
                            border: Border.all(width: 1, color: Colors.black),
                          ),
                        ),
                        Container(
                          width: width * 0.08,
                          height: width * 0.1,
                          decoration: BoxDecoration(
                            border: Border.all(width: 1, color: Colors.black),
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Container(
                          width: width * 0.08,
                          height: width * 0.1,
                          decoration: BoxDecoration(
                            border: Border.all(width: 1, color: Colors.black),
                          ),
                        ),
                        Container(
                          width: width * 0.08,
                          height: width * 0.1,
                          decoration: BoxDecoration(
                            border: Border.all(width: 1, color: Colors.black),
                          ),
                        ),
                        Container(
                          width: width * 0.08,
                          height: width * 0.1,
                          decoration: BoxDecoration(
                            border: Border.all(width: 1, color: Colors.black),
                          ),
                        ),
                        Container(
                          width: width * 0.08,
                          height: width * 0.1,
                          decoration: BoxDecoration(
                            border: Border.all(width: 1, color: Colors.black),
                          ),
                        ),
                        Container(
                          width: width * 0.08,
                          height: width * 0.1,
                          decoration: BoxDecoration(
                            border: Border.all(width: 1, color: Colors.black),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
