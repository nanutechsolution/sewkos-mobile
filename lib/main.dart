// import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:kossumba_app/pages/guest_home_page.dart';
// import 'package:kossumba_app/screens/home_screen.dart';

// void main() {
//   runApp(
//     const ProviderScope(
//       child: KosSumbaApp(),
//     ),
//   );
// }

// class KosSumbaApp extends StatelessWidget {
//   const KosSumbaApp({Key? key}) : super(key: key);

//   static const primaryColor = Color(0xFF2979FF);
//   static const secondaryColor = Color(0xFF7B1FA2);

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'KosSumba',
//       debugShowCheckedModeBanner: false,
//       theme: ThemeData(
//         colorScheme: ColorScheme.fromSeed(
//           seedColor: primaryColor,
//           primary: primaryColor,
//           secondary: secondaryColor,
//         ),
//         scaffoldBackgroundColor: const Color(0xFFF5F5F5),
//         fontFamily: 'Poppins',
//         appBarTheme: const AppBarTheme(
//           backgroundColor: primaryColor,
//           elevation: 2,
//           centerTitle: true,
//           titleTextStyle: TextStyle(
//             fontFamily: 'Poppins',
//             fontWeight: FontWeight.w600,
//             fontSize: 20,
//             color: Colors.white,
//           ),
//         ),
//       ),
//       home: const SplashScreen(),
//     );
//   }
// }

// class SplashScreen extends StatefulWidget {
//   const SplashScreen({Key? key}) : super(key: key);

//   @override
//   State<SplashScreen> createState() => _SplashScreenState();
// }

// class _SplashScreenState extends State<SplashScreen>
//     with TickerProviderStateMixin {
//   late AnimationController _logoController;
//   late AnimationController _textController;
//   late Animation<double> _logoScale;
//   late Animation<double> _logoFade;
//   late Animation<double> _textFade;
//   late Animation<Offset> _textSlide;

//   @override
//   void initState() {
//     super.initState();

//     // Logo animation
//     _logoController =
//         AnimationController(vsync: this, duration: const Duration(seconds: 2));
//     _logoScale =
//         CurvedAnimation(parent: _logoController, curve: Curves.elasticOut);
//     _logoFade = CurvedAnimation(parent: _logoController, curve: Curves.easeIn);

//     // Text animation
//     _textController = AnimationController(
//         vsync: this, duration: const Duration(milliseconds: 1000));
//     _textFade = CurvedAnimation(parent: _textController, curve: Curves.easeIn);
//     _textSlide = Tween(begin: const Offset(0, 0.3), end: Offset.zero).animate(
//       CurvedAnimation(parent: _textController, curve: Curves.easeOut),
//     );

//     // Start animation sequence
//     _logoController.forward().then((_) {
//       _textController.forward();
//     });

//     // Navigate to home after delay
//     Future.delayed(const Duration(seconds: 4), () {
//       Navigator.of(context).pushReplacement(_createRoute());
//     });
//   }

//   Route _createRoute() {
//     return PageRouteBuilder(
//       pageBuilder: (context, animation, secondaryAnimation) =>
//           const GuestHomeScreen(),
//       transitionsBuilder: (context, animation, secondaryAnimation, child) {
//         var tween =
//             Tween(begin: const Offset(0.0, 1.0), end: Offset.zero).chain(
//           CurveTween(curve: Curves.easeOutCubic),
//         );
//         return SlideTransition(
//           position: animation.drive(tween),
//           child: child,
//         );
//       },
//     );
//   }

//   @override
//   void dispose() {
//     _logoController.dispose();
//     _textController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Stack(
//         children: [
//           // Animated gradient background
//           AnimatedContainer(
//             duration: const Duration(seconds: 3),
//             decoration: const BoxDecoration(
//               gradient: LinearGradient(
//                 colors: [KosSumbaApp.primaryColor, KosSumbaApp.secondaryColor],
//                 begin: Alignment.topLeft,
//                 end: Alignment.bottomRight,
//               ),
//             ),
//           ),
//           Center(
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 // Logo with shadow & bounce effect
//                 FadeTransition(
//                   opacity: _logoFade,
//                   child: ScaleTransition(
//                     scale: _logoScale,
//                     child: Container(
//                       decoration: BoxDecoration(
//                         shape: BoxShape.circle,
//                         boxShadow: [
//                           BoxShadow(
//                             color: Colors.black26,
//                             blurRadius: 15,
//                             offset: Offset(0, 5),
//                           ),
//                         ],
//                       ),
//                       child: const Icon(
//                         Icons.home_work_rounded,
//                         size: 100,
//                         color: Colors.white,
//                       ),
//                     ),
//                   ),
//                 ),
//                 const SizedBox(height: 20),
//                 const Text(
//                   "KosSumba",
//                   style: TextStyle(
//                     fontFamily: 'Poppins',
//                     fontSize: 32,
//                     fontWeight: FontWeight.bold,
//                     color: Colors.white,
//                     letterSpacing: 1.5,
//                     shadows: [
//                       Shadow(
//                         color: Colors.black26,
//                         blurRadius: 5,
//                         offset: Offset(2, 2),
//                       )
//                     ],
//                   ),
//                 ),
//                 const SizedBox(height: 12),
//                 FadeTransition(
//                   opacity: _textFade,
//                   child: SlideTransition(
//                     position: _textSlide,
//                     child: const Text(
//                       "Selamat Datang 👋\nCari kos impianmu lebih mudah!",
//                       textAlign: TextAlign.center,
//                       style: TextStyle(
//                         fontFamily: 'Poppins',
//                         fontSize: 18,
//                         fontWeight: FontWeight.w400,
//                         color: Colors.white70,
//                         letterSpacing: 0.5,
//                       ),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kossumba_app/screens/splash_screen.dart'; // Impor SplashScreen

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Kos Sumba App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF667eea)),
        useMaterial3: true,
        textTheme: GoogleFonts.poppinsTextTheme(),
      ),
      home: const SplashScreen(), // Atur SplashScreen sebagai halaman pertama
    );
  }
}
