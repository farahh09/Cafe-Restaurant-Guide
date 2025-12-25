import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cafe_restaurant_guide/components/custom_button.dart';
import 'package:cafe_restaurant_guide/components/custom_textfield.dart';
import 'package:cafe_restaurant_guide/API/config.dart';
import 'package:cafe_restaurant_guide/screens/home_screen.dart';
import '../Providers/signup_provider.dart';
import 'package:http/http.dart' as http;



class SignupScreen extends ConsumerStatefulWidget {
  static const String routeName = 'SignupScreen';
  const SignupScreen({super.key});

  @override
  ConsumerState<SignupScreen> createState() => _SignupScreenState();
}


class _SignupScreenState extends ConsumerState<SignupScreen> {
  final formKey = GlobalKey<FormState>();
  String? nameError, emailError, passError, confirmPassError;

  void signUp() async {
    if (formKey.currentState!.validate()) {
      final name = ref.read(nameControllerProvider).text;
      final email = ref.read(emailControllerProvider).text;
      final password = ref.read(passwordControllerProvider).text;
      final confirmPassword = ref.read(confirmPasswordControllerProvider).text;
      final level = ref.read(selectedLevelProvider);
      final gender = ref.read(selectedGenderProvider);

      final url = Uri.parse('$baseUrl/api/auth/signup');
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "name": name,
          "email": email,
          "level": level,
          "gender": gender,
          "password": password,
          "confirm_password": confirmPassword,
        }),
      );

      final jsonResponse = jsonDecode(response.body);
      final errors = jsonResponse['errors'];

      setState(() {
        nameError = errors?['name'];
        emailError = errors?['email'];
        passError = errors?['password'];
        confirmPassError = errors?['confirm_password'];
      });

      if (response.statusCode == 201) {
        final user = jsonResponse['user'];
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => HomeScreen(userEmail: email),
          ),
        );
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    final nameController = ref.watch(nameControllerProvider);
    final emailController = ref.watch(emailControllerProvider);
    final passwordController = ref.watch(passwordControllerProvider);
    final confirmPasswordController = ref.watch(confirmPasswordControllerProvider);

    final selectedLevel = ref.watch(selectedLevelProvider);
    final selectedGender = ref.watch(selectedGenderProvider);

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: Container(
          margin: EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white,
            border: Border.all(color: Colors.grey.shade400),
            boxShadow: [BoxShadow(color: Colors.grey.shade300, blurRadius: 2, spreadRadius: 2,),],
          ),

          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2),
            child: IconButton(
              onPressed: () {Navigator.pop(context);},
              icon: Icon(Icons.arrow_back_ios, size: 17, color: Colors.black,),
            ),
          ),
        ),
      ),

      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                children: [

                  // Sign Up text
                  Text(
                    "Sign Up",
                    style: TextStyle(
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                        color: Colors.lightBlue.shade800
                    ),
                  ),

                  // Name (mandatory field)
                  const SizedBox(height: 10),
                  CustomTextField(
                    text_: "Name",
                    controller: nameController,
                    hintText: "Enter Your Name",
                    obscureText: false,
                    icon : Icons.person,
                    errorMessage: nameError,
                  ),


                  //Email
                  const SizedBox(height: 10),
                  CustomTextField(
                    text_: "Email",
                    controller: emailController,
                    hintText: "Enter Your Email",
                    obscureText: false,
                    icon: Icons.email,
                    errorMessage: emailError,
                  ),

                  //Gender and Level
                  const SizedBox(height: 25),
                  Row(
                    children: [
                      // //Level (4 options only {1,2,3,4} – optional field)
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(left: 40, right: 10),
                          child: DropdownButtonFormField<String>(
                            decoration: InputDecoration(
                              labelText: "Select Level",
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(25)),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(25),
                                borderSide: BorderSide(color: Colors.lightBlue.shade800, width: 2),
                              ),
                            ),
                            value: selectedLevel,
                            items: ["1", "2", "3", "4"].map((level) {
                              return DropdownMenuItem(value: level, child: Text(level));
                            }).toList(),
                            onChanged: (value) => ref.read(selectedLevelProvider.notifier).state = value,
                          ),
                        ),
                      ),

                      const SizedBox(width: 10),
                      // Gender (radio button – optional field)
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Gender", style: TextStyle(color: Colors.lightBlue.shade800)),
                            Row(
                              children: [
                                Radio(
                                  value: "Male",
                                  groupValue: selectedGender,
                                  onChanged: (value) => ref.read(selectedGenderProvider.notifier).state = value,                                  fillColor: WidgetStateProperty.resolveWith<Color>((states) {
                                  return states.contains(WidgetState.selected)
                                      ? Colors.lightBlue.shade800
                                      : Colors.grey;
                                }),
                                ),
                                const Text("Male"),

                                Radio(
                                  value: "Female",
                                  groupValue: selectedGender,
                                  onChanged: (value) => ref.read(selectedGenderProvider.notifier).state = value,                                  fillColor: WidgetStateProperty.resolveWith<Color>((states) {
                                  return states.contains(WidgetState.selected)
                                      ? Colors.lightBlue.shade800
                                      : Colors.grey;
                                }),
                                ),
                                const Text("Female"),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  //Password (at least 8 characters with at least 1 number mandatory field)
                  SizedBox(height: 10),
                  CustomTextField(
                    text_: "Password",
                    controller: passwordController,
                    hintText: "Enter Your Password",
                    obscureText: true,
                    icon: Icons.lock,
                    errorMessage: passError,

                  ),

                  //Confirm password (at least 8 characters – matching password field - mandatory field)
                  const SizedBox(height: 10),
                  CustomTextField(
                    text_: "Confirm Password",
                    controller: confirmPasswordController,
                    hintText: "Confirm Your Password",
                    obscureText: true,
                    icon: Icons.lock,
                    errorMessage: confirmPassError,

                  ),

                  //Sign Up button
                  const SizedBox(height: 10),
                  CustomButton(
                    textButton: "Sign Up",
                    onTap: signUp,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
