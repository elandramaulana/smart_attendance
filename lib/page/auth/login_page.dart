import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:smart_attendance/controller/login_controller.dart';
import 'package:smart_attendance/core/app_routes.dart';

class LoginPage extends GetView<LoginController> {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background gradient yang selaras dengan SplashScreen
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFFFF3F0), Color(0xFFE3F2FD)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          // Siluet dekoratif yang sesuai dengan SplashScreen
          Positioned(
            top: -50,
            left: -50,
            child: Container(
              width: 200.w,
              height: 200.h,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.pink.shade100.withOpacity(0.3),
              ),
            ),
          ),
          Positioned(
            bottom: -30,
            right: -30,
            child: Container(
              width: 150.w,
              height: 150.h,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.blue.shade100.withOpacity(0.3),
              ),
            ),
          ),
          Positioned(
            bottom: 50,
            left: 50,
            child: Container(
              width: 100.w,
              height: 100.h,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.green.shade100.withOpacity(0.3),
              ),
            ),
          ),
          Center(
            child: SingleChildScrollView(
              child: Card(
                elevation: 5,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.r),
                ),
                margin: EdgeInsets.symmetric(horizontal: 30.w),
                child: Padding(
                  padding: EdgeInsets.all(25.w),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        'Halo!',
                        style: TextStyle(
                          fontSize: 26.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey.shade800,
                        ),
                      ),
                      SizedBox(height: 10.h),
                      Text(
                        textAlign: TextAlign.center,
                        'Silahkan masuk untuk melanjutkan',
                        style: TextStyle(
                          fontSize: 16.sp,
                          color: Colors.grey,
                        ),
                      ),
                      SizedBox(height: 30.h),
                      TextField(
                        controller: controller.emailController,
                        decoration: InputDecoration(
                          labelText: 'Email',
                          prefixIcon:
                              const Icon(Icons.email, color: Colors.blueGrey),
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.r),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                      SizedBox(height: 20.h),
                      TextField(
                        controller: controller.passwordController,
                        obscureText: true,
                        decoration: InputDecoration(
                          labelText: 'Password',
                          prefixIcon:
                              const Icon(Icons.lock, color: Colors.blueGrey),
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.r),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                      SizedBox(height: 30.h),
                      Obx(() {
                        return SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: controller.isLoading.value
                                ? null
                                : () {
                                    controller.login();
                                  },
                            style: ElevatedButton.styleFrom(
                              padding: EdgeInsets.symmetric(vertical: 15.h),
                              backgroundColor: Colors.blueGrey,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12.r),
                              ),
                            ),
                            child: controller.isLoading.value
                                ? SizedBox(
                                    width: 24.w,
                                    height: 24.w,
                                    child: const CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : Text(
                                    'Login',
                                    style: TextStyle(
                                      fontSize: 18.sp,
                                      color: Colors.white,
                                    ),
                                  ),
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
