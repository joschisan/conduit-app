import 'package:flutter/material.dart';
import 'package:fpdart/fpdart.dart' hide State;
import '../widgets/async_action_button.dart';
import '../widgets/address_field.dart';
import '../utils/account.dart';
import '../utils/auth_utils.dart';
import '../core/context/app_context.dart';
import 'register_screen.dart';
import 'home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _lightningAddressController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _lightningAddressController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // Handle login button press
  Future<Either<String, Unit>> _handleLogin() async {
    return validateLightningAddress(_lightningAddressController.text.trim())
        .flatMap(
          (address) => validatePassword(_passwordController.text).map(
            (password) => AccountCredentials(
              lightningAddress: address,
              password: password,
            ),
          ),
        )
        .fold((loginError) => Future.value(left(loginError)), (
          credentials,
        ) async {
          final result = await login(credentials).run();
          return result.fold((error) => left(error), (token) {
            final appContext = AppContext(
              lightningAddress: credentials.lightningAddress,
              token: token,
            );

            // Reset the login screen
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
                const SizedBox(height: 24),
                _buildLoginButton(),
                const SizedBox(height: 16),
                _buildRegisterLink(),
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

  Widget _buildLoginButton() =>
      AsyncActionButton(text: 'Login', onPressed: _handleLogin);

  Widget _buildRegisterLink() => TextButton(
    onPressed: () {
      Navigator.of(
        context,
      ).push(MaterialPageRoute(builder: (context) => const RegisterScreen()));
    },
    child: const Text("Don't have an account? Register"),
  );
}
