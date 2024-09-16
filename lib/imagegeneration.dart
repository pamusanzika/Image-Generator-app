import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:typed_data';

class ImageGeneration extends StatefulWidget {
  const ImageGeneration({super.key});

  @override
  State<ImageGeneration> createState() => _ImageGenerationState();
}

class _ImageGenerationState extends State<ImageGeneration> {
  TextEditingController textEditingController = TextEditingController();
  Uint8List? imageBytes;
  bool isLoading = false;

  // Function to generate the image
  Future<void> generateImage() async {
    final String prompt = textEditingController.text.trim();
    if (prompt.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a prompt to generate an image')),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      final url = Uri.parse('https://api.stability.ai/v2beta/stable-image/generate/ultra');
      final headers = {
        'authorization': "sk-bfic7nplt2HICpBzwwZYFVSmwpPvJhDUBfv3eVcQwnJUilU2",  
        "accept": "image/*",
      };
      final request = http.MultipartRequest('POST', url)
        ..headers.addAll(headers)
        ..fields['prompt'] = prompt
        ..fields['output_format'] = 'webp';

      final response = await request.send();

      if (response.statusCode == 200) {
        final bytes = await response.stream.toBytes();
        setState(() {
          imageBytes = bytes;
          isLoading = false;
        });
      } else {
        throw Exception('Failed to generate image: ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF2E335A),
              Color(0xFF1C1B33),
            ],
            stops: [0.0162, 0.9572],
            transform: GradientRotation(168.44 * 3.14159 / 180),
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                "Text To Image Generation",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
              SizedBox(height: size.height * .05),
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: imageBytes != null
                    ? Image.memory(imageBytes!, width: size.width * .6)
                    : Image.asset('assets/placeholder.jpg', width: size.width * .6),
              ),
              SizedBox(height: size.height * .05),
            Container(
  margin: const EdgeInsets.all(10),
  child: TextField(
    controller: textEditingController,
    maxLines: 5,
    style: const TextStyle(color: Colors.white),  // Set text color to white
    decoration: InputDecoration(
      labelText: 'Enter text',
      labelStyle: const TextStyle(color: Colors.white),  // Label text color to white
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      enabledBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Colors.white),  // Border color when enabled
        borderRadius: BorderRadius.circular(12.0),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Colors.white),  // Border color when focused
        borderRadius: BorderRadius.circular(12.0),
      ),
    ),
  ),
),

              Container(
                margin: const EdgeInsets.all(10),
                child: ElevatedButton(
                  onPressed: isLoading ? null : generateImage,
                  child: isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Generate Image'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
