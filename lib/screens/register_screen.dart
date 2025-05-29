import 'package:flutter/material.dart';
import 'package:fpdart/fpdart.dart' hide State;
import '../widgets/async_action_button.dart';
import '../utils/account.dart';
import '../widgets/address_field.dart';
import '../utils/auth_utils.dart';
import '../core/context/app_context.dart';
import 'home_screen.dart';
import 'login_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _lightningAddressController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _lightningAddressController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  // Handle register button press
  Future<Either<String, Unit>> _handleRegister() async {
    return validateLightningAddress(_lightningAddressController.text.trim())
        .flatMap(
          (address) =>
              validatePassword(_passwordController.text, minLength: 6).flatMap(
                (password) => validatePasswordMatch(
                  password,
                  _confirmPasswordController.text,
                ).map(
                  (_) => AccountCredentials(
                    lightningAddress: address,
                    password: password,
                  ),
                ),
              ),
        )
        .fold((registerError) => Future.value(left(registerError)), (
          credentials,
        ) async {
          final result = await register(credentials).run();
          return result.fold((error) => left(error), (token) {
            final appContext = AppContext(
              lightningAddress: credentials.lightningAddress,
              token: token,
            );

            // Navigate to LoginScreen
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const LoginScreen()),
            );

            // Navigate to HomeScreen
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => HomeScreen(appContext: appContext),
              ),
            );

            return right(unit);
          });
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                LightningAddressField(controller: _lightningAddressController),
                const SizedBox(height: 16),
                _buildPasswordField(),
                const SizedBox(height: 16),
                _buildConfirmPasswordField(),
                const SizedBox(height: 24),
                _buildRegisterButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPasswordField() => TextFormField(
    controller: _passwordController,
    obscureText: true,
    decoration: const InputDecoration(
      labelText: 'Password',
      border: OutlineInputBorder(),
    ),
  );

  Widget _buildConfirmPasswordField() => TextFormField(
    controller: _confirmPasswordController,
    obscureText: true,
    decoration: const InputDecoration(
      labelText: 'Confirm Password',
      border: OutlineInputBorder(),
    ),
  );

  Widget _buildRegisterButton() =>
      AsyncActionButton(text: 'Register', onPressed: _handleRegister);
}
