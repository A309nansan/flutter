Map<int, String> _strMap = {
  101: "한 자릿수끼리의 덧셈 결과를 적어 주세요.",
  102: "한 자릿수끼리의 뺄셈 결과를 적어 주세요.",
  103: "1부터 9까지 숫자 두 개를 더해서 10 이상이 되는 결과를 적어 주세요!",
  104: "10에서 1부터 9까지의 숫자 중 하나를 뺀 결과를 적어 주세요!",
  201: "받아올림 없이 계산되는 두 자릿수와 한 자릿수의 덧셈 결과를 적어 주세요!",
  202: "받아올림 없이 계산되는 두 자릿수와 한 자릿수의 덧셈 결과를 적어 주세요!",
  203: "받아올림 없이 계산되는 두 자릿수 + 두 자릿수 덧셈의 결과를 적어 주세요!",
  204: "받아내림 없이 계산되는 두 자릿수 - 두 자릿수 뺄셈의 결과를 적어 주세요!",
  301: "두 자릿수 숫자와 한 자릿수 숫자를 더했을 때, 받아올림이 생기는 결과를 적어 주세요!",
  302: "두 자릿수 숫자에서 한 자릿수 숫자를 뺄 때, 받아내림이 생기는 결과를 적어 주세요!",
  303: "두 자릿수 숫자끼리 더해서 받아올림이 생기는 결과를 적어 주세요!",
  304: "두 자릿수 숫자에서 두 자릿수 숫자를 뺄 때, 받아내림이 생기는 결과를 적어 주세요!",
  401: "세 자릿수 숫자 두 개를 더했을 때, 받아올림 없이 계산되는 결과를 적어 주세요!",
  402: "세 자릿수 숫자 두 개를 뺄 때, 받아내림 없이 계산되는 결과를 적어 주세요!",
  403: "세 자릿수 숫자 두 개를 더했을 때, 받아올림이 생기는 계산의 결과를 적어 주세요!",
  404: "세 자릿수 숫자 두 개를 뺄 때, 받아내림이 생기는 계산의 결과를 적어 주세요!",
  501: "구구단을 이용해 나눗셈의 정답을 적어 주세요!",
  502: "두 자릿수와 한 자릿수를 곱했을 때, 정답을 적어 주세요!",
  503: "4자리 수 두 개를 더한 결과를 적어 주세요!",
  504: "4자리 수에서 4자리 수를 뺀 결과를 적어 주세요!",
  601: "세 자릿수와 한 자릿수를 곱했을 때, 정답을 적어 주세요!",
  602: "두 자릿수끼리 곱했을 때, 정답을 적어 주세요!",
  603: "",
  604: "",
};


const String _markdown101 = "";
const String _markdown102 = "";
const String _markdown103 = "";
const String _markdown104 = "";
const String _markdown201 = "";
const String _markdown202 = "";
const String _markdown203 = "";
const String _markdown204 = "";


const String _markdown301 = '''
💡**받아올림이란?**
일의 자리끼리 더해서 10 이상이 되면, 일의 자리에 10의 자리 숫자를 **올려 보내는 것** 을 받아올림이라고 해요.
예: 17 + 8 → 일의 자리 7 + 8 = 15 → 5 쓰고 1을 받아올림해서, 1(십의 자리) + 1 = 2 → 결과는 **25**
''';

const String _markdown302 = '''
💡**받아내림이란?**
일의 자리에서 뺄 숫자가 더 클 때, 10의 자리에서 **숫자 하나를 빌려와서 계산** 하는 걸 받아내림이라고 해요.
예: 35 - 9 → 5에서 9를 못 빼니까, 10의 자리 3에서 1을 빌려와서 15 - 9 = 6 → 결과는 **26**
''';

const String _markdown303 = '''
💡**받아올림이란?**
일의 자리끼리 더해서 10 이상이 되면, 일의 자리에 10의 자리 숫자를 **올려 보내는 것** 을 받아올림이라고 해요.
예: 14 + 87 → 4 + 7 = 11 → 1 쓰고 1 올림 → 1 + 8 + 1 = 10 → 0 쓰고 1올림 → 결과는 **101**
''';

const String _markdown304 = '''
💡**받아내림이란?**\n
일의 자리에서 뺄 숫자가 더 클 때, 10의 자리에서 **숫자 하나를 빌려와서 계산** 하는 걸 받아내림이라고 해요.\n
예: 83 - 28 → 3 - 8이 안 되니까, 10의 자리에서 빌려와 13 - 8 = 5 → 7 - 2 = 5 → 결과는 **55**
''';

const String _markdown401 = '''
💡**받아올림이 없다는 뜻이란?**
일의 자리, 십의 자리, 백의 자리를 더할 때 *각 자리에서 10이 넘지 않아* 윗자리로 올림이 생기지 않는다는 뜻이에요.
예: 644 + 213 → 각 자리 더해도 10을 넘지 않음 → **857**
''';

const String _markdown402 = '''
💡**받아내림이 없다는 뜻이란?**
각 자리(일, 십, 백)에서 **윗자리에서 숫자를 빌려올 필요 없이** 바로 뺄 수 있다는 뜻이에요.
예: 826 - 412 → 모든 자리에서 큰 수가 위에 있어 빌림 없이 계산 가능 → **414**
''';

const String _markdown403 = '''
💡**받아올림이란?**

일의 자리끼리 더해서 10 이상이 되면, 일의 자리에 10의 자리 숫자를 **올려 보내는 것** 을 받아올림이라고 해요.

예: 

670 + 437 → 0 + 7 = 7 → 7 + 3 = 10→ 0 쓰고 1올림 →  

6 + 4 + 1 = 11 계속 올림 발생 → **1107**
''';

const String _markdown404 = '''
💡**받아내림이란?**
일의 자리에서 뺄 숫자가 더 클 때, 10의 자리에서 **숫자 하나를 빌려와서 계산** 하는 걸 받아내림이라고 해요.
예: 401 - 179 → 1 - 9 불가 → 0에서 빌릴 수 없어 백의 자리에서 빌려오는 받아내림 → 백의 자리는 4 → 3, 
10의 자리는 0 → 9, 1의 자리는 11 - 9 = 2, 10의 자리는 9 - 7 = 2, 100의 자리는 3 - 1 = 2 → **222**
''';

const String _markdown501 = '''
💡**설명**: 나누는 수에 어떤 수를 곱하면 나누어지는 수가 되는지를 생각해 보세요.
예: 48 ÷ 8 = ? → 8 × 몇 = 48? → 정답: **6**
''';

const String _markdown502 = '''
💡**올림이 생긴다는 뜻?**
일의 자리끼리 곱하거나, 십의 자리에 곱한 결과를 더할 때 **10 이상이 되어 올림이 발생하는 경우**예요.
예: 52 × 8 → 2×8 =16 → 6쓰고 1 올림 → 8 x 5 = 40 + 1 → 4 올리고 1 작성. 4 도 백의 자리에 작성 → **416**
''';

const String _markdown503 = '''
💡**설명** : 네 자릿수끼리의 큰 수 덧셈이에요. 받아올림이 생길 수도 있어요.
예: 8028 + 9414 → 17442
''';

const String _markdown504 = '''
💡**설명**: 큰 수에서 큰 수를 빼는 문제예요. 받아내림이 생길 수 있어요.
예: 4561 - 3971 → 590
''';
const String _markdown601 = "";
const String _markdown602 = "";
const String _markdown603 = "";
const String _markdown604 = "";
Map<int, String> _markdown = {
  101: _markdown101,
  102: _markdown102,
  103: _markdown103,
  104: _markdown104,
  201: _markdown201,
  202: _markdown202,
  203: _markdown203,
  204: _markdown204,
  301: _markdown301,
  302: _markdown302,
  303: _markdown303,
  304: _markdown304,
  401: _markdown401,
  402: _markdown402,
  403: _markdown403,
  404: _markdown404,
  501: _markdown501,
  502: _markdown502,
  503: _markdown503,
  504: _markdown504,
  601: _markdown601,
  602: _markdown602,
  603: _markdown603,
  604: _markdown604,
};
Map<String, String> _errordict = {
  "INCORRECT_OPERATION": "연산기호 착각",
  "INCORRECT_OPERATION_1": "연산기호 착각",
  "INCORRECT_OPERATION_2": "연산기호 착각",
  "INCORRECT_OPERATION_3": "연산기호 착각",
  "INCORRECT_OPERATION_4": "연산기호 착각",
  "INCORRECT_OPERATION_5_1": "연산기호 착각",
  "INCORRECT_OPERATION_5_2": "연산기호 착각",
  "INCORRECT_OPERATION_6_1": "연산기호 착각",
  "INCORRECT_OPERATION_6_2": "연산기호 착각",
  "LARGER_MINUS_SMALLER": "뺄셈순서 오류",
  "ALGORITHM_MIXED_ERROR": "연산섞임 오류",
  "CARRY_ERROR": "받아올림/내림 오류",
  "CARRY_ERROR_1": "받아올림/내림 오류",
  "CARRY_ERROR_2": "받아올림/내림 오류",
  "CARRY_ERROR_3": "받아올림/내림 오류",
  "WRONG_POSITION": "자릿수 오류",
  "CALCULATE_WRONG": "계산 실수",
};

Map<String, String> _errordictSub = {
  "INCORRECT_OPERATION": "덧셈문제를 뺄셈문제로 계산했어요. 이번 차시의 덧셈 편과 뺄셈 편을 복습해보세요!",
  "INCORRECT_OPERATION_1": "덧셈문제를 뺄셈문제로 계산했어요. 이번 차시의 덧셈 편과 뺄셈 편을 복습해보세요!",
  "INCORRECT_OPERATION_2": "덧셈문제를 곱셈문제로 계산했어요. 이번 차시의 덧셈 편과 5과의 곱셈 편을 복습해보세요!",
  "INCORRECT_OPERATION_3": "뺄셈문제를 덧셈문제로 계산했어요. 이번 차시의 덧셈 편과 뺄셈 편을 복습해보세요!",
  "INCORRECT_OPERATION_4": "뺄셈문제를 곱셈문제로 계산했어요. 이번 차시의 뺄셈 편과 5과의 곱셈 편을 복습해보세요!",
  "INCORRECT_OPERATION_5_1": "곱셈 문제를 덧셈 문제로 계산했어요. 5과의 곱셈 문제를 복습해보세요!",
  "INCORRECT_OPERATION_5_2": "곱셈 문제를 덧셈 문제로 계산했어요. 6과의 곱셈 문제를 복습해보세요!",
  "INCORRECT_OPERATION_6_1": "곱셈 문제를 뺄셈 문제로 계산했어요. 5과의 곱셈 문제를 복습해보세요!",
  "INCORRECT_OPERATION_6_2": "곱셈 문제를 뺄셈 문제로 계산했어요. 6과의 곱셈 문제를 복습해보세요!",
  "LARGER_MINUS_SMALLER": "큰 수에서 작은 수를 뺏어요. 3과를 복습해보세요!",
  "ALGORITHM_MIXED_ERROR": "덧셈 문제를 곱셈처럼 2번째 숫자와 모두 더했어요. 이는 주로 곱셈을 공부한 아이들한테 자주 나타나는 현상이에요. 이번 차시의 덧셈 편과 5과의 곱셈 편을 복습해보세요!",
  "CARRY_ERROR": "받아올림이나 받아내림 과정에서 실수했어요.",
  "CARRY_ERROR_1": "받아올림 부분에서 연산 실수를 했어요. 3과의 더하기 부분을 복습해보세요!",
  "CARRY_ERROR_2": "받아올림 부분에서 연산 실수를 했어요. 3과의 빼기 부분을 복습해보세요!",
  "CARRY_ERROR_3": "받아올림 부분에서 연산 실수를 했어요. 5과의 '두 자릿수와 한 자릿수의 곱셈' 부분을 복습해보세요!",
  "WRONG_POSITION": "연산 결과를 다른 자릿수에 작성했어요.",
  "CALCULATE_WRONG": "실수가 반복된다면 이번 차시의 '교사와 함께하기' 부분을 선생님과 한번 더 풀어보세요!",
};



String returnExplanation1(int index){
  return _strMap[index] ?? "";
}

String returnExplanation2(int index){
  return _markdown[index] ?? "";
}

String returnErrorType(String rawError){
  return _errordict[rawError] ?? "UNKNOWN ERROR";
}
String returnErrorTypeSub(String rawError){
  return _errordictSub[rawError] ?? "UNKNOWN ERROR";
}

List<String> returnErrorTypeList(List<String> rawErrors){
  List<String> ans = [];
  for(int i = 0; i< rawErrors.length; i++) {
    ans.add(returnErrorType(rawErrors[i]));
  }
  return ans;
}
List<String> returnErrorTypeSubList(List<String> rawErrors){
  List<String> ans = [];
  for(int i = 0; i< rawErrors.length; i++) {
    ans.add(returnErrorTypeSub(rawErrors[i]));
  }
  return ans;
}


