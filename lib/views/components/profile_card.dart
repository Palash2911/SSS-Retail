import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:sss_retail/constants/app_colors.dart';

class ProfileCard extends StatelessWidget {
  final String uName;
  final String uNum;
  final String uDealerName;
  final bool isAdmin;

  const ProfileCard({
    super.key,
    required this.uDealerName,
    required this.uName,
    required this.uNum,
    required this.isAdmin,
  });

  String formatPhoneNumber(String number) {
    if (number.length == 13 && number.startsWith('+91')) {
      return '${number.substring(0, 3)} ${number.substring(3, 8)} ${number.substring(8)}';
    }
    return number;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 9, vertical: 15),
      child: Card(
        elevation: 3,
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: Colors.grey, width: 1.2),
        ),
        child: Padding(
          padding: EdgeInsets.all(15),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Gap(6),
              Image.asset(
                "assets/profile_avtar.png",
              ),
              Gap(15),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      AutoSizeText(
                        uName,
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      if (!isAdmin) ...[
                        AutoSizeText(
                          uDealerName,
                          style: TextStyle(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 1,
                        ),
                        const SizedBox(height: 10),
                      ],
                      AutoSizeText(
                        formatPhoneNumber(uNum),
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      isAdmin
                          ? Container(
                              padding: const EdgeInsets.symmetric(
                                vertical: 5,
                                horizontal: 20,
                              ),
                              decoration: BoxDecoration(
                                borderRadius: const BorderRadius.all(
                                  Radius.circular(20),
                                ),
                                color: AppColors.primary,
                              ),
                              child: Text(
                                'Admin',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 15,
                                ),
                              ),
                            )
                          : SizedBox(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
