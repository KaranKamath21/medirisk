import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'functions.dart';

class LocationScreen extends StatefulWidget {
  final Position initialPosition;

  const LocationScreen({required this.initialPosition});

  @override
  State<LocationScreen> createState() => _LocationScreenState();
}

class _LocationScreenState extends State<LocationScreen> {
  late Stream<Position> positionStream;
  late num aqi;

  Future<void> _fetchAndSetAqi(Position position) async {
    final LocationFunctions locationFunctions = LocationFunctions();
    // Implement the logic to fetch and set AQI
    final fetchedAqi = await locationFunctions.fetchAirQuality(position);
    setState(() {
      aqi = fetchedAqi;
    });
  }

  @override
  void initState() {
    super.initState();
    positionStream = Geolocator.getPositionStream();
    aqi = 0; // Initialize aqi
    _fetchAndSetAqi(widget.initialPosition);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Location Screen'),
      ),
      body: StreamBuilder<Position>(
        stream: positionStream,
        initialData: widget.initialPosition,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.active) {
            final position = snapshot.data!;
            _fetchAndSetAqi(position);
            return Center(
              child: Text(
                'Position: ${position.latitude}, ${position.longitude}, AQI: $aqi',
              ),
            );
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}
