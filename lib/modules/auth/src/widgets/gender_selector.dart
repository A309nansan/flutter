import 'package:flutter/material.dart';
import '../models/gender.dart';
import 'custom_gender_radio.dart';

class GenderSelector extends StatefulWidget {
  final Function(int) onSelected;
  final int initialGender; // 초기 성별 값 추가

  const GenderSelector({
    super.key,
    required this.onSelected,
    required this.initialGender,
  });

  @override
  GenderSelectorState createState() => GenderSelectorState();
}

class GenderSelectorState extends State<GenderSelector> {
  late int selectedGender;

  final List<Gender> genders = [
    Gender("남", Icons.male, 0, false),
    Gender("여", Icons.female, 1, false),
  ];

  @override
  void initState() {
    super.initState();
    selectedGender = widget.initialGender;

    for (var gender in genders) {
      gender.isSelected = gender.value == selectedGender;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      scrollDirection: Axis.horizontal,
      shrinkWrap: true,
      itemCount: genders.length,
      itemBuilder: (context, index) {
        return ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: Color.fromARGB(255, 249, 241, 196),
            shape: index == 0 ? RoundedRectangleBorder(
                borderRadius: BorderRadius.only(topLeft: Radius.circular(15), bottomLeft: Radius.circular(15))
            ) : RoundedRectangleBorder(
                borderRadius: BorderRadius.only(topRight: Radius.circular(15), bottomRight: Radius.circular(15))
            ),
            padding: EdgeInsets.zero,
            minimumSize: Size.zero,
            elevation: 3,
          ),
          onPressed: () {
            setState(() {
              for (var gender in genders) {
                gender.isSelected = false;
              }
              genders[index].isSelected = true;
              selectedGender = genders[index].value;
            });

            widget.onSelected(selectedGender);
          },
          child: CustomGenderRadio(genders[index]),
        );
      },
    );
  }
}
