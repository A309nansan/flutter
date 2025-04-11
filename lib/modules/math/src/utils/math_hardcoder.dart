import '../models/m_problem_metadata.dart';
import 'dart:math';
String getOperator(int categoryIndex){

  if (categoryIndex < 500 && categoryIndex % 2 == 1) return "PLUS";
  if (categoryIndex < 500 && categoryIndex % 2 == 0) return "MIN";
  if (categoryIndex == 503) return "PLUS";
  if (categoryIndex == 504) return "MIN";
  if (categoryIndex == 502 || categoryIndex == 601 || categoryIndex == 602) return 'MULT';
  return "DIV";

}

List<int> getMatrixVolumes(int c, int num1, int num2){ //c = categoryIndex

  if (c == 101 || c == 102 || c == 104 || c == 501) return [0,0,0,0,1,1];
  if (c == 103 || (c > 200 && c < 205) ) return [0,0,0,0,1,2];
  if (c == 302 || c == 304) return [1,2,0,0,1,2];
  if (c == 401 || c == 402) return [0,0,0,0,1,3];
  if (c == 301 || c == 303 || c == 404 ) return [1,3,0,0,1,3];
  if (c == 403 || c == 504) return [1,4,0,0,1,4];
  if (c == 503) return [1,5,0,0,1,5];

  if (c == 502) return [1,3,0,0,1,3];
  if (c == 601) return [1,4,0,0,1,4];
  if (c == 602) return [2,4,2,4,1,4];

  if (c == 603) {
    if (num1~/num2 >= 10 ) return [0, 0, 4, 2, 1, 2];
    else return [0,0,2,2,1,2];
  }
  if (c == 604) {
    if (num1~/num2 >= 10 )return [1, 1, 4, 2, 1, 2];
    else return [1,1,2,2,1,2];
  }
    return [];
}

int idTranslate(int id){
  if (id == 46) return 101;
  if (id == 47) return 102;
  if (id == 48) return 103;
  if (id == 49) return 104;

  if (id == 50) return 201;
  if (id == 51) return 202;
  if (id == 52) return 203;
  if (id == 53) return 204;

  if (id == 54) return 301;
  if (id == 55) return 302;
  if (id == 56) return 303;
  if (id == 57) return 304;

  if (id == 58) return 401;
  if (id == 59) return 402;
  if (id == 60) return 403;
  if (id == 61) return 404;

  if (id == 62) return 501;
  if (id == 63) return 502;
  if (id == 64) return 503;
  if (id == 65) return 504;

  if (id == 66) return 601;
  if (id == 67) return 602;
  if (id == 68) return 603;
  if (id == 69) return 604;

  return -1;
}

String getType(int c){
  if (c<200 || c == 501) return "SingleLine";
  if (c<500 || c == 503 || c == 504) return "AddSub";
  if(c == 502 || c == 601 || c == 602) return "Multiplication";
  if (c == 603) return "Division";
  return "DivisionRemainder";
}



// final _random = Random();
//
// int getRandomNoCarry(int x) {
//   int ans = 0;
//   int index = 1;
//   for (int i = 0; i < x; i++) {
//     ans += index * _random.nextInt(5); // 0~4
//     index *= 10;
//   }
//   return ans;
// }
// int getRandomInRange(int min, int max) {
//   return min + _random.nextInt(max - min + 1);
// }
//
// int getRandomYesCarry(int x) {
//   if (x == 1) return getRandomInRange(0,10);
//   if (x == 2) return getRandomInRange(10,100);
//   if (x == 3) return getRandomInRange(100,1000);
//   if (x == 4) return getRandomInRange(1000,10000);
//   return 0;
// }
//
// List<int> getRandomValue(int c){
//   if (c == 101) {
//     int n1 = getRandomNoCarry(1);
//     int n2 = getRandomNoCarry(1);
//     return [n1,n2];
//   }
//   if (c == 102){
//     int n1 = getRandomNoCarry(1);
//     int n2 = getRandomNoCarry(1);
//     return [n1+n2,n2];
//   }
//   if (c == 103) {
//     int n1 = getRandomYesCarry(1);
//     int n2 = getRandomYesCarry(1);
//     return [n1,n2];
//   }
//   if (c == 104){
//     int n1 = 10;
//     int n2 = getRandomNoCarry(1);
//     return [n1,n2];
//   }
//
//
//   if (c == 201) {
//     int n1 = getRandomNoCarry(2);
//     int n2 = getRandomNoCarry(1);
//     return [n1,n2];
//   }
//   if (c == 202){
//     int n1 = getRandomNoCarry(2);
//     int n2 = getRandomNoCarry(1);
//     return [n1+n2,n2];
//   }
//   if (c == 203) {
//     int n1 = getRandomNoCarry(2);
//     int n2 = getRandomNoCarry(2);
//     return [n1,n2];
//   }
//   if (c == 204){
//     int n1 = getRandomNoCarry(2);
//     int n2 = getRandomNoCarry(2);
//     return [n1+n2,n2];
//   }
//
//   if (c == 301) {
//     int n1 = getRandomYesCarry(2);
//     int n2 = getRandomYesCarry(1);
//     return [n1,n2];
//   }
//   if (c == 302){
//     int n1 = getRandomYesCarry(2);
//     int n2 = getRandomYesCarry(1);
//     return [n1+n2 - 10,n2];
//   }
//   if (c == 303) {
//     int n1 = getRandomYesCarry(2);
//     int n2 = getRandomYesCarry(2);
//     return [n1,n2];
//   }
//   if (c == 304){
//     int n1 = getRandomYesCarry(2);
//     int n2 = getRandomYesCarry(2);
//     return [max(n1,n2),min(n1,n2)];
//   }
//
//   if (c == 401) {
//     int n1 = getRandomNoCarry(3);
//     int n2 = getRandomNoCarry(3);
//     return [n1,n2];
//   }
//   if (c == 402){
//     int n1 = getRandomNoCarry(3);
//     int n2 = getRandomNoCarry(3);
//     return [n1+n2,n2];
//   }
//   if (c == 403) {
//     int n1 = getRandomYesCarry(3);
//     int n2 = getRandomYesCarry(3);
//     return [n1,n2];
//   }
//   if (c == 404){
//     int n1 = getRandomYesCarry(3);
//     int n2 = getRandomYesCarry(3);
//     return [max(n1,n2),min(n1,n2)];
//   }
//
//   if (c == 501){
//     int n1 = (getRandomYesCarry(1) + 1) % 10;
//     int n2 = (getRandomYesCarry(1) + 1) % 10;
//     return [n1*n2, n1];
//   }
//   if (c == 502){
//     int n1 = getRandomYesCarry(2);
//     int n2 = getRandomYesCarry(1);
//     return [n1, n2];
//   }
//   if (c == 503) {
//     int n1 = getRandomYesCarry(4);
//     int n2 = getRandomYesCarry(4);
//     return [n1,n2];
//   }
//   if (c == 504){
//     int n1 = getRandomYesCarry(4);
//     int n2 = getRandomYesCarry(4);
//     return [max(n1,n2),min(n1,n2)];
//   }
//
//   if (c == 601){
//     int n1 = getRandomYesCarry(3);
//     int n2 = getRandomYesCarry(1);
//     return [n1, n2];
//   }
//   if (c == 602){
//     int n1 = getRandomYesCarry(2);
//     int n2 = getRandomYesCarry(2);
//     return [n1, n2];
//   }
//
//   if (c == 603){
//     int n1 = (getRandomNoCarry(1) + 1) ;
//     int n2 = getRandomNoCarry(2)+10;
//     return [(n1*n2)%80, n1];
//   }
//   if (c == 604){
//     int n1 = getRandomYesCarry(2);
//     int n2 = getRandomYesCarry(1);
//     return [n1, n2];
//   }
//
//   List<int> ans = [0,0];
//
//   return ans;
//
// }
// MProblemMetadata getRandomMathData(int c, int index){
//   String op = getOperator(c);
//   List<int> nums = getRandomValue(c);
//
//   List<int> mv= getMatrixVolumes(c, nums[0], nums[1]);
//   String type = getType(c);
//   MProblemMetadata md = MProblemMetadata(index: index, num1: nums[0], num2: nums[1], operator: op, matrixVolume: mv, type: type
//
//   );
//
//   return md;
// }


//
// int findCategory(int n, int m, String op){
//   int nDigit = n.toString().length;
//   int mDigit = m.toString().length;
//   if (op == "PLUS") return findPlusCategory(n,m, nDigit, mDigit);
//   if (op == "MIN") return findMinusCategory(n,m, nDigit, mDigit);
//   if (op == "MULT") return findMultiplicationCategory(n,m);
//   if (op == "DIV") return findDivisionCategory(n,m);
//   return 0;
// }
// //
// // bool hasPlusCarry(int n, int m) {
//   int carry = 0;
//   while (n > 0 || m > 0 || carry > 0) {
//     int sum = (n % 10) + (m % 10) + carry;
//     if (sum >= 10) {
//       return true; // carry 발생!
//     }
//     carry = sum ~/ 10; // 정수 나눗셈
//     n ~/= 10; // 다음 자리
//     m ~/= 10;
//   }
//   return false; // 한 번도 carry 안 생겼음
// }
// bool hasMinusCarry(int n, int m, int maxDigit) {
//   // n >= m 이라고 가정
//   while (n > 0 || m > 0) {
//     int dN = n % maxDigit;
//     int dM = m % maxDigit;
//
//     // 만약 현재 자릿수에서 dN < dM 이라면, 빌려와야 함
//     if (dN < dM) {
//       return false; // 한 번이라도 borrow가 생김 → 즉시 0
//     }
//
//     // 빌려오지 않고 처리 가능하므로( dN >= dM ),
//     // 다음 자릿수로 넘어가기
//     n ~/= maxDigit;
//     m ~/= maxDigit;
//   }
//
//   // 모든 자리에서 빌려온 적 없음
// //   return true;
// // }
// int findPlusCategory(int n, int m, int nDigit, int mDigit){
//   if (n+m < 10) return 101;
//   if (n<10 && m < 10) return 103;
//   if (!hasPlusCarry(n,m)){
//     if (nDigit + mDigit == 3) return 201;
//     if (nDigit == 2 && mDigit == 2) return 203;
//     if (max(nDigit, mDigit) == 3) return 401;
//
//   }
//   else{
//     if (nDigit + mDigit == 3) return 301;
//     if (nDigit == 2 && mDigit == 2) return 303;
//     if (max(nDigit, mDigit) == 3) return 403;
//   }
//   return 503;
// }
// int findMinusCategory(int n, int m, int nDigit, int mDigit){
//   if (n < 10 && m < 10) return 102;
//   if (n == 10 && m < 10) return 104;
//   if (!hasPlusCarry(n,m)){
//     if (nDigit + mDigit == 3) return 202;
//     if (nDigit == 2 && mDigit == 2) return 204;
//     if (max(nDigit, mDigit) == 3) return 402;
//   }
//   else{
//     if (nDigit + mDigit == 3) return 302;
//     if (nDigit == 2 && mDigit == 2) return 304;
//     if (max(nDigit, mDigit) == 3) return 404;
//   }
//   return 504;
// }
//
// int findMultiplicationCategory(int n, int m){
//   if (n<100) {
//     if (m < 10) return 502;
//     return 602;
//   }
//   return 601;
// }
// int findDivisionCategory(int n, int m){
//   if (n%m ==0){
//     if (n/m < 10) return 501;
//     else return 603;
//   }
//   return 604;
// }
