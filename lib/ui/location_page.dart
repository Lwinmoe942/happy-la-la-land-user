import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';

import '../core/format.dart';
import '../core/theme.dart';
import '../state/app_state.dart';
import 'widgets.dart';

const shopLatitude = 16.4678628;
const shopLongitude = 97.6270787;

class LocationPage extends StatefulWidget {
  const LocationPage({super.key});

  @override
  State<LocationPage> createState() => _LocationPageState();
}

class _LocationPageState extends State<LocationPage> {
  var _satellite = true;

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<AppState>().settings;
    final open = DateTime(2026, 1, 1, settings.openHour);
    final close = DateTime(2026, 1, 1, settings.closeHour);
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      children: [
        const PageHeader(title: 'Location', subtitle: 'HAPPY LA LA LAND ကလေးကစားကွင်း'),
        ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: SizedBox(
            height: 420,
            child: Stack(
              children: [
                FlutterMap(
                  options: const MapOptions(
                    initialCenter: LatLng(shopLatitude, shopLongitude),
                    initialZoom: 17,
                  ),
                  children: [
                    if (_satellite) ...[
                      TileLayer(
                        urlTemplate:
                            'https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}',
                        userAgentPackageName: 'com.happylalaland.user',
                      ),
                      TileLayer(
                        urlTemplate:
                            'https://server.arcgisonline.com/ArcGIS/rest/services/Reference/World_Boundaries_and_Places/MapServer/tile/{z}/{y}/{x}',
                        userAgentPackageName: 'com.happylalaland.user',
                      ),
                    ] else
                      TileLayer(
                        urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                        userAgentPackageName: 'com.happylalaland.user',
                      ),
                    const MarkerLayer(
                      markers: [
                        Marker(
                          point: LatLng(shopLatitude, shopLongitude),
                          width: 48,
                          height: 48,
                          alignment: Alignment.bottomCenter,
                          child: Icon(Icons.location_on, color: AppColors.coral, size: 48),
                        ),
                      ],
                    ),
                  ],
                ),
                Positioned(
                  top: 12,
                  right: 12,
                  child: Material(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    elevation: 2,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(20),
                      onTap: () => setState(() => _satellite = !_satellite),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        child: Text(
                          _satellite ? 'Map' : 'Satellite',
                          style: const TextStyle(fontWeight: FontWeight.w800),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        const AppCard(
          child: Text(
            'HAPPY LA LA LAND',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
          ),
        ),
        const SizedBox(height: 12),
        AppCard(
          child: Row(
            children: [
              const Icon(Icons.schedule_rounded, color: AppColors.teal),
              const SizedBox(width: 8),
              Text('ဖွင့်ချိန်  ${mmTime(open)} - ${mmTime(close)}'),
            ],
          ),
        ),
      ],
    );
  }
}
