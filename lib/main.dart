import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';

void main() => runApp(const AppleMusicClone());

class AppleMusicClone extends StatelessWidget {
  const AppleMusicClone({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Apple Music Clone',
      theme: ThemeData(
        brightness: Brightness.light,
        primarySwatch: Colors.red,
        fontFamily: 'San Francisco',
      ),
      darkTheme: ThemeData(brightness: Brightness.dark),
      themeMode: ThemeMode.system,
      home: const MusicHomePage(),
    );
  }
}

class MusicHomePage extends StatefulWidget {
  const MusicHomePage({super.key});

  @override
  State<MusicHomePage> createState() => _MusicHomePageState();
}

class _MusicHomePageState extends State<MusicHomePage> {
  final AudioPlayer _player = AudioPlayer();
  List<File> _songs = [];
  File? _currentSong;
  bool _isPlaying = false;

  Future<void> _pickSongs() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.audio,
      allowMultiple: true,
    );

    if (result != null) {
      final files = result.paths.map((path) => File(path!)).toList();
      setState(() {
        _songs = files;
      });
    }
  }

  Future<void> _playSong(File file) async {
    try {
      await _player.setFilePath(file.path);
      await _player.play();
      setState(() {
        _currentSong = file;
        _isPlaying = true;
      });
    } catch (e) {
      print('Error playing file: $e');
    }
  }

  void _togglePlayPause() async {
    if (_isPlaying) {
      await _player.pause();
    } else {
      await _player.play();
    }
    setState(() {
      _isPlaying = !_isPlaying;
    });
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Library"),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _pickSongs,
          )
        ],
      ),
      body: _songs.isEmpty
          ? const Center(child: Text("No songs selected"))
          : ListView.builder(
              itemCount: _songs.length,
              itemBuilder: (context, index) {
                final song = _songs[index];
                return ListTile(
                  title: Text(song.path.split('/').last),
                  onTap: () => _playSong(song),
                );
              },
            ),
      bottomNavigationBar: _currentSong == null
          ? null
          : BottomAppBar(
              child: ListTile(
                title: Text(_currentSong!.path.split('/').last),
                trailing: IconButton(
                  icon: Icon(_isPlaying ? Icons.pause : Icons.play_arrow),
                  onPressed: _togglePlayPause,
                ),
              ),
            ),
    );
  }
}
