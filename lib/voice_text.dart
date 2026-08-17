// voice_text.dart
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:permission_handler/permission_handler.dart';

class Speakify extends StatefulWidget {
  const Speakify({super.key});

  @override
  State<Speakify> createState() => _SpeakifyState();
}

class _SpeakifyState extends State<Speakify> {
  late stt.SpeechToText speech;
  late FlutterTts flutterTts;
  TextEditingController textEditingController = TextEditingController();
  bool isListening = false;

  @override
  void initState() {
    super.initState();
    speech = stt.SpeechToText();
    flutterTts = FlutterTts();
    initializeSpeech();
    requestMicrophonePermission();
  }

  // Request microphone permission for Android
  Future<void> requestMicrophonePermission() async {
    var status = await Permission.microphone.request();
    if (!status.isGranted) {
      debugPrint("Microphone permission denied");
    }
  }

  // Initialize speech recognition
  Future<void> initializeSpeech() async {
    bool available = await speech.initialize(
      onStatus: (status) => debugPrint("Status: $status"),
      onError: (error) => debugPrint("Error: ${error.errorMsg}"),
    );
    if (!available) {
      debugPrint('Speech recognition not available');
    } else {
      debugPrint('Speech recognition initialized successfully');
    }
  }

  // Start or stop listening to speech
  void toggleListening() async {
    if (isListening) {
      await speech.stop();
      setState(() {
        isListening = false;
      });
    } else {
      await speech.listen(
        onResult: (result) {
          setState(() {
            textEditingController.text = result.recognizedWords;
          });
        },
      );
      setState(() {
        isListening = true;
      });
    }
  }

  // Convert text to speech
  Future<void> speak(String text) async {
    await flutterTts.setLanguage("en-US");
    await flutterTts.speak(text);
  }

  @override
  void dispose() {
    textEditingController.dispose();
    speech.stop();
    super.dispose();
  }

  // UI design improvements
  @override
  Widget build(BuildContext context) {
    Size mediaQuerySize = MediaQuery.of(context).size;
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Voice to Text & Text to Voice'),
          centerTitle: true,
          backgroundColor: Colors.green,
        ),
        body: SingleChildScrollView(
          reverse: true,
          physics: const BouncingScrollPhysics(),
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(height: mediaQuerySize.height * 0.1),
                  // Instructions
                  Image.asset("assets/home.png"),
                  const Text(
                    'Press the mic to start/stop listening and convert speech to text. Press "Speak Text" to hear the text aloud.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 18, color: Colors.black54),
                  ),
                  SizedBox(height: mediaQuerySize.height * 0.02),

                  // Text Input Field
                  TextFormField(
                    controller: textEditingController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      hintText: 'Please enter some text to speak it aloud',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide:
                            const BorderSide(color: Colors.green, width: 2),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide:
                            const BorderSide(color: Colors.green, width: 2),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 15, horizontal: 20),
                    ),
                  ),
                  SizedBox(height: mediaQuerySize.height * 0.02),

                  // Speak Text Button
                  ElevatedButton(
                    onPressed: () {
                      if (textEditingController.text.isNotEmpty) {
                        speak(textEditingController.text);
                      } else if (textEditingController.text.isEmpty) {
                        speak("Please enter some text to speak it aloud");
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      padding: const EdgeInsets.symmetric(
                          vertical: 15, horizontal: 40),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: const Text(
                      'Speak Text',
                      style: TextStyle(fontSize: 18, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: toggleListening,
          backgroundColor: Colors.green,
          child: Icon(
            isListening ? Icons.stop : Icons.mic,
            size: 30,
          ),
        ),
      ),
    );
  }
}
