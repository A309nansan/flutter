class MProblemMetadata {
  final int index;
  final int num1;
  final int num2;
  final String operator;
  final List<int> matrixVolume;
  final String type;


  MProblemMetadata({
    required this.index,
    required this.num1,
    required this.num2,
    required this.operator,
    required this.matrixVolume,
    required this.type,
  });

  @override
  String toString() {
    return 'MathData(index: $index, num1: $num1, num2: $num2, matrixVolume: $matrixVolume)';
  }
}

