import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:url_launcher/url_launcher_string.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Flutter Google Maps Demo',
      home: MapSample(),
    );
  }
}

class MapSample extends StatefulWidget {
  const MapSample({Key? key}) : super(key: key);

  @override
  State<MapSample> createState() => MapSampleState();
}

class MapSampleState extends State<MapSample> {
  Position? currentPosition;
  late GoogleMapController _controller;
  late StreamSubscription<Position> positionStream;
  //初期位置
  final CameraPosition _kGooglePlex = const CameraPosition(
    target: LatLng(35.6690, 139.7588),
    zoom: 18,
  );

  final LocationSettings locationSettings = const LocationSettings(
    accuracy: LocationAccuracy.high, //正確性:highはAndroid(0-100m),iOS(10m)
    distanceFilter: 100,
  );
  
  @override
  void initState() {
    super.initState();

    //位置情報が許可されていない時に許可をリクエストする
    Future(() async {
      LocationPermission permission = await Geolocator.checkPermission();
      if(permission == LocationPermission.denied){
        await Geolocator.requestPermission();
      }
    });

    //現在位置を更新し続ける
    positionStream =
        Geolocator.getPositionStream(locationSettings: locationSettings)
            .listen((Position? position) {
      currentPosition = position;
      print(position == null
          ? 'Unknown'
          : '${position.latitude.toString()}, ${position.longitude.toString()}');
    });
  }
  


  @override
  Widget build(BuildContext context) {
    return GoogleMap(
      mapType: MapType.normal,
      initialCameraPosition: _kGooglePlex,
      markers: _createMarker(),
      myLocationEnabled: true,//現在位置をマップ上に表示
      onMapCreated: (GoogleMapController controller) {
        _controller = controller;
      },

    );
  }
Set<Marker> _createMarker() {
 return {
   Marker(
     markerId: MarkerId("marker_1"),
     position: LatLng(35.6700, 139.7592),
     infoWindow: InfoWindow(title: "俺のやきとり", snippet: 'https://www.oreno.co.jp/restaurant/yakitori_ginza9'),
     onTap: () {
         showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: Text('Aの動作の確認'),
                    content: Text("This is the content"),
                    actions: [
                      TextButton(
                        child: Text("Cancel"),
                        onPressed: () => Navigator.pop(context),
                      ),
                      TextButton(
                      child: Text("OK"),
                      onPressed: () => launchUrl(),
                    ),
                  ],
                  );
                });
     },
     ),
    Marker(
      markerId: MarkerId("marker_2"),
      position: LatLng(35.6710, 139.7596),
      // infoWindow: InfoWindow(title: "天ぷらとワイン"),
      onTap: () {
        print("Clicked"); 
      },
    ),
 };
}

   Future<void> launchUrl() async {
    final url = "https://www.oreno.co.jp/restaurant/yakitori_ginza9";
    if (await canLaunchUrlString(url)) {
      await launchUrlString(url);
    } else {
      final Error error = ArgumentError('Error launching $url');
      throw error;
    }
  }

  
}

