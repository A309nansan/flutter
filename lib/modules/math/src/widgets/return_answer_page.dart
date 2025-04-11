// return_problem_page.dart
import 'package:flutter/material.dart';
import '../models/m_problem_metadata.dart';
import '../services/m_response.dart';
import 'm_display_answer/m_answer_addsubmult.dart';
import 'm_display_answer/m_answer_div.dart';
import 'm_display_answer/m_answer_div_remainder.dart';
import 'm_display_answer/m_answer_singleline.dart';


Widget buildAnswerWidget({
  required MProblemMetadata mathData,
  required MResponse userResponse,
  required List<List<List<String>>> answer,
  required bool isShowingUserInput,
  required Function() onCleared,


}) {
  final isOneDigit = mathData.type == "SingleLine";
  final isAddSub = mathData.type == "AddSub";
  final isMultiplication = mathData.type == "Multiplication";
  final isDivision = mathData.type == "Division";
  final isDivisionRemainder = mathData.type == "DivisionRemainder";

  if (isOneDigit) {
    return MAnswerSingleline(
      mathData: mathData,
      userResponse: userResponse,
      answer: answer,
      isShowingUserInput: isShowingUserInput,
      onCleared: onCleared
    );
  }
  if (isAddSub || isMultiplication) {
    return MAnswerAddSubMult(
      mathData: mathData,
      userResponse: userResponse,
      answer: answer,
      isShowingUserInput: isShowingUserInput,
        onCleared: onCleared
    );
  }
  if (isDivision) {
    return MAnswerDiv(
      mathData: mathData,
      userResponse: userResponse,
      answer: answer,
      isShowingUserInput: isShowingUserInput,
    );
  }
  else {
    return MAnswerDivRemainder(
      mathData: mathData,
      userResponse: userResponse,
      answer: answer,
      isShowingUserInput: isShowingUserInput,
    );
  }
}


