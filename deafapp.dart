import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:rive/rive.dart';

void main() {
  runApp(AvatarISLApp());
}

class AvatarISLApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: ISLConverter(),
    );
  }
}
// void main() {
//   runApp(AvatarISLApp());
// }

// class AvatarISLApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       debugShowCheckedModeBanner: false,
//       home: ISLConverter(),
//     );
//   }
// }

class ISLConverter extends StatefulWidget {
  @override
  _ISLConverterState createState() => _ISLConverterState();
}

class _ISLConverterState extends State<ISLConverter> {
  stt.SpeechToText _speech;
  bool _isListening = false;
  String _text = "Tap the button and start speaking";
  Artboard _riveArtboard;
  RiveAnimationController _controller;

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
    rootBundle.load('assets/isl_avatar.riv').then((data) {
      final file = RiveFile.import(data);
      final artboard = file.mainArtboard;
      _controller = SimpleAnimation('idle');
      artboard.addController(_controller);
      setState(() => _riveArtboard = artboard);
    });
  }

  void _startListening() async {
    bool available = await _speech.initialize();
    if (available) {
      setState(() => _isListening = true);
      _speech.listen(onResult: (result) {
        setState(() => _text = result.recognizedWords);
        _updateAvatar(_text);
      });
    }
  }

  void _stopListening() {
    setState(() => _isListening = false);
    _speech.stop();
  }

  void _updateAvatar(String text) {
    if (text.toLowerCase().contains("hello")) {
      _controller.isActive = false;
      _controller = SimpleAnimation('hello');
    } else if (text.toLowerCase().contains("thank you")) {
      _controller.isActive = false;
      _controller = SimpleAnimation('thank_you');
    } else {
      _controller.isActive = false;
      _controller = SimpleAnimation('idle');
    }
    _riveArtboard.addController(_controller);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Avatar-Based ISL Conversion")),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _riveArtboard != null
              ? Container(height: 300, child: Rive(artboard: _riveArtboard))
              : CircularProgressIndicator(),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(_text, style: TextStyle(fontSize: 18)),
          ),
          FloatingActionButton(
            onPressed: _isListening ? _stopListening : _startListening,
            child: Icon(_isListening ? Icons.mic_off : Icons.mic),
          ),
        ],
      ),
    );
  }
}
