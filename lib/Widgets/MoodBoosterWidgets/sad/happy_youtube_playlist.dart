import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

void showHappyYoutubePlaylistPopup(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(
          "🎬 Mood Booster: Happy YouTube Videos",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Suggested TMKOC Playlist at top
              _suggestedPlaylistItem(
                title: "TMKOC Best Comedy Scenes",
                url: "https://youtube.com/playlist?list=PL6Rtnh6YJK7Yy2Skx9-qMPYPNjiilz12j&si=9NdubiMemhV7tL6C",
              ),
              SizedBox(height: 8),
              // Divider to separate suggested from regular playlists
              Divider(color: Colors.grey[400], thickness: 1),
              SizedBox(height: 8),
              // Regular happy playlists
              _playlistItem(
                title: "Happy Pop Music Mix 2024",
                url: "https://www.youtube.com/watch?v=ZbZSe6N_BXs",
              ),
              _playlistItem(
                title: "Feel Good Songs Playlist",
                url: "https://www.youtube.com/watch?v=ru0K8uYEZWw",
              ),
              _playlistItem(
                title: "Upbeat Dance Music Mix",
                url: "https://www.youtube.com/watch?v=jfKfPfyJRdk",
              ),
              _playlistItem(
                title: "Best Motivational Songs",
                url: "https://www.youtube.com/watch?v=Cvb-A1l5-qM",
              ),
              _playlistItem(
                title: "Good Vibes Lo-Fi Hip Hop",
                url: "https://www.youtube.com/watch?v=lTRiuFIWV54",
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

// Special widget for suggested playlist with badge
Widget _suggestedPlaylistItem({required String title, required String url}) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 8.0),
    child: Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange, width: 2),
        color: Colors.orange[50],
      ),
      child: ListTile(
        leading: Stack(
          children: [
            Icon(Icons.play_circle_filled, color: Colors.red, size: 32),
            Positioned(
              right: -2,
              top: -2,
              child: Container(
                padding: EdgeInsets.all(2),
                decoration: BoxDecoration(
                  color: Colors.orange,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.star, color: Colors.white, size: 12),
              ),
            ),
          ],
        ),
        title: Row(
          children: [
            Expanded(child: Text(title, style: TextStyle(fontWeight: FontWeight.w600))),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.orange,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                "SUGGESTED",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        subtitle: Text("😂 Comedy • Mood Booster", style: TextStyle(color: Colors.grey[600])),
        trailing: Icon(Icons.open_in_new, color: Colors.orange),
        onTap: () async {
          Uri uri = Uri.parse(url);
          if (await canLaunchUrl(uri)) {
            await launchUrl(uri, mode: LaunchMode.externalApplication);
          } else {
            debugPrint("[sad_youtube_playlist] Could not launch $url");
          }
        },
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),
  );
}

// Regular playlist item widget
Widget _playlistItem({required String title, required String url}) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 8.0),
    child: ListTile(
      leading: Icon(Icons.play_circle_filled, color: Colors.red),
      title: Text(title),
      trailing: Icon(Icons.open_in_new, color: Colors.grey),
      onTap: () async {
        Uri uri = Uri.parse(url);
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        } else {
          debugPrint("[sad_youtube_playlist] Could not launch $url");
        }
      },
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      tileColor: Colors.grey[100],
    ),
  );
}
