// // lib/main.dart
// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
//
//
// void main() {
//   DependencyInjection.init();
//   runApp(MyApp());
// }
//
// class MyApp extends StatelessWidget {
//   const MyApp({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return GetMaterialApp(
//       title: 'Flutter Sign Up',
//       theme: ThemeData(
//         primarySwatch: Colors.blue,
//         visualDensity: VisualDensity.adaptivePlatformDensity,
//       ),
//       initialRoute: AppRoutes.SIGNUP,
//       getPages: AppPages.routes,
//       debugShowCheckedModeBanner: false,
//     );
//   }
// }
//
// // lib/app/routes/app_routes.dart
// abstract class AppRoutes {
//   static const SIGNUP = '/signup';
// }
//
// // lib/app/routes/app_pages.dart
// // import 'package:get/get.dart';
// // import '../modules/signup/bindings/signup_binding.dart';
// // import '../modules/signup/views/signup_view.dart';
// // import 'app_routes.dart';
//
// class AppPages {
//   static const INITIAL = AppRoutes.SIGNUP;
//
//   static final routes = [
//     GetPage(
//       name: AppRoutes.SIGNUP,
//       page: () => SignupView(),
//       binding: SignupBinding(),
//     ),
//   ];
// }
//
// // lib/app/data/models/user_model.dart
// class SignUpModel {
//   final String firstName;
//   final String lastName;
//   final String email;
//   final String phone;
//   final String dateOfBirth;
//   final String password;
//   final String gender;
//
//   SignUpModel({
//     required this.firstName,
//     required this.lastName,
//     required this.email,
//     required this.phone,
//     required this.dateOfBirth,
//     required this.password,
//     required this.gender,
//   });
//
//   Map<String, dynamic> toJson() {
//     return {
//       'firstName': firstName,
//       'lastName': lastName,
//       'email': email,
//       'phone': phone,
//       'dateOfBirth': dateOfBirth,
//       'password': password,
//       'gender': gender,
//     };
//   }
//
//   factory SignUpModel.fromJson(Map<String, dynamic> json) {
//     return SignUpModel(
//       firstName: json['firstName'] ?? '',
//       lastName: json['lastName'] ?? '',
//       email: json['email'] ?? '',
//       phone: json['phone'] ?? '',
//       dateOfBirth: json['dateOfBirth'] ?? '',
//       password: json['password'] ?? '',
//       gender: json['gender'] ?? '',
//     );
//   }
// }
//
// // lib/app/data/providers/auth_provider.dart
// // import 'package:get/get.dart';
// // import '../models/user_model.dart';
//
// class AuthProvider extends GetConnect {
//   @override
//   void onInit() {
//     httpClient.baseUrl = 'https://your-api-base-url.com';
//     httpClient.timeout = Duration(seconds: 30);
//   }
//
//   Future<Response> signUp(SignUpModel user) async {
//     try {
//       return await post('/auth/signup', user.toJson());
//     } catch (e) {
//       return Response(statusCode: 500, body: {'error': e.toString()});
//     }
//   }
//
//   Future<Response> checkEmailExists(String email) async {
//     try {
//       return await get('/auth/check-email?email=$email');
//     } catch (e) {
//       return Response(statusCode: 500, body: {'error': e.toString()});
//     }
//   }
// }
//
// // lib/app/data/repositories/auth_repository.dart
// // import 'package:get/get.dart';
// // import '../models/user_model.dart';
// // import '../providers/auth_provider.dart';
//
// class AuthRepository {
//   final AuthProvider _authProvider = Get.find<AuthProvider>();
//
//   Future<bool> signUp(SignUpModel user) async {
//     try {
//       final response = await _authProvider.signUp(user);
//       return response.statusCode == 200;
//     } catch (e) {
//       if (kDebugMode) {
//         print('Repository Error: $e');
//       }
//       return false;
//     }
//   }
//
//   Future<bool> checkEmailExists(String email) async {
//     try {
//       final response = await _authProvider.checkEmailExists(email);
//       return response.statusCode == 200 && response.body['exists'] == true;
//     } catch (e) {
//       if (kDebugMode) {
//         print('Repository Error: $e');
//       }
//       return false;
//     }
//   }
// }
//
// // lib/app/data/services/dependency_injection.dart
// // import 'package:get/get.dart';
// // import '../providers/auth_provider.dart';
// // import '../repositories/auth_repository.dart';
//
// class DependencyInjection {
//   static void init() {
//     Get.put<AuthProvider>(AuthProvider());
//     Get.put<AuthRepository>(AuthRepository());
//   }
// }
//
// // lib/app/modules/signup/controllers/signup_controller.dart
// // import 'package:flutter/material.dart';
// // import 'package:get/get.dart';
// // import '../../../data/models/user_model.dart';
// // import '../../../data/repositories/auth_repository.dart';
//
// class SignupController extends GetxController {
//   final AuthRepository _authRepository = Get.find<AuthRepository>();
//
//   // Form Controllers
//   final firstNameController = TextEditingController();
//   final lastNameController = TextEditingController();
//   final emailController = TextEditingController();
//   final phoneController = TextEditingController();
//   final dobController = TextEditingController();
//   final passwordController = TextEditingController();
//
//   // Observable variables
//   var isLoading = false.obs;
//   var isPasswordVisible = false.obs;
//   var selectedGender = 'Male'.obs;
//   var isFormValid = false.obs;
//
//   // Form Key
//   final formKey = GlobalKey<FormState>();
//
//   @override
//   void onInit() {
//     super.onInit();
//     phoneController.text = '+92 ';
//
//     // Add listeners to validate form
//     firstNameController.addListener(_validateForm);
//     lastNameController.addListener(_validateForm);
//     emailController.addListener(_validateForm);
//     phoneController.addListener(_validateForm);
//     dobController.addListener(_validateForm);
//     passwordController.addListener(_validateForm);
//   }
//
//   void _validateForm() {
//     isFormValid.value = firstNameController.text.isNotEmpty &&
//         lastNameController.text.isNotEmpty &&
//         emailController.text.isNotEmpty &&
//         phoneController.text.length > 4 &&
//         dobController.text.isNotEmpty &&
//         passwordController.text.isNotEmpty;
//   }
//
//   void togglePasswordVisibility() {
//     isPasswordVisible.value = !isPasswordVisible.value;
//   }
//
//   void selectGender(String gender) {
//     selectedGender.value = gender;
//   }
//
//   Future<void> selectDateOfBirth(BuildContext context) async {
//     final DateTime? picked = await showDatePicker(
//       context: context,
//       initialDate: DateTime.now().subtract(Duration(days: 6570)), // 18 years ago
//       firstDate: DateTime(1900),
//       lastDate: DateTime.now(),
//     );
//
//     if (picked != null) {
//       dobController.text = "${picked.day}/${picked.month}/${picked.year}";
//     }
//   }
//
//   String? validateEmail(String? value) {
//     if (value == null || value.isEmpty) {
//       return 'Email is required';
//     }
//     if (!GetUtils.isEmail(value)) {
//       return 'Please enter a valid email';
//     }
//     return null;
//   }
//
//   String? validatePhone(String? value) {
//     if (value == null || value.isEmpty) {
//       return 'Phone number is required';
//     }
//     if (value.length < 10) {
//       return 'Please enter a valid phone number';
//     }
//     return null;
//   }
//
//   String? validatePassword(String? value) {
//     if (value == null || value.isEmpty) {
//       return 'Password is required';
//     }
//     if (value.length < 6) {
//       return 'Password must be at least 6 characters';
//     }
//     return null;
//   }
//
//   String? validateRequired(String? value, String fieldName) {
//     if (value == null || value.isEmpty) {
//       return '$fieldName is required';
//     }
//     return null;
//   }
//
//   Future<void> signUp() async {
//     if (!formKey.currentState!.validate()) return;
//
//     isLoading.value = true;
//
//     try {
//       final user = SignUpModel(
//         firstName: firstNameController.text.trim(),
//         lastName: lastNameController.text.trim(),
//         email: emailController.text.trim(),
//         phone: phoneController.text.trim(),
//         dateOfBirth: dobController.text.trim(),
//         password: passwordController.text.trim(),
//         gender: selectedGender.value,
//       );
//
//       final success = await _authRepository.signUp(user);
//
//       if (success) {
//         Get.snackbar(
//           'Success',
//           'Account created successfully!',
//           snackPosition: SnackPosition.BOTTOM,
//           backgroundColor: Colors.green,
//           colorText: Colors.white,
//         );
//         // Navigate to next screen
//       } else {
//         Get.snackbar(
//           'Error',
//           'Failed to create account. Please try again.',
//           snackPosition: SnackPosition.BOTTOM,
//           backgroundColor: Colors.red,
//           colorText: Colors.white,
//         );
//       }
//     } catch (e) {
//       Get.snackbar(
//         'Error',
//         'An error occurred. Please try again.',
//         snackPosition: SnackPosition.BOTTOM,
//         backgroundColor: Colors.red,
//         colorText: Colors.white,
//       );
//     } finally {
//       isLoading.value = false;
//     }
//   }
//
//   @override
//   void onClose() {
//     firstNameController.dispose();
//     lastNameController.dispose();
//     emailController.dispose();
//     phoneController.dispose();
//     dobController.dispose();
//     passwordController.dispose();
//     super.onClose();
//   }
// }
//
// // // lib/app/modules/signup/bindings/signup_binding.dart
// // import 'package:get/get.dart';
// // import '../controllers/signup_controller.dart';
//
// class SignupBinding extends Bindings {
//   @override
//   void dependencies() {
//     Get.lazyPut<SignupController>(
//           () => SignupController(),
//     );
//   }
// }
//
// // lib/app/modules/signup/views/signup_view.dart
// // import 'package:flutter/material.dart';
// // import 'package:get/get.dart';
// // import '../controllers/signup_controller.dart';
// // import '../widgets/custom_text_field.dart';
// // import '../widgets/gender_selector.dart';
// // import '../widgets/custom_button.dart';
//
// class SignupView extends GetView<SignupController> {
//   const SignupView({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       appBar: AppBar(
//         backgroundColor: Colors.transparent,
//         elevation: 0,
//         leading: IconButton(
//           icon: Icon(Icons.arrow_back_ios, color: Colors.black),
//           onPressed: () => Get.back(),
//         ),
//       ),
//       body: SingleChildScrollView(
//         padding: EdgeInsets.symmetric(horizontal: 35, vertical:1),
//         child: Form(
//           key: controller.formKey,
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Center(
//                 child: Text(
//                   'Create Account',
//                   style: TextStyle(
//                     fontSize: 28,
//                     fontWeight: FontWeight.bold,
//                     color: Colors.black,
//                   ),
//                 ),
//               ),
//               SizedBox(height: 8),
//               Center(
//                 child: Text(
//                   'Sign up to keep exploring profiles\naround the world',
//                   style: TextStyle(
//                     fontSize: 16,
//                     color: Colors.grey[600],
//                     height: 1.4,
//                   ),
//                 ),
//               ),
//               SizedBox(height: 10),
//
//               // First Name and Last Name Row
//               Row(
//                 children: [
//                   Expanded(
//                     child: CustomTextField(
//                       controller: controller.firstNameController,
//                       hintText: 'First Name',
//                       prefixIcon: Icons.person_outline,
//                       validator: (value) => controller.validateRequired(value, 'First Name'),
//                     ),
//                   ),
//                   SizedBox(width: 16),
//                   Expanded(
//                     child: CustomTextField(
//                       controller: controller.lastNameController,
//                       hintText: 'Last Name',
//                       prefixIcon: Icons.person_outline,
//                       validator: (value) => controller.validateRequired(value, 'Last Name'),
//                     ),
//                   ),
//                 ],
//               ),
//               SizedBox(height: 10),
//
//               // Email Field
//               CustomTextField(
//                 controller: controller.emailController,
//                 hintText: 'Enter your email',
//                 prefixIcon: Icons.email_outlined,
//                 keyboardType: TextInputType.emailAddress,
//                 validator: controller.validateEmail,
//               ),
//               SizedBox(height: 10),
//
//               // Phone Field
//               CustomTextField(
//                 controller: controller.phoneController,
//                 hintText: '+92 000000000',
//                 prefixIcon: Icons.phone_outlined,
//                 keyboardType: TextInputType.phone,
//                 validator: controller.validatePhone,
//               ),
//               SizedBox(height: 10),
//
//               // Date of Birth Field
//               CustomTextField(
//                 controller: controller.dobController,
//                 hintText: 'Date of birth',
//                 prefixIcon: Icons.calendar_today_outlined,
//                 readOnly: true,
//                 onTap: () => controller.selectDateOfBirth(context),
//                 validator: (value) => controller.validateRequired(value, 'Date of birth'),
//               ),
//               SizedBox(height: 10),
//
//               // Password Field
//               Obx(() => CustomTextField(
//                 controller: controller.passwordController,
//                 hintText: 'Password',
//                 prefixIcon: Icons.lock_outline,
//                 obscureText: !controller.isPasswordVisible.value,
//                 suffixIcon: IconButton(
//                   icon: Icon(
//                     controller.isPasswordVisible.value
//                         ? Icons.visibility_outlined
//                         : Icons.visibility_off_outlined,
//                     color: Colors.grey,
//                   ),
//                   onPressed: controller.togglePasswordVisibility,
//                 ),
//                 validator: controller.validatePassword,
//               )),
//               SizedBox(height: 10),
//
//               // Gender Selector
//               GenderSelector(controller: controller),
//               SizedBox(height: 10),
//
//               // Let's Get Started Button
//               Obx(() => CustomButton(
//                 text: "Let's Get Started",
//                 isLoading: controller.isLoading.value,
//                 onPressed: controller.isFormValid.value ? controller.signUp : null,
//               )),
//               SizedBox(height: 8),
//
//               // Terms and Conditions
//               RichText(
//                 text: TextSpan(
//                   text: 'By creating an account, You agree to our ',
//                   style: TextStyle(color: Colors.grey[600], fontSize: 14),
//                   children: [
//                     TextSpan(
//                       text: 'Terms & Conditions',
//                       style: TextStyle(color: Colors.red),
//                     ),
//                     TextSpan(
//                       text: ' and agree to ',
//                       style: TextStyle(color: Colors.grey[600]),
//                     ),
//                     TextSpan(
//                       text: 'Privacy Policy',
//                       style: TextStyle(color: Colors.red),
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
//
// // lib/app/modules/signup/widgets/custom_text_field.dart
// // import 'package:flutter/material.dart';
//
// class CustomTextField extends StatelessWidget {
//   final TextEditingController controller;
//   final String hintText;
//   final IconData prefixIcon;
//   final Widget? suffixIcon;
//   final bool obscureText;
//   final bool readOnly;
//   final TextInputType keyboardType;
//   final String? Function(String?)? validator;
//   final VoidCallback? onTap;
//
//   const CustomTextField({
//     super.key,
//     required this.controller,
//     required this.hintText,
//     required this.prefixIcon,
//     this.suffixIcon,
//     this.obscureText = false,
//     this.readOnly = false,
//     this.keyboardType = TextInputType.text,
//     this.validator,
//     this.onTap,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return TextFormField(
//       controller: controller,
//       obscureText: obscureText,
//       readOnly: readOnly,
//       keyboardType: keyboardType,
//       validator: validator,
//       onTap: onTap,
//       decoration: InputDecoration(
//         hintText: hintText,
//         hintStyle: TextStyle(color: Colors.grey[500]),
//         prefixIcon: Icon(prefixIcon, color: Colors.grey[500]),
//         suffixIcon: suffixIcon,
//         filled: true,
//         fillColor: Colors.grey[50],
//         border: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(12),
//           borderSide: BorderSide(color: Colors.grey[300]!),
//         ),
//         enabledBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(12),
//           borderSide: BorderSide(color: Colors.grey[300]!),
//         ),
//         focusedBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(12),
//           borderSide: BorderSide(color: Colors.blue),
//         ),
//         errorBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(12),
//           borderSide: BorderSide(color: Colors.red),
//         ),
//         focusedErrorBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(12),
//           borderSide: BorderSide(color: Colors.red),
//         ),
//       ),
//     );
//   }
// }
//
// // lib/app/modules/signup/widgets/gender_selector.dart
// // import 'package:flutter/material.dart';
// // import 'package:get/get.dart';
// // import '../controllers/signup_controller.dart';
//
// class GenderSelector extends StatelessWidget {
//   final SignupController controller;
//
//   const GenderSelector({super.key, required this.controller});
//
//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         SizedBox(height: 5),
//         Center(
//           child: Text(
//             'Gender',
//             style: TextStyle(
//               fontSize: 16,
//               fontWeight: FontWeight.w500,
//               color: Colors.black,
//             ),
//           ),
//         ),
//         Obx(() => Row(
//           children: [
//             Expanded(
//               child: GestureDetector(
//                 onTap: () => controller.selectGender('Male'),
//                 child: Container(
//                   // padding: EdgeInsets.symmetric(vertical: 12),
//                   // decoration: BoxDecoration(
//                   //   color: controller.selectedGender.value == 'Male'
//                   //       ? Colors.blue.withOpacity(0.1)
//                   //       : Colors.transparent,
//                   //   border: Border.all(
//                   //     color: controller.selectedGender.value == 'Male'
//                   //         ? Colors.blue
//                   //         : Colors.grey[300]!,
//                   //   ),
//                   //   borderRadius: BorderRadius.circular(12),
//                   // ),
//                   child: Row(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       Radio<String>(
//                         value: 'Male',
//                         groupValue: controller.selectedGender.value,
//                         onChanged: (value) => controller.selectGender(value!),
//                         activeColor: Colors.blue,
//                       ),
//                       Text(
//                         'Male',
//                         style: TextStyle(
//                           color: controller.selectedGender.value == 'Male'
//                               ? Colors.blue
//                               : Colors.grey[600],
//                           fontWeight: FontWeight.w500,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ),
//             // SizedBox(width: ),
//             Expanded(
//               child: GestureDetector(
//                 onTap: () => controller.selectGender('Female'),
//                 child: Container(
//                   // padding: EdgeInsets.symmetric(vertical: 12),
//                   // decoration: BoxDecoration(
//                   //   color: controller.selectedGender.value == 'Female'
//                   //       ? Colors.pink.withOpacity(0.1)
//                   //       : Colors.transparent,
//                   // border: Border.all(
//                   //   color: controller.selectedGender.value == 'Female'
//                   //       ? Colors.pink
//                   //       : Colors.grey[300]!,
//                   // ),
//                   // borderRadius: BorderRadius.circular(24),
//                   // ),
//                   child: Row(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       Radio<String>(
//                         value: 'Female',
//                         groupValue: controller.selectedGender.value,
//                         onChanged: (value) => controller.selectGender(value!),
//                         activeColor: Colors.pink,
//                       ),
//                       Text(
//                         'Female',
//                         style: TextStyle(
//                           color: controller.selectedGender.value == 'Female'
//                               ? Colors.pink
//                               : Colors.grey[600],
//                           fontWeight: FontWeight.w500,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ),
//           ],
//         )),
//       ],
//     );
//   }
// }
//
// // lib/app/modules/signup/widgets/custom_button.dart
// // import 'package:flutter/material.dart';
//
// class CustomButton extends StatelessWidget {
//   final String text;
//   final VoidCallback? onPressed;
//   final bool isLoading;
//
//   const CustomButton({
//     super.key,
//     required this.text,
//     this.onPressed,
//     this.isLoading = false,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return SizedBox(
//       width: double.infinity,
//       height: 50,
//       child: ElevatedButton(
//         onPressed: isLoading ? null : onPressed,
//         style: ElevatedButton.styleFrom(
//           backgroundColor: onPressed != null ? Colors.red : Colors.grey[300],
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(12),
//           ),
//           elevation: 0,
//         ),
//         child: isLoading
//             ? SizedBox(
//           height: 20,
//           width: 20,
//           child: CircularProgressIndicator(
//             strokeWidth: 2,
//             valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
//           ),
//         )
//             : Text(
//           text,
//           style: TextStyle(
//             color: onPressed != null ? Colors.white : Colors.grey[600],
//             fontSize: 16,
//             fontWeight: FontWeight.w600,
//           ),
//         ),
//       ),
//     );
//   }
// }
//
//
// lib/app/routes/app_routes.dart
//
//
//
//
//
//
//
//
//
//
//
//
//
//
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:get/get.dart';
//
//
//
// abstract class AppRoutes {
//   static const LOGIN = '/login';
//   static const SIGNUP = '/signup';
//   static const FORGOT_PASSWORD = '/forgot-password';
// }
//
// // lib/app/routes/app_pages.dart
// // import 'package:get/get.dart';
// // import '../modules/login/bindings/login_binding.dart';
// // import '../modules/login/views/login_view.dart';
// // import '../modules/signup/bindings/signup_binding.dart';
// // import '../modules/signup/views/signup_view.dart';
// // import 'app_routes.dart';
//
// class AppPages {
//   static const INITIAL = AppRoutes.LOGIN;
//
//   static final routes = [
//     GetPage(
//       name: AppRoutes.LOGIN,
//       page: () => LoginView(),
//       binding: LoginBinding(),
//     ),
//     // GetPage(
//     //   name: AppRoutes.SIGNUP,
//     //   // page: () => SignupView(),
//     //   // binding: SignupBinding(),
//     // ),
//   ];
// }
//
// // lib/app/data/models/login_model.dart
// class LoginModel {
//   final String email;
//   final String password;
//   final bool rememberMe;
//
//   LoginModel({
//     required this.email,
//     required this.password,
//     this.rememberMe = false,
//   });
//
//   Map<String, dynamic> toJson() {
//     return {
//       'email': email,
//       'password': password,
//       'rememberMe': rememberMe,
//     };
//   }
//
//   factory LoginModel.fromJson(Map<String, dynamic> json) {
//     return LoginModel(
//       email: json['email'] ?? '',
//       password: json['password'] ?? '',
//       rememberMe: json['rememberMe'] ?? false,
//     );
//   }
// }
//
// // lib/app/data/providers/auth_provider.dart
// // import 'package:get/get.dart';
// // import '../main.dart';
// // import '../models/login_model.dart';
//
// class AuthProvider extends GetConnect {
//   @override
//   void onInit() {
//     httpClient.baseUrl = 'https://your-api-base-url.com';
//     httpClient.timeout = Duration(seconds: 30);
//   }
//
//   Future<Response> login(LoginModel loginData) async {
//     try {
//       return await post('/auth/login', loginData.toJson());
//     } catch (e) {
//       return Response(statusCode: 500, body: {'error': e.toString()});
//     }
//   }
//
//   Future<Response> forgotPassword(String email) async {
//     try {
//       return await post('/auth/forgot-password', {'email': email});
//     } catch (e) {
//       return Response(statusCode: 500, body: {'error': e.toString()});
//     }
//   }
// }
//
// // lib/app/data/repositories/auth_repository.dart
// // import 'package:get/get.dart';
// // import '../models/login_model.dart';
// // import '../providers/auth_provider.dart';
//
// class AuthRepository {
//   final AuthProvider _authProvider = Get.find<AuthProvider>();
//
//   Future<bool> login(LoginModel loginData) async {
//     try {
//       final response = await _authProvider.login(loginData);
//       return response.statusCode == 200;
//     } catch (e) {
//       print('Repository Error: $e');
//       return false;
//     }
//   }
//
//   Future<bool> forgotPassword(String email) async {
//     try {
//       final response = await _authProvider.forgotPassword(email);
//       return response.statusCode == 200;
//     } catch (e) {
//       print('Repository Error: $e');
//       return false;
//     }
//   }
// }
//
// // lib/app/modules/login/controllers/login_controller.dart
// // import 'package:flutter/material.dart';
// // import 'package:get/get.dart';
// // import '../../../data/models/login_model.dart';
// // import '../../../data/repositories/auth_repository.dart';
// // import '../../../routes/app_routes.dart';
//
// class LoginController extends GetxController {
//   final AuthRepository _authRepository = Get.find<AuthRepository>();
//
//   // Form Controllers
//   final emailController = TextEditingController();
//   final passwordController = TextEditingController();
//
//   // Observable variables
//   var isLoading = false.obs;
//   var isPasswordVisible = false.obs;
//   var rememberMe = false.obs;
//   var agreeToTerms = false.obs;
//   var isFormValid = false.obs;
//
//   // Form Key
//   final formKey = GlobalKey<FormState>();
//
//   @override
//   void onInit() {
//     super.onInit();
//
//     // Add listeners to validate form
//     emailController.addListener(_validateForm);
//     passwordController.addListener(_validateForm);
//   }
//
//   void _validateForm() {
//     isFormValid.value = emailController.text.isNotEmpty &&
//         passwordController.text.isNotEmpty;
//   }
//
//   void togglePasswordVisibility() {
//     isPasswordVisible.value = !isPasswordVisible.value;
//   }
//
//   void toggleRememberMe() {
//     rememberMe.value = !rememberMe.value;
//   }
//
//   void toggleAgreeToTerms() {
//     agreeToTerms.value = !agreeToTerms.value;
//   }
//
//   String? validateEmail(String? value) {
//     if (value == null || value.isEmpty) {
//       return 'Email is required';
//     }
//     if (!GetUtils.isEmail(value)) {
//       return 'Please enter a valid email';
//     }
//     return null;
//   }
//
//   String? validatePassword(String? value) {
//     if (value == null || value.isEmpty) {
//       return 'Password is required';
//     }
//     if (value.length < 6) {
//       return 'Password must be at least 6 characters';
//     }
//     return null;
//   }
//
//   Future<void> login() async {
//     if (!formKey.currentState!.validate()) return;
//
//     if (!agreeToTerms.value) {
//       Get.snackbar(
//         'Terms & Conditions',
//         'Please agree to Terms & Conditions and Privacy Policy',
//         snackPosition: SnackPosition.BOTTOM,
//         backgroundColor: Colors.red,
//         colorText: Colors.white,
//       );
//       return;
//     }
//
//     isLoading.value = true;
//
//     try {
//       final loginData = LoginModel(
//         email: emailController.text.trim(),
//         password: passwordController.text.trim(),
//         rememberMe: rememberMe.value,
//       );
//
//       final success = await _authRepository.login(loginData);
//
//       if (success) {
//         Get.snackbar(
//           'Success',
//           'Login successful!',
//           snackPosition: SnackPosition.BOTTOM,
//           backgroundColor: Colors.green,
//           colorText: Colors.white,
//         );
//         // Navigate to dashboard or home
//       } else {
//         Get.snackbar(
//           'Error',
//           'Invalid email or password',
//           snackPosition: SnackPosition.BOTTOM,
//           backgroundColor: Colors.red,
//           colorText: Colors.white,
//         );
//       }
//     } catch (e) {
//       Get.snackbar(
//         'Error',
//         'An error occurred. Please try again.',
//         snackPosition: SnackPosition.BOTTOM,
//         backgroundColor: Colors.red,
//         colorText: Colors.white,
//       );
//     } finally {
//       isLoading.value = false;
//     }
//   }
//
//   void goToSignup() {
//     Get.toNamed(AppRoutes.SIGNUP);
//   }
//
//   void goToForgotPassword() {
//     // You can implement forgot password screen here
//     Get.snackbar(
//       'Forgot Password',
//       'Forgot password functionality will be implemented',
//       snackPosition: SnackPosition.BOTTOM,
//     );
//   }
//
//   @override
//   void onClose() {
//     emailController.dispose();
//     passwordController.dispose();
//     super.onClose();
//   }
// }
//
// // // lib/app/modules/login/bindings/login_binding.dart
// // import 'package:get/get.dart';
// // import '../controllers/login_controller.dart';
//
// class LoginBinding extends Bindings {
//   @override
//   void dependencies() {
//     Get.lazyPut<LoginController>(
//           () => LoginController(),
//     );
//   }
// }
//
// // lib/app/modules/login/views/login_view.dart
// // import 'package:flutter/material.dart';
// // import 'package:get/get.dart';
// // import '../controllers/login_controller.dart';
// // import '../widgets/custom_text_field.dart';
// // import '../widgets/custom_button.dart';
// // import '../widgets/custom_checkbox.dart';
//
// class LoginView extends GetView<LoginController> {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       appBar: AppBar(
//         backgroundColor: Colors.transparent,
//         elevation: 0,
//         leading: IconButton(
//           icon: Icon(Icons.arrow_back_ios, color: Colors.black),
//           onPressed: () => Get.back(),
//         ),
//       ),
//       body: SingleChildScrollView(
//         padding: EdgeInsets.symmetric(horizontal: 35, vertical:10),
//         child: Form(
//           key: controller.formKey,
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Center(
//                 child: Text(
//                   'Welcome Back!',
//                   style: TextStyle(
//                     fontSize: 28,
//                     fontWeight: FontWeight.bold,
//                     color: Colors.black,
//                   ),
//                 ),
//               ),
//               SizedBox(height: 8),
//               Center(
//                 child: Text(
//                   'Please login to your account',
//                   style: TextStyle(
//                     fontSize: 16,
//                     color: Colors.grey[600],
//                   ),
//                 ),
//               ),
//               SizedBox(height: 40),
//
//               // Email Field
//               CustomTextField(
//                 controller: controller.emailController,
//                 hintText: 'Enter your register email',
//                 prefixIcon: Icons.email_outlined,
//                 keyboardType: TextInputType.emailAddress,
//                 validator: controller.validateEmail,
//               ),
//               SizedBox(height: 16),
//
//               // Password Field
//               Obx(() => CustomTextField(
//                 controller: controller.passwordController,
//                 hintText: 'Password',
//                 prefixIcon: Icons.lock_outline,
//                 obscureText: !controller.isPasswordVisible.value,
//                 suffixIcon: IconButton(
//                   icon: Icon(
//                     controller.isPasswordVisible.value
//                         ? Icons.visibility_outlined
//                         : Icons.visibility_off_outlined,
//                     color: Colors.grey,
//                   ),
//                   onPressed: controller.togglePasswordVisibility,
//                 ),
//                 validator: controller.validatePassword,
//               )),
//               SizedBox(height: 20),
//
//               // Remember Me and Forgot Password Row
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   Obx(() => Row(
//                     children: [
//                       CustomCheckbox(
//                         isChecked: controller.rememberMe.value,
//                         onChanged: controller.toggleRememberMe,
//                       ),
//                       SizedBox(width: 8),
//                       Text(
//                         'Remember me',
//                         style: TextStyle(
//                           color: Colors.grey[600],
//                           fontSize: 14,
//                         ),
//                       ),
//                     ],
//                   )),
//                   GestureDetector(
//                     onTap: controller.goToForgotPassword,
//                     child: Text(
//                       'Forgot Password',
//                       style: TextStyle(
//                         color: Colors.red,
//                         fontSize: 14,
//                         fontWeight: FontWeight.w500,
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//               SizedBox(height: 40),
//
//               // Login Button
//               Obx(() => CustomButton(
//                 text: "Login",
//                 isLoading: controller.isLoading.value,
//                 onPressed: controller.isFormValid.value ? controller.login : null,
//               )),
//               SizedBox(height: 200),
//
//               // Terms and Conditions Checkbox
//               Obx(() => Row(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   CustomCheckbox(
//                     isChecked: controller.agreeToTerms.value,
//                     onChanged: controller.toggleAgreeToTerms,
//                   ),
//                   SizedBox(width: 8),
//                   Expanded(
//                     child: RichText(
//                       text: TextSpan(
//                         text: 'I agree to the ',
//                         style: TextStyle(color: Colors.grey[600], fontSize: 14),
//                         children: [
//                           TextSpan(
//                             text: 'Terms & Conditions',
//                             style: TextStyle(color: Colors.red),
//                           ),
//                           TextSpan(
//                             text: ' and ',
//                             style: TextStyle(color: Colors.grey[600]),
//                           ),
//                           TextSpan(
//                             text: 'Privacy Policy',
//                             style: TextStyle(color: Colors.red),
//                           ),
//                           TextSpan(
//                             text: ' to be able to ',
//                             style: TextStyle(color: Colors.grey[600]),
//                           ),
//                           TextSpan(
//                             text: 'sign-in',
//                             style: TextStyle(color: Colors.red),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                 ],
//               )),
//               SizedBox(height: 30),
//
//               // Don't have an account
//               Center(
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     Text(
//                       "Don't have an account? ",
//                       style: TextStyle(
//                         color: Colors.grey[600],
//                         fontSize: 14,
//                       ),
//                     ),
//                     GestureDetector(
//                       onTap: controller.goToSignup,
//                       child: Text(
//                         'Register here',
//                         style: TextStyle(
//                           color: Colors.red,
//                           fontSize: 14,
//                           fontWeight: FontWeight.w500,
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
//
// // // lib/app/modules/login/widgets/custom_text_field.dart
// // import 'package:flutter/material.dart';
// // import 'package:get/get.dart';
//
// class CustomTextField extends StatelessWidget {
//   final TextEditingController controller;
//   final String hintText;
//   final IconData prefixIcon;
//   final Widget? suffixIcon;
//   final bool obscureText;
//   final TextInputType keyboardType;
//   final String? Function(String?)? validator;
//
//   const CustomTextField({
//     Key? key,
//     required this.controller,
//     required this.hintText,
//     required this.prefixIcon,
//     this.suffixIcon,
//     this.obscureText = false,
//     this.keyboardType = TextInputType.text,
//     this.validator,
//   }) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     return TextFormField(
//       controller: controller,
//       obscureText: obscureText,
//       keyboardType: keyboardType,
//       validator: validator,
//       decoration: InputDecoration(
//         hintText: hintText,
//         hintStyle: TextStyle(color: Colors.grey[500]),
//         prefixIcon: Icon(prefixIcon, color: Colors.grey[500]),
//         suffixIcon: suffixIcon,
//         filled: true,
//         fillColor: Colors.grey[50],
//         border: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(12),
//           borderSide: BorderSide(color: Colors.grey[300]!),
//         ),
//         enabledBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(12),
//           borderSide: BorderSide(color: Colors.grey[300]!),
//         ),
//         focusedBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(12),
//           borderSide: BorderSide(color: Colors.blue),
//         ),
//         errorBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(12),
//           borderSide: BorderSide(color: Colors.red),
//         ),
//         focusedErrorBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(12),
//           borderSide: BorderSide(color: Colors.red),
//         ),
//       ),
//     );
//   }
// }
//
// // lib/app/modules/login/widgets/custom_button.dart
// // import 'package:flutter/material.dart';
//
// class CustomButton extends StatelessWidget {
//   final String text;
//   final VoidCallback? onPressed;
//   final bool isLoading;
//
//   const CustomButton({
//     Key? key,
//     required this.text,
//     this.onPressed,
//     this.isLoading = false,
//   }) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     return SizedBox(
//       width: double.infinity,
//       height: 50,
//       child: ElevatedButton(
//         onPressed: isLoading ? null : onPressed,
//         style: ElevatedButton.styleFrom(
//           backgroundColor: onPressed != null ? Colors.red : Colors.grey[300],
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(12),
//           ),
//           elevation: 0,
//         ),
//         child: isLoading
//             ? SizedBox(
//           height: 20,
//           width: 20,
//           child: CircularProgressIndicator(
//             strokeWidth: 2,
//             valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
//           ),
//         )
//             : Text(
//           text,
//           style: TextStyle(
//             color: onPressed != null ? Colors.white : Colors.grey[600],
//             fontSize: 16,
//             fontWeight: FontWeight.w600,
//           ),
//         ),
//       ),
//     );
//   }
// }
//
// // lib/app/modules/login/widgets/custom_checkbox.dart
// // import 'package:flutter/material.dart';
// // import 'package:get/get.dart';
//
// class CustomCheckbox extends StatelessWidget {
//   final bool isChecked;
//   final VoidCallback onChanged;
//
//   const CustomCheckbox({
//     Key? key,
//     required this.isChecked,
//     required this.onChanged,
//   }) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: onChanged,
//       child: Container(
//         width: 20,
//         height: 20,
//         decoration: BoxDecoration(
//           color: isChecked ? Colors.red : Colors.transparent,
//           border: Border.all(
//             color: isChecked ? Colors.red : Colors.grey[400]!,
//             width: 2,
//           ),
//           borderRadius: BorderRadius.circular(4),
//         ),
//         child: isChecked
//             ? Icon(
//           Icons.check,
//           color: Colors.white,
//           size: 14,
//         )
//             : null,
//       ),
//     );
//   }
// }
//
// // lib/main.dart
// // import 'package:flutter/material.dart';
// // import 'package:get/get.dart';
// // import 'app/routes/app_pages.dart';
// // import 'app/routes/app_routes.dart';
// // import 'app/data/services/dependency_injection.dart';
//
// void main() {
//   DependencyInjection.init();
//   runApp(MyApp());
// }
//
// class MyApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return GetMaterialApp(
//       title: 'Flutter Login',
//       theme: ThemeData(
//         primarySwatch: Colors.blue,
//         visualDensity: VisualDensity.adaptivePlatformDensity,
//       ),
//       initialRoute: AppRoutes.LOGIN,
//       getPages: AppPages.routes,
//       debugShowCheckedModeBanner: false,
//     );
//   }
// }
//
// // lib/app/data/services/dependency_injection.dart
// // import 'package:get/get.dart';
// // import '../providers/auth_provider.dart';
// // import '../repositories/auth_repository.dart';
//
// class DependencyInjection {
//   static void init() {
//     Get.put<AuthProvider>(AuthProvider());
//     Get.put<AuthRepository>(AuthRepository());
//   }
// }
//
//
//
//
//
// // void main() {
// //   runApp(AsanRishtaApp());
// // }
//
// class AsanRishtaApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return GetMaterialApp(
//       title: 'Asan Rishta',
//       theme: ThemeData(
//         primarySwatch: Colors.red,
//         fontFamily: 'Roboto',
//       ),
//       home: AccountTypeScreen(),
//       debugShowCheckedModeBanner: false,
//     );
//   }
// }
//
// class AccountTypeScreen extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.grey[50],
//       appBar: AppBar(
//         backgroundColor: Colors.white,
//         elevation: 0,
//         systemOverlayStyle: SystemUiOverlayStyle.dark,
//         toolbarHeight: 44,
//       ),
//       body: Padding(
//         padding: EdgeInsets.symmetric(horizontal: 24),
//         child: Column(
//           children: [
//             SizedBox(height: 40),
//             // Logo and App Name
//             Center(
//               child: Row(
//                 children: [
//                   // Logo
//                   Center(
//                     child: Container(
//                       width: 50,
//                       height: 50,
//                       decoration: BoxDecoration(
//                         shape: BoxShape.circle,
//                         border: Border.all(color: Colors.pink, width: 2),
//                       ),
//                       child: Center(
//                         child: Icon(
//                           Icons.favorite,
//                           color: Colors.pink,
//                           size: 24,
//                         ),
//                       ),
//                     ),
//                   ),
//                   SizedBox(width: 16),
//                   // App Name and Tagline
//                   Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Center(
//                         child: Text(
//                           'Asan Rishta',
//                           style: TextStyle(
//                             fontSize: 28,
//                             fontWeight: FontWeight.bold,
//                             color: Colors.pink,
//                           ),
//                         ),
//                       ),
//                       Text(
//                         'FIND MATCH EASILY, SPEND LIFE HAPPILY',
//                         style: TextStyle(
//                           fontSize: 10,
//                           color: Colors.grey[600],
//                           letterSpacing: 0.5,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ],
//               ),
//             ),
//
//             SizedBox(height: 80),
//
//             // Account Type Title
//             Text(
//               'Account Type',
//               style: TextStyle(
//                 fontSize: 28,
//                 fontWeight: FontWeight.bold,
//                 color: Colors.black87,
//               ),
//             ),
//
//             SizedBox(height: 8),
//
//             // Subtitle
//             Text(
//               'Please choose your account type',
//               style: TextStyle(
//                 fontSize: 16,
//                 color: Colors.grey[600],
//               ),
//             ),
//
//             SizedBox(height: 60),
//
//             // Create Account Button
//             Container(
//               width: double.infinity,
//               height: 50,
//               child: ElevatedButton(
//                 onPressed: () {},
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: Colors.red,
//                   foregroundColor: Colors.white,
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(8),
//                   ),
//                   elevation: 0,
//                 ),
//                 child: Text(
//                   'Create an account',
//                   style: TextStyle(
//                     fontSize: 16,
//                     fontWeight: FontWeight.w500,
//                   ),
//                 ),
//               ),
//             ),
//
//             SizedBox(height: 16),
//
//             // Login Button
//             Container(
//               width: double.infinity,
//               height: 50,
//               child: ElevatedButton(
//                 onPressed: () {},
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: Colors.black,
//                   foregroundColor: Colors.white,
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(8),
//                   ),
//                   elevation: 0,
//                 ),
//                 child: Text(
//                   'Login',
//                   style: TextStyle(
//                     fontSize: 16,
//                     fontWeight: FontWeight.w500,
//                   ),
//                 ),
//               ),
//             ),
//
//             Spacer(),
//
//             // Terms and Conditions
//             Padding(
//               padding: EdgeInsets.only(bottom: 40),
//               child: RichText(
//                 textAlign: TextAlign.center,
//                 text: TextSpan(
//                   style: TextStyle(
//                     fontSize: 12,
//                     color: Colors.grey[600],
//                   ),
//                   children: [
//                     TextSpan(text: 'By creating an account, You agree to our '),
//                     TextSpan(
//                       text: 'Terms & Conditions',
//                       style: TextStyle(
//                         color: Colors.pink,
//                         decoration: TextDecoration.underline,
//                       ),
//                     ),
//                     TextSpan(text: ' and agree to '),
//                     TextSpan(
//                       text: 'Privacy Policy',
//                       style: TextStyle(
//                         color: Colors.pink,
//                         decoration: TextDecoration.underline,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }