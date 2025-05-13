// import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart';
// import 'dart:io';

// class PhotoScreen extends StatefulWidget {
//   const PhotoScreen({super.key});

//   @override
//   State<PhotoScreen> createState() => _PhotoScreenState();
// }

// class _PhotoScreenState extends State<PhotoScreen> {
//   File? _image;

//   Future<void> _pickImage(ImageSource source) async {
//     final picked = await ImagePicker().pickImage(source: source);
//     if (picked != null) {
//       setState(() {
//         _image = File(picked.path);
//       });

//       // Tu później: przekazanie do OCR + AI
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return SingleChildScrollView(
//       padding: const EdgeInsets.all(16),
//       child: Column(
//         children: [
//           const Text(
//             'Zrób zdjęcie lub wgraj zadanie do analizy',
//             style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
//           ),
//           const SizedBox(height: 16),
//           _image != null
//               ? Image.file(_image!)
//               : Container(
//                   height: 200,
//                   color: Colors.grey[200],
//                   child: const Center(child: Text('Brak zdjęcia')),
//                 ),
//           const SizedBox(height: 16),
//           ElevatedButton.icon(
//             onPressed: () => _pickImage(ImageSource.camera),
//             icon: const Icon(Icons.camera_alt),
//             label: const Text('Zrób zdjęcie'),
//           ),
//           const SizedBox(height: 8),
//           ElevatedButton.icon(
//             onPressed: () => _pickImage(ImageSource.gallery),
//             icon: const Icon(Icons.photo),
//             label: const Text('Wybierz z galerii'),
//           ),
//         ],
//       ),
//     );
//   }
// }
