// The original content is temporarily commented out to allow generating a self-contained demo - feel free to uncomment later.

// import 'package:flutter/material.dart';
// import 'screens/memo_screen.dart';
// import 'services/classifier_service.dart';
//
// Future<void> main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//
//   final classifierService = ClassifierService();
//
//   await classifierService.initialize();
//
//   runApp(
//     MyApp(
//       classifierService: classifierService,
//     ),
//   );
// }
//
// class MyApp extends StatelessWidget {
//   final ClassifierService classifierService;
//
//   const MyApp({
//     super.key,
//     required this.classifierService,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       home: MemoScreen(
//         classifierService: classifierService,
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:nlpmemoflutter/src/rust/api/simple.dart';
import 'package:nlpmemoflutter/src/rust/frb_generated.dart';

Future<void> main() async {
  await RustLib.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('flutter_rust_bridge quickstart')),
        body: Center(
          child: Text(
            'Action: Call Rust `greet("Tom")`\nResult: `${greet(name: "Tom")}`',
          ),
        ),
      ),
    );
  }
}
