import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:frontend/signup_page.dart';

// Página de inicio de sesión como un widget con estado
class LoginPage extends StatefulWidget {
  static route() => MaterialPageRoute(
        builder: (context) => const LoginPage(),
      );
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // Controladores para los campos de texto
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  // Clave para validar el formulario
  final formKey = GlobalKey<FormState>();

  // Variable para mostrar si está cargando
  bool isLoading = false;

  // Libera los controladores cuando la página se destruye
  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  // Función para iniciar sesión con email y contraseña
  Future<void> loginUserWithEmailAndPassword() async {
    if (!formKey.currentState!.validate()) return;

    setState(() => isLoading = true);
    try {
      UserCredential userCredential =
          await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );
      print(
          'Inicio de sesión exitoso: ${userCredential.user?.email}, UID: ${userCredential.user?.uid}');

      emailController.clear();
      passwordController.clear();

      if (mounted) {
        Navigator.pushReplacementNamed(context, '/home');
      }
    } on FirebaseAuthException catch (e) {
      print('Error al iniciar sesión: ${e.code} - ${e.message}');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message ?? 'Error al iniciar sesión')),
      );
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false, // Elimina la flecha de "atrás"
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 20.0, bottom: 20.0),
                child: Image.asset(
                  'assets/img/candado.png',
                  width: 200,
                  height: 200,
                  fit: BoxFit.contain,
                ),
              ),
              const Text(
                'Iniciar Sesión.',
                style: TextStyle(
                  fontSize: 50,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 30),
              Form(
                key: formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: emailController,
                      decoration: const InputDecoration(hintText: 'Correo'),
                      validator: (value) {
                        if (value == null || value.isEmpty) return 'Ingresa un correo';
                        if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                          return 'Correo inválido';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 15),
                    TextFormField(
                      controller: passwordController,
                      decoration: const InputDecoration(hintText: 'Contraseña'),
                      obscureText: true,
                      validator: (value) {
                        if (value == null || value.isEmpty) return 'Ingresa una contraseña';
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: isLoading ? null : loginUserWithEmailAndPassword,
                      child: isLoading
                          ? const CircularProgressIndicator(color: Color.fromARGB(255, 255, 149, 28))
                          : const Text(
                              'INICIAR SESIÓN',
                              style: TextStyle(fontSize: 16, color: Colors.white),
                            ),
                    ),
                    const SizedBox(height: 20),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(context, SignUpPage.route());
                      },
                      child: RichText(
                        text: TextSpan(
                          text: '¿No tienes una cuenta? ',
                          style: Theme.of(context).textTheme.titleMedium,
                          children: [
                            TextSpan(
                              text: 'Registrarse',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}