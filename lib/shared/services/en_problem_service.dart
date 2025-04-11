class EnProblemService {
  String getLevelPath(String problemCode) {
    final levelMatch = RegExp(r'lv(\d+)').firstMatch(problemCode);
    if (levelMatch == null) {
      throw FormatException('Invalid problem code: $problemCode');
    }

    final levelNumber = levelMatch.group(1); // 예: "1"
    return "/level$levelNumber/$problemCode";
  }
}