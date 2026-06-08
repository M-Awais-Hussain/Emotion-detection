// Stub file for web - File and Directory are not available
// This file is only used when dart:io is not available

// These functions should never be called on web due to kIsWeb checks
// But we need to define them to satisfy the compiler

dynamic createFile(String path) {
  throw UnsupportedError('File operations not supported on web');
}

dynamic getSystemTemp() {
  throw UnsupportedError('Directory operations not supported on web');
}
