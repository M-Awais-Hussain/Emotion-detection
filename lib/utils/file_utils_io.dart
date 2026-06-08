// File utilities for non-web platforms
import 'dart:io';

File createFile(String path) => File(path);
Directory getSystemTemp() => Directory.systemTemp;

