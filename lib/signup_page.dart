import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:frontend/login_page.dart';

// Página de registro como un widget con estado
class SignUpPage extends StatefulWidget {
  // Método estático para crear una ruta hacia esta página
  static route() => MaterialPageRoute(
        builder: (context) => const SignUpPage(),
      );
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
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

  // Función para crear un usuario con email y contraseña
  Future<void> createUserWithEmailAndPassword() async {
    // Valida el formulario antes de proceder
    if (!formKey.currentState!.validate()) return;

    setState(() => isLoading = true); // Muestra el estado de carga
    try {
      // Crea el usuario en Firebase
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );
      // Cierra sesión inmediatamente después de registrar
      await FirebaseAuth.instance.signOut();
      
      // Muestra un mensaje de éxito
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Usuario creado exitosamente')),
      );
      
      // Redirige a la página de inicio de sesión
      Navigator.pushReplacement(context, LoginPage.route());
    } on FirebaseAuthException catch (e) {
      // Muestra un error si falla el registro
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message ?? 'Error al registrarse')),
      );
    } finally {
      setState(() => isLoading = false); // Termina el estado de carga
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Form(
          key: formKey, // Asocia la clave al formulario
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Registrarse.', // Título en español
                style: TextStyle(
                  fontSize: 50,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: emailController,
                decoration: const InputDecoration(hintText: 'Correo'), // Texto en español
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
                decoration: const InputDecoration(hintText: 'Contraseña'), // Texto en español
                obscureText: true, // Oculta la contraseña
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Ingresa una contraseña';
                  if (value.length < 6) return 'Mínimo 6 caracteres';
                  return null;
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: isLoading ? null : createUserWithEmailAndPassword,
                child: isLoading
                    ? const CircularProgressIndicator(color:  Color.fromARGB(255, 255, 149, 28))
                    : const Text(
                        'REGISTRARSE', // Botón en español
                        style: TextStyle(fontSize: 16, color: Colors.white),
                      ),
              ),
              const SizedBox(height: 20),
              GestureDetector(
                onTap: () {
                  Navigator.push(context, LoginPage.route()); // Navega a inicio de sesión
                },
                child: RichText(
                  text: TextSpan(
                    text: '¿Ya tienes una cuenta? ', // Texto en español
                    style: Theme.of(context).textTheme.titleMedium,
                    children: [
                      TextSpan(
                        text: 'Iniciar Sesión', // Texto en español
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
      ),
    );
  }
}