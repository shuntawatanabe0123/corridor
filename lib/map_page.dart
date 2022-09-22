import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

import 'alertdialog.dart';
import 'my_page.dart';

class MyApp2 extends StatelessWidget {
  const MyApp2({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('マップ'),
             // actions プロパティにWidgetを与えると右端に表示されます。
        actions: [
          // tap 可能にするために InkWell を使います。
          // InkWell(
          //   onTap: () {
          //     Navigator.of(context).push(
          //       MaterialPageRoute(
          //         builder: (context) {
          //           return const MyApp2();
          //         },
          //       ),
          //     );
          //   },
          //   child: CircleAvatar(
          //     backgroundImage: NetworkImage(
          //       FirebaseAuth.instance.currentUser!.photoURL!,
          //     ),
          //   ),
          // ),SizedBox(width: 8,),
          InkWell(
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) {
                    return const MyPage();
                  },
                ),
              );
            },
            child: CircleAvatar(
              backgroundImage: NetworkImage(
                FirebaseAuth.instance.currentUser!.photoURL!,
              ),
            ),
          )
        ],
      ),
      body: MapSample(),
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
                 return DialogNew();
                });
     },
     ),
    Marker(
      markerId: MarkerId("marker_2"),
      position: LatLng(35.6710, 139.7596),
      infoWindow: InfoWindow(title: "天ぷらとワイン"),
       onTap: () {
         showDialog(
                context: context,
                builder: (context) {
                 return DialogNew2();
                });
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
     Future<void> launchUrl_2() async {
    final url = "https://tabelog.com/tokyo/A1301/A130103/13250016/";
    if (await canLaunchUrlString(url)) {
      await launchUrlString(url);
    } else {
      final Error error = ArgumentError('Error launching $url');
      throw error;
    }
  }

  
}