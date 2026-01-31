import 'package:flutter/material.dart';
import 'package:kaarya/core/widgets/my_text_form_field_widget.dart';

class UpdateProfileFormCard extends StatelessWidget {
  const UpdateProfileFormCard({
    super.key,
    required this.formKey,
    required this.fullNameController,
    required this.emailAddressController,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController fullNameController;
  final TextEditingController emailAddressController;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      elevation: 0,
      margin: const EdgeInsets.all(0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade300),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Detail Information",
              style: Theme.of(context).textTheme.titleMedium,
            ),

            SizedBox(height: 14),

            Form(
              key: formKey,
              child: Column(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Profile Picture",
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 15,
                        ),
                      ),

                      SizedBox(height: 6),

                      Text(
                        "Full Name",
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 15,
                        ),
                      ),

                      SizedBox(height: 6),

                      MyTextFormField(
                        controller: fullNameController,
                        text: "Trishan Wagle",
                        inputType: TextInputType.text,
                        validationErrorMessage: "Full name is required",
                      ),

                      SizedBox(height: 14),

                      Text(
                        "Email Address",
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 15,
                        ),
                      ),

                      SizedBox(height: 6),

                      MyTextFormField(
                        controller: emailAddressController,
                        text: "mailtotrishan@gmail.com",
                        inputType: TextInputType.emailAddress,
                        validationErrorMessage: "Email address is required",
                      ),

                      SizedBox(height: 14),

                      Text(
                        "Phone Number",
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 15,
                        ),
                      ),

                      SizedBox(height: 6),

                      MyTextFormField(
                        text: "9841XXXXXX",
                        inputType: TextInputType.text,
                        optional: true,
                      ),

                      SizedBox(height: 14),

                      Text(
                        "Full Address",
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 15,
                        ),
                      ),

                      SizedBox(height: 6),

                      MyTextFormField(
                        text: "Kathmandu-24, Dillibazar, Kathmandu, Nepal",
                        inputType: TextInputType.text,
                        optional: true,
                      ),

                      SizedBox(height: 14),

                      Text(
                        "Bio",
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 15,
                        ),
                      ),

                      SizedBox(height: 6),

                      MyTextFormField(
                        text: "Experienced Flutter Developer",
                        inputType: TextInputType.text,
                        optional: true,
                      ),

                      SizedBox(height: 14),

                      Text(
                        "Social Media",
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 15,
                        ),
                      ),

                      SizedBox(height: 6),

                      MyTextFormField(
                        text: "https://github.com/trishan9",
                        inputType: TextInputType.text,
                        optional: true,
                      ),

                      SizedBox(height: 14),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
