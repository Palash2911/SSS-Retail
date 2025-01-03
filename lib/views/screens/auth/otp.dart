import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:gap/gap.dart';
import 'package:provider/provider.dart';
import 'package:sss_retail/constants/app_colors.dart';
import 'package:sss_retail/providers/auth_provider.dart';
import 'package:sss_retail/views/components/custom_loader.dart';

class OTPScreen extends StatefulWidget {
  const OTPScreen({super.key});

  @override
  State<OTPScreen> createState() => _OTPScreenState();
}

class _OTPScreenState extends State<OTPScreen> {
  final TextEditingController _otpController = TextEditingController();
  String otp = "";

  var isLoading = false;
  final _form = GlobalKey<FormState>();
  Timer? _timer;
  int _remainingTime = 0;
  bool _isButtonDisabled = false;

  @override
  void initState() {
    _startTimer();
    super.initState();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _otpController.dispose();
    super.dispose();
  }

  void _startTimer() {
    setState(() {
      _isButtonDisabled = true;
      _remainingTime = 0;
    });

    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        if (_remainingTime > 0) {
          _remainingTime--;
        } else {
          _isButtonDisabled = false;
          timer.cancel();
        }
      });
    });
  }

  // Future resendOtp() async {
  //   try {
  //     var authProvider = Provider.of<Auth>(context, listen: false);
  //     final auth = FirebaseAuth.instance;
  //     print(auth.currentUser!.phoneNumber);
  //     await authProvider
  //         .authenticate(auth.currentUser!.phoneNumber.toString())
  //         .then((_) {
  //       Fluttertoast.showToast(
  //         msg: "OTP Resent Successfully !",
  //         toastLength: Toast.LENGTH_SHORT,
  //         timeInSecForIosWeb: 1,
  //         backgroundColor: AppColors.primary,
  //         textColor: Colors.white,
  //         fontSize: 16.0,
  //       );
  //     });
  //   } catch (e) {
  //     print("yeh error $e");
  //   }
  // }

  Future _verifyOtp() async {
    setState(() {
      isLoading = true;
    });
    var authProvider = Provider.of<Auth>(context, listen: false);
    var isValid = false;
    if (otp.length == 6) {
      isValid = await authProvider.verifyOtp(otp).catchError((e) {
        return false;
      });
      if (isValid) {
        var user = await authProvider.checkUser();
        if (mounted) {
          if (user == 0) {
            Navigator.of(context).pushNamedAndRemoveUntil(
              '/user-bottom-nav',
              (Route<dynamic> route) => false,
            );
          } else if (user == 1) {
            Navigator.of(context).pushNamedAndRemoveUntil(
              '/admin-bottom-nav',
              (Route<dynamic> route) => false,
            );
          } else {
            Navigator.of(context).pushNamedAndRemoveUntil(
              '/register',
              (Route<dynamic> route) => false,
            );
          }
        }
      } else {
        setState(() {
          isLoading = false;
        });
      }
    } else {
      setState(() {
        isLoading = false;
      });
      Fluttertoast.showToast(
        msg: "Something Went Wrong !",
        toastLength: Toast.LENGTH_SHORT,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.grey,
        textColor: Colors.white,
        fontSize: 16,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isLoading
          ? CustomLoader()
          : SingleChildScrollView(
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 35.0, vertical: 54.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      SizedBox(height: 40.h),
                      Center(
                        child: Image.asset(
                          'assets/login_lottie.gif',
                          scale: 0.65,
                        ),
                      ),
                      Gap(20.w),
                      Form(
                        key: _form,
                        child: TextField(
                          controller: _otpController,
                          maxLength: 6,
                          textInputAction: TextInputAction.done,
                          keyboardType: TextInputType.phone,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          cursorColor: AppColors.accent,
                          style: const TextStyle(fontSize: 18),
                          decoration: InputDecoration(
                            hintText: 'Enter OTP',
                            counterText: "",
                            labelStyle: TextStyle(color: Colors.black),
                            border: UnderlineInputBorder(
                              borderSide: const BorderSide(
                                color: Colors.black,
                                width: 1,
                              ),
                            ),
                            focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(
                                color: AppColors.primary,
                                width: 2,
                              ),
                            ),
                            enabledBorder: UnderlineInputBorder(
                              borderSide: const BorderSide(
                                color: AppColors.primary,
                                width: 1,
                              ),
                            ),
                          ),
                          onChanged: (phone) {
                            setState(() {
                              otp = _otpController.text.toString();
                            });
                          },
                        ),
                      ),
                      Gap(30),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              mainAxisSize: MainAxisSize.max,
                              children: [
                                SizedBox(
                                  width: double.infinity,
                                  child: OutlinedButton(
                                    onPressed: _isButtonDisabled
                                        ? null
                                        : () async {
                                            // await resendOtp();
                                            _startTimer();
                                          },
                                    style: OutlinedButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 20, vertical: 14),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      textStyle: const TextStyle(
                                        fontSize: 18,
                                      ),
                                      side: BorderSide(
                                        color: _isButtonDisabled
                                            ? Colors.grey
                                            : AppColors.primary,
                                        width: 2,
                                      ),
                                      disabledBackgroundColor: Colors.white,
                                    ),
                                    child: Text(
                                      'Resend OTP',
                                      style: TextStyle(
                                        fontSize: 16.sp,
                                        color: _isButtonDisabled
                                            ? Colors.grey
                                            : AppColors.primary,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ),
                                if (_isButtonDisabled) ...[
                                  Gap(5),
                                  Text(
                                    'After 00:$_remainingTime',
                                    style: TextStyle(
                                      color: Colors.grey,
                                      fontSize: 15,
                                    ),
                                  ),
                                ]
                              ],
                            ),
                          ),
                          Gap(20),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              style: ElevatedButton.styleFrom(
                                fixedSize: const Size(300, 50),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                backgroundColor: AppColors.primary,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 10),
                                textStyle: const TextStyle(
                                  fontSize: 18,
                                ),
                              ),
                              child: Text(
                                'Edit Number',
                                style: TextStyle(
                                  fontSize: 17.sp,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 30),
                      ElevatedButton(
                        onPressed: otp.length < 6
                            ? null
                            : () async {
                                await _verifyOtp();
                              },
                        style: ElevatedButton.styleFrom(
                          fixedSize: const Size(340, 50),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          backgroundColor: AppColors.primary,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 10),
                          textStyle: const TextStyle(
                            fontSize: 18,
                          ),
                          disabledBackgroundColor:
                              const Color.fromARGB(255, 200, 200, 200),
                        ),
                        child: const Text(
                          'Verify OTP',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}
