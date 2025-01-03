import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:gap/gap.dart';
import 'package:provider/provider.dart';
import 'package:sss_retail/providers/auth_provider.dart';
import 'package:sss_retail/views/components/custom_loader.dart';

import '../../../constants/app_colors.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final _phoneController = TextEditingController();
  String phoneNo = "";

  var isLoading = false;
  final _form = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _phoneController.text = "";
  }

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  Future _sendOtp(BuildContext ctx) async {
    final isValid = _form.currentState!.validate();
    isLoading = true;
    _form.currentState!.save();
    if (isValid) {
      await Provider.of<Auth>(ctx, listen: false)
          .authenticate(phoneNo)
          .catchError((e) {})
          .then((_) {
        Fluttertoast.showToast(
          msg: "OTP Sent Successfully !",
          toastLength: Toast.LENGTH_SHORT,
          timeInSecForIosWeb: 1,
          backgroundColor: AppColors.primary,
          textColor: Colors.white,
          fontSize: 16.0,
        );
        if (mounted) {
          Navigator.of(context).pushNamed('/otp');
        }
      }).catchError((e) {
        Fluttertoast.showToast(
          msg: e.toString(),
          toastLength: Toast.LENGTH_SHORT,
          timeInSecForIosWeb: 1,
          backgroundColor: AppColors.primary,
          textColor: Colors.white,
          fontSize: 16.0,
        );
      });
    } else {
      Fluttertoast.showToast(
        msg: "Enter A Valid Number !",
        toastLength: Toast.LENGTH_SHORT,
        timeInSecForIosWeb: 1,
        backgroundColor: AppColors.primary,
        textColor: Colors.white,
        fontSize: 16.0,
      );
    }
    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isLoading
          ? CustomLoader()
          : SingleChildScrollView(
              child: SafeArea(
                child: Padding(
                  padding:
                      EdgeInsets.symmetric(horizontal: 27.w, vertical: 36.w),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      SizedBox(height: 40.h),
                      Center(
                        child: Image.asset(
                          'assets/login_lottie.gif',
                          scale: 0.65,
                        ),
                      ),
                      Gap(20.w),
                      Text(
                        "Phone Number",
                        style: TextStyle(
                          fontSize: 25.sp,
                          color: Colors.black87,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Gap(18.w),
                      Form(
                          key: _form,
                          child: Row(
                            children: [
                              Expanded(
                                child: TextFormField(
                                  controller: _phoneController,
                                  keyboardType: TextInputType.phone,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly,
                                  ],
                                  style: TextStyle(
                                    fontSize: 19.sp,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  cursorColor: AppColors.accent,
                                  maxLength: 10,
                                  decoration: InputDecoration(
                                    prefixIcon: Container(
                                      width: 30,
                                      alignment: Alignment.centerLeft,
                                      child: Text(
                                        '+91 ',
                                        style: TextStyle(
                                          fontSize: 18.sp,
                                          color: Colors.grey,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                    hintText: 'Enter Number',
                                    hintStyle: TextStyle(color: Colors.black54),
                                    counterText: "",
                                    border: UnderlineInputBorder(
                                      borderRadius: BorderRadius.circular(15.r),
                                      borderSide: const BorderSide(
                                        color: AppColors.accent,
                                        width: 1,
                                      ),
                                    ),
                                    focusedBorder: UnderlineInputBorder(
                                      borderSide: BorderSide(
                                        color: AppColors.accentColor2,
                                        width: 2,
                                      ),
                                    ),
                                    enabledBorder: UnderlineInputBorder(
                                      borderSide: BorderSide(
                                        color: AppColors.accentColor2,
                                        width: 1,
                                      ),
                                    ),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please Enter Valid Number!';
                                    }
                                    return null;
                                  },
                                  onChanged: (value) {
                                    setState(() {
                                      phoneNo = '+91$value';
                                    });
                                  },
                                ),
                              ),
                            ],
                          )),
                      SizedBox(height: 20.h),
                      SizedBox(
                        width: 280,
                        child: Text(
                          "A 6 digit OTP will be sent via SMS to verify your number",
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 15.sp,
                          ),
                          textAlign: TextAlign.left,
                        ),
                      ),
                      SizedBox(height: 50.h),
                      Center(
                        child: ElevatedButton(
                          onPressed: _phoneController.text.length < 10
                              ? null
                              : () => _sendOtp(context),
                          style: ElevatedButton.styleFrom(
                            fixedSize: const Size(340, 50),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.r),
                            ),
                            backgroundColor:
                                const Color.fromARGB(209, 230, 57, 71),
                            padding: EdgeInsets.symmetric(
                                horizontal: 20.w, vertical: 10.w),
                            textStyle: const TextStyle(fontSize: 18),
                            disabledBackgroundColor: AppColors.accent,
                          ),
                          child: const Text(
                            'Get OTP',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
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
