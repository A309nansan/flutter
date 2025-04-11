import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:nansan_flutter/modules/auth/src/services/auth_service.dart';
import 'package:nansan_flutter/modules/main/src/service/category_service.dart';
import 'package:nansan_flutter/modules/main/src/widgets/main_list_item.dart';
import 'package:nansan_flutter/shared/widgets/appbar_widget.dart';
import '../../../../shared/widgets/en_list_splash_screen.dart';
import '../../../math/src/utils/math_ui_constant.dart';
import '../models/en_category_model.dart';

class MainListScreen extends StatefulWidget {
  const MainListScreen({super.key});

  @override
  State<MainListScreen> createState() => _MainListScreenState();
}

class _MainListScreenState extends State<MainListScreen> {
  List<EnCategoryModel> mainCategories = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    setState(() => isLoading = true);
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    final result = await CategoryService.fetchCategories();
    setState(() {
      mainCategories = result;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    var screenWidth = MediaQuery.of(context).size.width;
    var screenHeight = MediaQuery.of(context).size.height;
    final authService = Modular.get<AuthService>();
    MathUIConstant.instance.init(
      mediaQuery: MediaQuery.of(context),
      isTest: false, // 테스트 여부에 따라 true로 변경 가능
    );

    return Scaffold(
      appBar: AppbarWidget(
        title: Text(
          "프로필 선택",
          style: TextStyle(
              fontSize: screenWidth * 0.02,
              fontWeight: FontWeight.bold
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.chevron_left, size: screenWidth * 0.05),
          onPressed: () => Modular.to.pop(),
        ),
      ),
      body: isLoading
          ? EnListSplashScreen() :
      Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: screenWidth * 0.55,
                height: screenHeight * 0.25,
                child: Image.asset(
                  "assets/images/soonamu_main.png",
                  fit: BoxFit.contain,
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
                child: GridView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: screenWidth * 0.04,
                    mainAxisSpacing: screenHeight * 0.05,
                    childAspectRatio: 1,
                  ),
                  itemCount: mainCategories.length - 1,
                  itemBuilder: (context, index) {
                    return MainListItem(category: mainCategories[index], scale: screenHeight * 0.0011);
                  },
                ),
              ),
              Padding(
                padding: EdgeInsets.only(top: screenHeight * 0.015),
                child: SizedBox(
                  width: screenWidth * 0.90,
                  height: screenHeight * 0.33,
                  child: MainListItem(category: mainCategories.last, scale: screenHeight * 0.001),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
