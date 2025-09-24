import 'package:geolocator/geolocator.dart';

class LocationService {
  Future<Position> getUserLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) throw 'Serviço de localização desativado';

    await _validatePermission();
    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.bestForNavigation,
    );
  }

  Future<void> _validatePermission() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw 'Permissão de localização negada';
      }
    }
    if (permission == LocationPermission.deniedForever) {
      throw 'Permissão de localização permanentemente negada';
    }
  }
}
