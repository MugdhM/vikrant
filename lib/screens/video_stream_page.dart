import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:typed_data';

class VideoStreamPage extends StatefulWidget {
  const VideoStreamPage({Key? key}) : super(key: key);

  @override
  _VideoStreamPageState createState() => _VideoStreamPageState();
}

class _VideoStreamPageState extends State<VideoStreamPage> {
  // Configuration variables
  static const String _RASPBERRY_PI_IP =
      '192.168.104.35'; // Replace with your Pi's IP
  static const int _RECONNECT_DELAY = 5; // seconds
  static const int _MAX_FRAMES_BEFORE_RESET = 2000; // Reset after 2000 frames

  // Streaming variables
  StreamController<List<int>>? _streamController;
  http.StreamedResponse? _response;
  bool _isStreaming = false;
  String _errorMessage = '';
  Uint8List? _latestFrame;

  // Diagnostic and management variables
  List<int> _accumulatedBytes = [];
  int _frameCount = 0;
  int _failedDecodeAttempts = 0;

  // Connection settings
  bool _autoReconnect = true;
  int _connectionAttempts = 0;
  static const int _MAX_CONNECTION_ATTEMPTS = 3;

  @override
  void initState() {
    super.initState();
    _initializeVideoStream();
  }

  void _resetStreamState() {
    // Reset all streaming-related state variables
    _accumulatedBytes.clear();
    _frameCount = 0;
    _failedDecodeAttempts = 0;
    _latestFrame = null;
  }

  void _initializeVideoStream() async {
    // Prevent excessive reconnection attempts
    if (_connectionAttempts >= _MAX_CONNECTION_ATTEMPTS) {
      setState(() {
        _errorMessage =
            'Max connection attempts reached. Check network/server.';
        _isStreaming = false;
      });
      return;
    }

    // Reset stream state before new connection
    _resetStreamState();

    try {
      setState(() {
        _isStreaming = true;
        _errorMessage = '';
        _connectionAttempts++;
      });

      final request = http.Request(
          'GET', Uri.parse('http://$_RASPBERRY_PI_IP:5000/video_feed'));
      _response = await request.send();

      if (_response!.statusCode == 200) {
        // Initialize StreamController here
        _streamController = StreamController<List<int>>();
        _response!.stream.listen(
          (chunk) {
            // Check if stream controller is still open before adding
            if (_streamController != null && !_streamController!.isClosed) {
              _processVideoChunk(chunk);
            }
          },
          onDone: () => _handleStreamError('Stream completed unexpectedly'),
          onError: (error) => _handleStreamError('Stream error: $error'),
        );
      } else {
        _handleStreamError('Failed to connect to video stream');
      }
    } catch (e) {
      _handleStreamError('Connection error: $e');
    }
  }

  void _processVideoChunk(List<int> chunk) {
    try {
      // Accumulate bytes and look for JPEG/image boundaries
      _accumulatedBytes.addAll(chunk);

      // Search for JPEG start and end markers
      final startMarker = [0xFF, 0xD8]; // JPEG start of image
      final endMarker = [0xFF, 0xD9]; // JPEG end of image

      while (true) {
        // Find start of image
        final startIndex = _findSequence(_accumulatedBytes, startMarker);
        if (startIndex == -1) break;

        // Find end of image
        final endIndex =
            _findSequence(_accumulatedBytes, endMarker, startIndex);
        if (endIndex == -1) break;

        // Extract complete image
        final imageBytes = _accumulatedBytes.sublist(startIndex, endIndex + 2);

        // Attempt to decode and display the image
        setState(() {
          _latestFrame = Uint8List.fromList(imageBytes);
          _frameCount++;
        });

        // Remove processed bytes
        _accumulatedBytes = _accumulatedBytes.sublist(endIndex + 2);

        // Check if we need to reset the stream
        if (_frameCount >= _MAX_FRAMES_BEFORE_RESET) {
          _handleStreamReset();
          break;
        }
      }
    } catch (e) {
      _failedDecodeAttempts++;
      print('Decode attempt failed: $e');

      // Reset accumulated bytes if too many failed attempts
      if (_failedDecodeAttempts > 10) {
        _handleStreamReset();
      }
    }
  }

  void _handleStreamReset() {
    // Close current stream
    _streamController?.close();
    _response?.stream.drain();

    // Reinitialize the stream
    _initializeVideoStream();
  }

  int _findSequence(List<int> list, List<int> sequence, [int start = 0]) {
    for (int i = start; i <= list.length - sequence.length; i++) {
      bool found = true;
      for (int j = 0; j < sequence.length; j++) {
        if (list[i + j] != sequence[j]) {
          found = false;
          break;
        }
      }
      if (found) return i;
    }
    return -1;
  }

  void _handleStreamError(String message) {
    setState(() {
      _isStreaming = false;
      _errorMessage = message;
    });

    // Close the stream controller if it exists
    _streamController?.close();
    _streamController = null;

    // Attempt to reconnect if auto-reconnect is enabled
    if (_autoReconnect) {
      Future.delayed(
          Duration(seconds: _RECONNECT_DELAY), _initializeVideoStream);
    }
  }

  Widget _buildStreamView() {
    // Null check added for _streamController
    if (_streamController == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width,
            maxHeight: 300, // Adjust height as needed
          ),
          child: _latestFrame != null
              ? Image.memory(
                  _latestFrame!,
                  gaplessPlayback: true,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return const Icon(Icons.broken_image, color: Colors.red);
                  },
                )
              : const CircularProgressIndicator(),
        ),
        // Diagnostic information
        Text('Frames received: $_frameCount'),
        Text('Stream resets: $_connectionAttempts'),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Raspberry Pi Video Stream'),
        actions: [
          // Toggle auto-reconnect
          IconButton(
            icon: Icon(_autoReconnect ? Icons.refresh : Icons.play_disabled),
            tooltip:
                _autoReconnect ? 'Auto-Reconnect: ON' : 'Auto-Reconnect: OFF',
            onPressed: () {
              setState(() {
                _autoReconnect = !_autoReconnect;
              });
            },
          ),
        ],
      ),
      body: Center(
        child: _isStreaming
            ? _buildStreamView()
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 20),
                  Text(
                    _errorMessage.isNotEmpty
                        ? _errorMessage
                        : 'Connecting to video stream...',
                    style: Theme.of(context).textTheme.titleMedium,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
      ),
    );
  }

  @override
  void dispose() {
    // Cleanup resources
    _streamController?.close();
    _response?.stream.drain();
    super.dispose();
  }
}
