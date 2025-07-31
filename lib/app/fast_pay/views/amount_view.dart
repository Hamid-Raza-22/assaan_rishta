import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:stacked/stacked.dart';

import '../../utils/app_colors.dart';
import '../../widgets/export.dart';
import '../viewmodels/amount_viewmodel.dart';

class AmountView extends StatelessWidget {
  final String amount;
  final String packageId;

  const AmountView({
    super.key,
    required this.amount,
    required this.packageId,
  });

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<AmountViewModel>.reactive(
      viewModelBuilder: () => AmountViewModel(),
      builder: (context, model, child) => Scaffold(
        backgroundColor: AppColors.whiteColor,
        appBar: AppBar(
          backgroundColor: AppColors.whiteColor,
          surfaceTintColor: AppColors.whiteColor,
          title: Text(
            "Enter Payment Details",
            style: GoogleFonts.poppins(
              color: AppColors.blackColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        body: Form(
          key: model.formKey,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                const SizedBox(height: 16),
                CustomFormField(
                  tec: model.emailTEC,
                  keyboardType: TextInputType.emailAddress,
                  hint: "Email",
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Please enter email";
                    } else {
                      return null;
                    }
                  },
                ),
                const SizedBox(height: 16),
                CustomFormField(
                  tec: model.phoneTEC,
                  keyboardType: TextInputType.phone,
                  hint: "Phone number",
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Please enter phone number";
                    } else if (!RegExp(r'^923\d{9}$').hasMatch(value)) {
                      return "Enter valid phone (923XXXXXXXXX)";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.sticky_note_2_outlined,
                      color: AppColors.primaryColor,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        "After clicking \"Pay Now\", you will be redirect to PayFast to complete your purchase securely.",
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: AppColors.blackColor,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                model.isLoading
                    ? const Center(
                        child: CircularProgressIndicator(
                          color: AppColors.primaryColor,
                        ),
                      )
                    : CustomButton(
                        text: "Pay Now",
                        isGradient: true,
                        fontColor: AppColors.whiteColor,
                        onTap: () {
                          if (model.formKey.currentState!.validate()) {
                            model.getToken(
                              context: context,
                              srtAmount: amount,
                              packageId: packageId,
                            );
                          }
                        },
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
