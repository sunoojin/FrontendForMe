import 'package:diary_for_me/setting/widget/setting_category.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../common/ui_kit.dart';
import 'edit_collection_screen.dart';
import 'edit_profile_screen.dart';

class SettingScreen extends StatelessWidget {
  const SettingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: textPrimary, size: 28.0),
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        titleSpacing: 20,
      ),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '설정',
                style: pageTitle(),
              ),
              SizedBox(height: 16,),
              SettingCategory(
                title: '개인정보 변경하기',
                icon: Icons.person,
                onTap: () {
                  Navigator.push(
                    context,
                    CupertinoPageRoute(builder: (context) => const EditProfileScreen()),
                  );
                },
              ),
              SizedBox(height: 16,),
              SettingCategory(
                title: '정보 수집 범위 변경하기',
                icon: Icons.collections,
                onTap: () {
                  Navigator.push(
                    context,
                    CupertinoPageRoute(builder: (context) => const EditCollectionScreen()),
                  );
                },
              )
            ],
          ),
        ),
      ),
    );
  }
}
