// return_problem_page.dart
import 'package:flutter/material.dart';
import '../models/m_problem_metadata.dart';
import '../services/m_response.dart';
import 'm_display_problem/m_problem_addsub.dart';
import 'm_display_problem/m_problem_div.dart';
import 'm_display_problem/m_problem_div_remainder.dart';
import 'm_display_problem/m_problem_mult.dart';
import 'm_display_problem/m_problem_singleline.dart';

Widget buildProblemWidget({
  required MProblemMetadata mathData,
  required List<List<List<String>>> initialResult,
  required Function(List<List<List<String>>>) onResultUpdated,
  required MResponse userResponse,
  required Function() onCleared,


}) {
  final isOneDigit = mathData.type == "SingleLine";
  final isAddSub = mathData.type == "AddSub";
  final isMultiplication = mathData.type == "Multiplication";
  final isDivision = mathData.type == "Division";
  final isDivisionRemainder = mathData.type == "DivisionRemainder";

  if (isOneDigit) {
    return MProblemSingleline(
      mathData: mathData,
      onResultUpdated: onResultUpdated,
      initialResult: initialResult,
        userResponse: userResponse,
      recognitionAnswerZoneKeys: userResponse.recognitionAnswerZoneKeys,
      onCleared: onCleared
    );
  }
  if (isAddSub) {
    return MProblemAddSub(
      mathData: mathData,
      onResultUpdated: onResultUpdated,
      initialResult: initialResult,
      userResponse: userResponse,
      recognitionCarryZoneKeys: userResponse.recognitionCarryZoneKeys,
      recognitionProgressZoneKeys: userResponse.recognitionProgressZoneKeys,
      recognitionAnswerZoneKeys: userResponse.recognitionAnswerZoneKeys,
        onCleared: onCleared,
    );
  }
  if (isMultiplication) {
    return MProblemMult(
      mathData: mathData,
      onResultUpdated: onResultUpdated,
      initialResult: initialResult,
      userResponse: userResponse,
      recognitionCarryZoneKeys: userResponse.recognitionCarryZoneKeys,
      recognitionProgressZoneKeys: userResponse.recognitionProgressZoneKeys,
      recognitionAnswerZoneKeys: userResponse.recognitionAnswerZoneKeys,
        onCleared: onCleared,
    );
  }
  if (isDivision) {
    return MProblemDiv(
      mathData: mathData,
      onResultUpdated: onResultUpdated,
      initialResult: initialResult,
      userResponse: userResponse,
      recognitionCarryZoneKeys: userResponse.recognitionCarryZoneKeys,
      recognitionProgressZoneKeys: userResponse.recognitionProgressZoneKeys,
      recognitionAnswerZoneKeys: userResponse.recognitionAnswerZoneKeys,
        onCleared: onCleared,
    );
  } else {
    return MProblemDivRemainder(
      mathData: mathData,
      onResultUpdated: onResultUpdated,
      initialResult: initialResult,
      userResponse: userResponse,
      recognitionCarryZoneKeys: userResponse.recognitionCarryZoneKeys,
      recognitionProgressZoneKeys: userResponse.recognitionProgressZoneKeys,
      recognitionAnswerZoneKeys: userResponse.recognitionAnswerZoneKeys,
        onCleared: onCleared,
    );
  }
}
