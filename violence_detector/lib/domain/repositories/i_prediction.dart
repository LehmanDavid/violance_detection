abstract interface class IPrediction {
  Future<Map<String, dynamic>> getPrediction(String videoPath);
}
