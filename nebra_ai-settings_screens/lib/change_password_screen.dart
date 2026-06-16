import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  ChangePasswordScreenState createState() => ChangePasswordScreenState();
}

class ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final formKey = GlobalKey<FormState>();
  final currentPasswordController = TextEditingController();
  final newPasswordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  bool obscureCurrent = true;
  bool obscureNew = true;
  bool obscureConfirm = true;
  bool isLoading = false;

  Future<void> changePassword() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if(user == null || user.email == null){
        throw Exception("User email");
      }
      final isEmailUser = user.providerData.any((provider) => provider.providerId == "password",);

      if (!isEmailUser){
        throw Exception("You cannot change password");
      }
      
      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: currentPasswordController.text,
      );

      await user.reauthenticateWithCredential(credential);

      await user.updatePassword(newPasswordController.text);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Password changed successfully")),);
      currentPasswordController.clear();
      newPasswordController.clear();
      confirmPasswordController.clear();

      Navigator.pop(context);

    } on FirebaseAuthException catch (e) {
      String message = "Something went wrong";

      if(e.code == "wrong-password"){
        message = "Current password is incorrect";
      } else if(e.code == "weak-password"){
        message = "New password is too weak";
      } else if(e.code == "requires-recent-login"){
        message = "Please login again and try";
      }
      ScaffoldMessenger.of(
        context
      ).showSnackBar(SnackBar(content: Text(message)));
    } catch(e){
       ScaffoldMessenger.of(
        context
      ).showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }

        

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF003E52), Color(0xFF004A60), Color(0xFF002F4A)],
            ),
          ),      child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: CircleAvatar(
                        backgroundColor: Colors.white24,
                        child: Padding(
                          padding: EdgeInsets.only(left: 5),
      
                          child: Icon(Icons.arrow_back_ios, color: Colors.white),
                        ),
                      ),
                    ),
                    SizedBox(width: 80),
                    Text(
                      "Change password",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xff063b3b), Color(0xff0a2a66)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Form(
                    // padding: EdgeInsets.symmetric(horizontal: 20),
                    key: formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 70),
                        buildField(
                          "Current password",
                          currentPasswordController,
                          obscureCurrent,
                          () {
                            setState(() {
                              obscureCurrent = !obscureCurrent;
                            });
                          },
                        ),
                        buildField(
                          "New password",
                          newPasswordController,
                          obscureNew,
                          () {
                            setState(() {
                              obscureNew = !obscureNew;
                            });
                          },
                        ),
                        buildField(
                          "Confirm new password",
                          confirmPasswordController,
                          obscureConfirm,
                          () {
                            setState(() {
                              obscureConfirm = !obscureConfirm;
                            });
                          },
                        ),
                        Spacer(),
      
                        Center(
                          child: GestureDetector(
                            onTap: isLoading ? null :() async {
                              if (formKey.currentState!.validate()) {
                                setState(() => isLoading = true);
                                await changePassword();
                                setState(() => isLoading = false);
      
                              }
                            },
                            child: Container(
                              width: 220,
                              padding: EdgeInsets.symmetric(vertical: 10),
                              decoration: BoxDecoration(
                                color: Color(0xff02308B),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Center(
                                child: isLoading ? CircularProgressIndicator(color: Colors.white,) :
                                Text(
                                  "Save changes",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
      
                        SizedBox(height: 90),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildField(
    String title,
    TextEditingController controller,
    bool obscure,
    VoidCallback toggle,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 8),
        TextFormField(
          controller: controller,
          obscureText: obscure,
          style: TextStyle(color: Colors.white),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return "Required";
            }
            if (title == "Confirm new password" &&
                value != newPasswordController.text) {
              return "Password do not match";
            }
            return null;
          },
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white12,
            suffixIcon: IconButton(
              icon: Icon(
                obscure ? Icons.visibility_off : Icons.visibility,
                color: Colors.white70,
              ),
              onPressed: toggle,
            ),

            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        SizedBox(height: 20),
      ],
    );
  }
}
