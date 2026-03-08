import 'package:flutter/material.dart';
import 'package:location_picker_flutter_map/location_picker_flutter_map.dart';

class LocationPickerPage extends StatelessWidget {
  const LocationPickerPage({
    super.key,
    required this.onPicked,
    this.initialAddress,
  });

  final void Function(String address) onPicked;
  final String? initialAddress;

  static const String _userAgent = 'Kaarya/1.0.0 (contact@kaarya.ai)';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pick Location'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: FlutterLocationPicker(
        userAgent: _userAgent,
        initZoom: 11,
        minZoomLevel: 5,
        maxZoomLevel: 16,
        trackMyPosition: true,
        searchBarBackgroundColor: Theme.of(context).cardColor,
        selectedLocationButtonTextStyle: const TextStyle(fontSize: 18),
        mapLanguage: 'en',
        showContributorBadgeForOSM: true,
        onPicked: (pickedData) {
          onPicked(pickedData.address);
          if (context.mounted) Navigator.of(context).pop();
        },
        onError: (e) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Map error: $e')));
        },
      ),
    );
  }
}
