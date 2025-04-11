import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:intl/intl.dart';
import 'package:nansan_flutter/modules/auth/src/widgets/gender_selector.dart';
import 'package:nansan_flutter/shared/widgets/toase_message.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';
import '../../../../shared/services/request_service.dart';
import '../services/profile_service.dart';
import '../utils/date_utils.dart';
import '../widgets/button.dart';
import '../widgets/custom_text_form_field.dart';
import '../widgets/teacher.dart';

class AddChildScreen extends StatefulWidget {
  const AddChildScreen({super.key});

  @override
  AddChildScreenState createState() => AddChildScreenState();
}

class AddChildScreenState extends State<AddChildScreen> {
  int selectedGender = 0;
  int age = 0;
  int grade = 0;
  bool _isNameEmpty = true;
  String? selectedValue;
  final List<String> items = [
    '미취학 아동',
    '초등학교 1학년',
    '초등학교 2학년',
    '초등학교 3학년',
    '초등학교 4학년',
    '초등학교 5학년',
    '초등학교 6학년',
    '중학고 1학년',
    '중학고 2학년',
    '중학고 3학년',
    '고등학교 1학년',
    '고등학교 2학년',
    '고등학교 3학년',
  ];
  final List<String> additionalTeachers = [];
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _dataTimeEditingController =
      TextEditingController();
  final TextEditingController _teacherCodeController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final _birthFormKey = GlobalKey<FormState>();
  final _teacherFormKey = GlobalKey<FormState>();
  final FocusNode _focusNode = FocusNode();
  final FocusNode _teacherFocusNode = FocusNode();
  final ScrollController _teacherListScrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _nameController.addListener(() {
      setState(() {
        _isNameEmpty = _nameController.text.isEmpty;
      });
    });
  }

  void onGenderSelected(int value) {
    setState(() {
      selectedGender = value;
    });
  }

  void submitChildProfile() async {
    if (_formKey.currentState!.validate() &&
        _birthFormKey.currentState!.validate()) {
      if (_dataTimeEditingController.text.isEmpty) {
        ToastMessage.show("생년월일을 입력해주세요.");
        return;
      }
      if (selectedValue == null) {
        ToastMessage.show("학년을 선택해주세요.");
        return;
      }

      final profileImageUrl = ProfileService().getRandomProfileImageUrl();

      final requestBody = {
        "name": _nameController.text.trim(),
        "profileImageUrl": profileImageUrl,
        "birthDate": _dataTimeEditingController.text,
        "grade": mapGradeToEnum(selectedValue),
        "gender": selectedGender == 0 ? "MALE" : "FEMALE",
      };

      try {
        await RequestService.post("/user/parent/child", data: requestBody);
        ToastMessage.show("아이 정보가 성공적으로 추가되었습니다.");
        Modular.to.pop(true);
      } catch (e) {
        print(e);
        ToastMessage.show("자녀 추가 실패: $e");
      }
    } else {
      ToastMessage.show("입력 정보를 확인해주세요.");
    }
  }

  String mapGradeToEnum(String? selectedValue) {
    switch (selectedValue) {
      case '미취학 아동':
        return 'PRESCHOOL';
      case '초등학교 1학년':
        return 'ELEMENTARY_1_1';
      case '초등학교 2학년':
        return 'ELEMENTARY_2_1';
      case '초등학교 3학년':
        return 'ELEMENTARY_3_1';
      case '초등학교 4학년':
        return 'ELEMENTARY_4_1';
      case '초등학교 5학년':
        return 'ELEMENTARY_5_1';
      case '초등학교 6학년':
        return 'ELEMENTARY_6_1';
      case '중학고 1학년':
        return 'MIDDLE_1_1';
      case '중학고 2학년':
        return 'MIDDLE_2_1';
      case '중학고 3학년':
        return 'MIDDLE_3_1';
      case '고등학교 1학년':
        return 'HIGH_1_1';
      case '고등학교 2학년':
        return 'HIGH_2_1';
      case '고등학교 3학년':
        return 'HIGH_3_1';
      default:
        return 'PRESCHOOL';
    }
  }

  @override
  Widget build(BuildContext context) {
    var screenWidth = MediaQuery.of(context).size.width;
    var screenHeight = MediaQuery.of(context).size.height;

    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          leading: IconButton(
            icon: const Icon(Icons.chevron_left, size: 40.0),
            onPressed: () => Navigator.pop(context),
          ),
          title: const Text(
            "아이 정보 입력",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: screenWidth * 0.85,
                padding: const EdgeInsets.symmetric(
                  vertical: 50,
                  horizontal: 20,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xAAC2BCBC),
                      blurRadius: 10.0,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      width: screenWidth * 0.45,
                      padding: EdgeInsets.symmetric(
                        vertical: screenHeight * 0.01,
                      ),
                      child: Image.asset(
                        "assets/images/child_info_logo.png",
                        fit: BoxFit.contain,
                      ),
                    ),
                    const SizedBox(height: 50),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: screenWidth * 0.5,
                          height: 80,
                          child: Form(
                            key: _formKey,
                            child: CustomTextFormField(
                              controller: _nameController,
                              focusNode: _focusNode,
                              labelText: "이름(필수)",
                              icon: null,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return '이름을 입력해주세요';
                                } else if (value.length > 10) {
                                  return '최대 10글자까지 입력 가능합니다';
                                } else if (value.length < 2) {
                                  return '2글자 이상 작성해주세요.';
                                }
                                return null;
                              },
                            ),
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.only(
                            left: screenWidth * 0.025,
                            top: 2,
                          ),
                          width: screenWidth * 0.25,
                          height: screenHeight * 0.07,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(
                                height: screenHeight * 0.045,
                                child: GenderSelector(
                                  onSelected: onGenderSelected,
                                  initialGender: selectedGender,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    // const SizedBox(height: 5),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: screenWidth * 0.5,
                          child: GestureDetector(
                            onTap: () {
                              _selectDataCalendar(context);
                            },
                            child: AbsorbPointer(
                              child: SizedBox(
                                child: Form(
                                  key: _birthFormKey,
                                  child: CustomTextFormField(
                                    controller: _dataTimeEditingController,
                                    focusNode: null,
                                    labelText: "생년월일(필수)",
                                    icon: const Icon(
                                      Icons.calendar_today_rounded,
                                      size: 23,
                                    ),
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return '생년월일을 입력해주세요';
                                      }
                                      return null;
                                    },
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.only(
                            left: screenWidth * 0.025,
                            right: screenWidth * 0.022,
                          ),
                          height: 55,
                          width: MediaQuery.of(context).size.width * 0.25,
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton2<String>(
                              isExpanded: true,
                              hint: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      '학년 선택',
                                      style: TextStyle(color: Colors.black),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                              items:
                                  items
                                      .map(
                                        (String item) =>
                                            DropdownMenuItem<String>(
                                              value: item,
                                              child: Text(
                                                item,
                                                style: const TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.black,
                                                ),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                      )
                                      .toList(),
                              value: selectedValue,
                              onChanged: (String? value) {
                                setState(() {
                                  selectedValue = value;
                                });
                              },
                              buttonStyleData: ButtonStyleData(
                                height: 50,
                                width: MediaQuery.of(context).size.width * 0.22,
                                padding: const EdgeInsets.only(
                                  left: 14,
                                  right: 14,
                                ),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(color: Colors.black26),
                                  color: Colors.white,
                                ),
                                elevation: 2,
                              ),
                              iconStyleData: const IconStyleData(
                                icon: Icon(Icons.arrow_forward_ios_outlined),
                                iconSize: 14,
                                iconEnabledColor: Colors.black,
                                iconDisabledColor: Colors.grey,
                              ),
                              dropdownStyleData: DropdownStyleData(
                                maxHeight: 200,
                                width: MediaQuery.of(context).size.width * 0.20,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(14),
                                  color: Colors.white,
                                ),
                                offset: const Offset(0, 0),
                                scrollbarTheme: ScrollbarThemeData(
                                  radius: const Radius.circular(40),
                                  thickness: WidgetStateProperty.all(6),
                                  thumbVisibility: WidgetStateProperty.all(
                                    true,
                                  ),
                                ),
                              ),
                              menuItemStyleData: const MenuItemStyleData(
                                height: 40,
                                padding: EdgeInsets.only(left: 14, right: 14),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),
                    Container(
                      height: 80,
                      width: screenWidth * 0.75,
                      padding: EdgeInsets.only(right: 17),
                      child: CustomTextFormField(
                        controller: _teacherCodeController,
                        focusNode: _teacherFocusNode,
                        labelText: "선생님 코드",
                        icon: IconButton(
                          onPressed: () {
                            String teacherCode =
                                _teacherCodeController.text.trim();
                            if (teacherCode.isEmpty) {
                              ToastMessage.show("선생님 코드를 입력해주세요.");
                              return;
                            }
                            if (additionalTeachers.length >= 4) {
                              ToastMessage.show("선생님은 최대 4명까지 추가 가능합니다.");
                              return;
                            }
                            setState(() {
                              additionalTeachers.add(teacherCode);
                              _teacherCodeController.clear();
                            });
                            WidgetsBinding.instance.addPostFrameCallback((_) {
                              if (_teacherListScrollController.hasClients) {
                                _teacherListScrollController.animateTo(
                                  _teacherListScrollController
                                      .position
                                      .maxScrollExtent,
                                  duration: const Duration(milliseconds: 300),
                                  curve: Curves.easeOut,
                                );
                              }
                            });
                          },
                          icon: const Icon(Icons.add),
                        ),
                        validator: null,
                      ),
                    ),
                    Container(
                      height: 200, // 고정 높이 (필요에 따라 조정 가능)
                      padding: EdgeInsets.symmetric(
                        horizontal: screenWidth * 0.04,
                      ),
                      child: ListView.builder(
                        controller: _teacherListScrollController,
                        itemCount: additionalTeachers.length,
                        itemBuilder: (context, index) {
                          final teacher = additionalTeachers[index];
                          return Teacher(
                            teacherCode: teacher,
                            onRemove: () {
                              setState(() {
                                additionalTeachers.removeAt(index);
                              });
                            },
                          );
                        },
                      ),
                    ),
                    Container(
                      alignment: Alignment.bottomRight,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 20,
                      ),
                      child: Align(
                        alignment: Alignment.bottomRight,
                        child: Button(
                          text: "추가하기",
                          onPressed: () {
                            submitChildProfile();
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _teacherListScrollController.dispose();
    super.dispose();
  }

  void _selectDataCalendar(BuildContext context) {
    showCupertinoDialog(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Center(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Container(
                width: MediaQuery.of(context).size.width * 0.55,
                height: 550,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(10),
                      blurRadius: 5,
                      spreadRadius: 5,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: SfDateRangePicker(
                  monthViewSettings: DateRangePickerMonthViewSettings(
                    dayFormat: 'EEE',
                  ),
                  monthFormat: 'MMM',
                  showNavigationArrow: true,
                  headerStyle: const DateRangePickerHeaderStyle(
                    textAlign: TextAlign.center,
                    textStyle: TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                    backgroundColor: Color.fromARGB(255, 249, 241, 196),
                  ),
                  headerHeight: 80,
                  view: DateRangePickerView.month,
                  allowViewNavigation: true,
                  backgroundColor: Colors.white,
                  initialSelectedDate: DateTime.now(),
                  minDate: DateTime(1900, 1, 1),
                  maxDate: DateTime.now(),
                  selectionColor: const Color.fromARGB(255, 249, 241, 196),
                  selectionTextStyle: const TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                  selectionMode: DateRangePickerSelectionMode.single,
                  confirmText: '완료',
                  cancelText: '취소',
                  onSubmit: (args) {
                    DateTime selectedDate = args as DateTime;
                    DateTime today = DateTime.now();

                    if (selectedDate.isAfter(today)) {
                      ToastMessage.show("미래 날짜를 선택할 수 없습니다.");
                    } else {
                      setState(() {
                        _dataTimeEditingController.text = DateFormat(
                          'yyyy-MM-dd',
                        ).format(selectedDate);
                        age = calculateAge(selectedDate);
                      });
                    }
                    Navigator.of(context).pop();
                  },
                  onCancel: () => Navigator.of(context).pop(),
                  showActionButtons: true,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
