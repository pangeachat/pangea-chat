// Flutter imports:

import 'package:fluffychat/pangea/pages/sign_up/full_width_button.dart';
import 'package:fluffychat/pangea/pages/sign_up/pangea_login_scaffold.dart';
import 'package:fluffychat/pangea/widgets/common/pangea_logo_svg.dart';
import 'package:fluffychat/pangea/widgets/signup/tos_checkbox.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/l10n.dart';

import 'signup.dart';

class SignupWithEmailView extends StatelessWidget {
  final SignupPageController controller;
  const SignupWithEmailView(this.controller, {super.key});

  @override
  Widget build(BuildContext context) {
    return Form(
      key: controller.formKey,
      child: PangeaLoginScaffold(
        children: [
          FullWidthTextField(
            hintText: L10n.of(context).yourUsername,
            autofocus: true,
            textInputAction: TextInputAction.next,
            validator: (text) {
              if (text == null || text.isEmpty) {
                return L10n.of(context).pleaseChooseAUsername;
              }
              return null;
            },
            controller: controller.usernameController,
          ),
          FullWidthTextField(
            hintText: L10n.of(context).yourEmail,
            textInputAction: TextInputAction.next,
            keyboardType: TextInputType.emailAddress,
            validator: controller.emailTextFieldValidator,
            controller: controller.emailController,
          ),
          FullWidthTextField(
            hintText: L10n.of(context).password,
            textInputAction: TextInputAction.done,
            obscureText: true,
            validator: controller.password1TextFieldValidator,
            controller: controller.passwordController,
          ),
          TosCheckbox(controller),
          FullWidthButton(
            title: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                PangeaLogoSvg(
                  width: 20,
                  forceColor: Theme.of(context).colorScheme.onPrimary,
                ),
                const SizedBox(width: 10),
                Text(L10n.of(context).signUp),
              ],
            ),
            onPressed: controller.enableSignUp ? controller.signup : null,
            error: controller.error,
            loading: controller.loading,
            enabled: controller.enableSignUp,
          ),
        ],
      ),
    );
  }
}
