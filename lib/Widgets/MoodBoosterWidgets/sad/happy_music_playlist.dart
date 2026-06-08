import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

void showHappyMusicPlaylistPopup(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(
          "🎵 Mood Booster: Happy Vibes Playlist",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _playlistItem(
                title: "Feel Good Pop Hits",
                url: "https://open.spotify.com/playlist/37i9dQZF1DX0XUsuxWHRQd",
              ),
              _playlistItem(
                title: "Happy Hits!",
                url: "https://open.spotify.com/playlist/37i9dQZF1DXdPec7aLTmlC",
              ),
              _playlistItem(
                title: "Good Vibes",
                url: "https://open.spotify.com/playlist/37i9dQZF1DX1BzILRveYHb",
              ),
              _playlistItem(
                title: "Mood Booster",
                url: "https://open.spotify.com/playlist/37i9dQZF1DX3rxVfibe1L0",
              ),
              _playlistItem(
                title: "Upbeat & Energetic",
                url: "https://open.spotify.com/playlist/37i9dQZF1DWUa8ZRTMdqZZ",
              ),
              _playlistItem(
                title: "Songs to Sing in the Car",
                url: "https://open.spotify.com/playlist/37i9dQZF1DWWMOmoXKqHTD",
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            child: Text("Close", style: TextStyle(color: Theme.of(context).colorScheme.primary)),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      );
    },
  );
}

Widget _playlistItem({required String title, required String url}) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 8.0),
    child: ListTile(
      leading: Icon(Icons.music_note_rounded, color: Colors.orange),
      title: Text(title),
      trailing: Icon(Icons.open_in_new, color: Colors.grey),
      onTap: () async {
        Uri uri = Uri.parse(url);
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        } else {
          debugPrint("[happy_music_playlist] Could not launch $url");
        }
      },
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      tileColor: Colors.orange[50],
    ),
  );
}
