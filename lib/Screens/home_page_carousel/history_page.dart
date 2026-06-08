import '../../utils/platform_utils.dart';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import '../../model/photo_data.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  Map<String, List<PhotoData>> groupedPhotos = {};
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadPhotos();
  }

  Future<void> loadPhotos() async {
    setState(() {
      isLoading = true;
    });

    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString('photo_data');

    if (saved != null) {
      List<PhotoData> allPhotos = PhotoData.decodeList(saved);
      allPhotos.sort((a, b) => DateTime.parse(b.time).compareTo(DateTime.parse(a.time)));


      Map<String, List<PhotoData>> grouped = {};
      for (var photo in allPhotos) {
        String dateKey = DateFormat('yyyy-MM-dd').format(DateTime.parse(photo.time));
        grouped.putIfAbsent(dateKey, () => []);
        grouped[dateKey]!.add(photo);
      }

      setState(() {
        groupedPhotos = grouped;
        isLoading = false;
      });
    } else {
      setState(() {
        groupedPhotos = {};
        isLoading = false;
      });
    }
  }

  Future<void> deletePhoto(PhotoData photoToDelete) async {
    // Show confirmation dialog
    bool confirmDelete = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Photo'),
        content: const Text('Are you sure you want to delete this photo?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    ) ?? false;

    if (!confirmDelete) return;

    // Get all photos from SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString('photo_data');

    if (saved != null) {
      List<PhotoData> allPhotos = PhotoData.decodeList(saved);

      // Remove the photo to delete
      allPhotos.removeWhere((photo) =>
      photo.path == photoToDelete.path &&
          photo.time == photoToDelete.time &&
          photo.mood == photoToDelete.mood
      );

      // Save updated list back to SharedPreferences
      await prefs.setString('photo_data', PhotoData.encodeList(allPhotos));

      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Photo deleted successfully'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }

      // Reload photos
      loadPhotos();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Photo History"),
        elevation: 0,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : groupedPhotos.isEmpty
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.photo_album_outlined, size: 80, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              "No photos yet",
              style: TextStyle(fontSize: 18, color: Colors.grey[600]),
            ),
            const SizedBox(height: 8),
            Text(
              "Your photo history will appear here",
              style: TextStyle(fontSize: 14, color: Colors.grey[500]),
            ),
          ],
        ),
      )
          : ListView(
        padding: const EdgeInsets.only(bottom: 24),
        children: groupedPhotos.entries.map((entry) {
          String date = entry.key;
          List<PhotoData> photos = entry.value;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Column(  // Use Column to have multiple children
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      DateFormat('EEEE, MMMM d, yyyy').format(DateTime.parse(date)),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Divider(thickness: 2,color: Colors.black,),
                  ],
                ),
              ),
              ...photos.map((photo) {
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  elevation: 1,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () {
                      // Preview photo in full screen if needed
                      showDialog(
                        context: context,
                        builder: (context) => Dialog(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              AppBar(
                                title: Text("${photo.mood[0].toUpperCase()}${photo.mood.substring(1)}"),
                                leading: IconButton(
                                  icon: const Icon(Icons.close),
                                  onPressed: () => Navigator.of(context).pop(),
                                ),
                                actions: [
                                  IconButton(
                                    icon: const Icon(Icons.delete),
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                      deletePhoto(photo);
                                    },
                                  ),
                                ],
                              ),
                              buildImageFromPath(
                                photo.path,
                                fit: BoxFit.contain,
                              ),
                              Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Text(
                                  DateFormat('MMMM d, yyyy - hh:mm a').format(DateTime.parse(photo.time)),
                                  style: const TextStyle(fontSize: 16),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: SizedBox(
                              width: 70,
                              height: 70,
                              child: buildImageFromPath(
                                photo.path,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  photo.mood,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  DateFormat('hh:mm a').format(DateTime.parse(photo.time)),
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_outline, color: Colors.red),
                            onPressed: () => deletePhoto(photo),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              })
            ],
          );
        }).toList(),
      ),
    );
  }
}