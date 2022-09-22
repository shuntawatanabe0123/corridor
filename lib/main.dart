import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:corridor/firebase_options.dart';
import 'package:corridor/post.dart';
import 'package:corridor/review_post.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'Chatpage.dart';

Future<void> main() async {
  // main 関数でも async が使えます
  WidgetsFlutterBinding.ensureInitialized(); // runApp 前に何かを実行したいときはこれが必要です。
  await Firebase.initializeApp(
    // これが Firebase の初期化処理です。
    options: DefaultFirebaseOptions.android,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
     // currentUser が null であればログインしていません。
   if (FirebaseAuth.instance.currentUser == null) {
     // 未ログイン
     return MaterialApp(
       theme: ThemeData(),
       home: const SignInPage(),
     );
   } else {
     // ログイン中
     return MaterialApp(
       theme: ThemeData(),
       home: const ChatPage(),
     );
   }
  }
}

class SignInPage extends StatefulWidget {
  const SignInPage({super.key});

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  Future<void> signInWithGoogle() async {
    // GoogleSignIn をして得られた情報を Firebase と関連づけることをやっています。
    final googleUser = await GoogleSignIn(scopes: ['profile', 'email']).signIn();

    final googleAuth = await googleUser?.authentication;

    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth?.accessToken,
      idToken: googleAuth?.idToken,
    );

    await FirebaseAuth.instance.signInWithCredential(credential);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('GoogleSignIn'),
      ),
      body: Center(
        child: ElevatedButton(
          child: const Text('GoogleSignIn'),
          onPressed: () async {
            await signInWithGoogle();
            // ログインが成功すると FirebaseAuth.instance.currentUser にログイン中のユーザーの情報が入ります
            print(FirebaseAuth.instance.currentUser?.displayName);

            // ログインに成功したら ChatPage に遷移します。
           // 前のページに戻らせないようにするにはpushAndRemoveUntilを使います。
           if (mounted) {
             Navigator.of(context).pushAndRemoveUntil(
               MaterialPageRoute(builder: (context) {
                 return const ChatPage();
               }),
               (route) => false,
             );
           }
          },
        ),
      ),
    );
  }
}

final postsReference = FirebaseFirestore.instance.collection('posts').withConverter<Post>( // <> ここに変換したい型名をいれます。今回は Post です。
  fromFirestore: ((snapshot, _) { // 第二引数は使わないのでその場合は _ で不使用であることを分かりやすくしています。
    return Post.fromFirestore(snapshot); // 先ほど定期着した fromFirestore がここで活躍します。
  }),
  toFirestore: ((value, _) {
    return value.toMap(); // 先ほど適宜した toMap がここで活躍します。
  }),
);
final reviewsReference = FirebaseFirestore.instance.collection('reviews').withConverter<Review_Post>( // <> ここに変換したい型名をいれます。今回は Post です。
  fromFirestore: ((snapshot, _) { // 第二引数は使わないのでその場合は _ で不使用であることを分かりやすくしています。
    return Review_Post.fromFirestore(snapshot); // 先ほど定期着した fromFirestore がここで活躍します。
  }),
  toFirestore: ((value, _) {
    return value.toMap(); // 先ほど適宜した toMap がここで活躍します。
  }),
);


// class MyApp2 extends StatelessWidget {
//   const MyApp2({Key? key}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return const MaterialApp(
//       title: 'Flutter Google Maps Demo',
//       home: MapSample(),
//     );
//   }
// }
// class MapSample extends StatefulWidget {
//   const MapSample({Key? key}) : super(key: key);

//   @override
//   State<MapSample> createState() => MapSampleState();
// }

// class MapSampleState extends State<MapSample> {
//   Position? currentPosition;
//   late GoogleMapController _controller;
//   late StreamSubscription<Position> positionStream;
//   //初期位置
//   final CameraPosition _kGooglePlex = const CameraPosition(
//     target: LatLng(35.6690, 139.7588),
//     zoom: 18,
//   );

//   final LocationSettings locationSettings = const LocationSettings(
//     accuracy: LocationAccuracy.high, //正確性:highはAndroid(0-100m),iOS(10m)
//     distanceFilter: 100,
//   );
  
//   @override
//   void initState() {
//     super.initState();

//     //位置情報が許可されていない時に許可をリクエストする
//     Future(() async {
//       LocationPermission permission = await Geolocator.checkPermission();
//       if(permission == LocationPermission.denied){
//         await Geolocator.requestPermission();
//       }
//     });

//     //現在位置を更新し続ける
//     positionStream =
//         Geolocator.getPositionStream(locationSettings: locationSettings)
//             .listen((Position? position) {
//       currentPosition = position;
//       print(position == null
//           ? 'Unknown'
//           : '${position.latitude.toString()}, ${position.longitude.toString()}');
//     });
//   }
  


//   @override
//   Widget build(BuildContext context) {
//     return GoogleMap(
//       mapType: MapType.normal,
//       initialCameraPosition: _kGooglePlex,
//       markers: _createMarker(),
//       myLocationEnabled: true,//現在位置をマップ上に表示
//       onMapCreated: (GoogleMapController controller) {
//         _controller = controller;
//       },

//     );
//   }
// Set<Marker> _createMarker() {
//  return {
//    Marker(
//      markerId: MarkerId("marker_1"),
//      position: LatLng(35.6700, 139.7592),
//      infoWindow: InfoWindow(title: "俺のやきとり", snippet: 'https://www.oreno.co.jp/restaurant/yakitori_ginza9'),
//      onTap: () {
//          showDialog(
//                 context: context,
//                 builder: (context) {
//                   return AlertDialog(
//                     title: Text('Aの動作の確認'),
//                     content: Text("This is the content"),
//                     actions: [
//                       TextButton(
//                         child: Text("Cancel"),
//                         onPressed: () => Navigator.pop(context),
//                       ),
//                       TextButton(
//                       child: Text("OK"),
//                       onPressed: () => launchUrl(),
//                     ),
//                   ],
//                   );
//                 });
//      },
//      ),
//     Marker(
//       markerId: MarkerId("marker_2"),
//       position: LatLng(35.6710, 139.7596),
//       infoWindow: InfoWindow(title: "天ぷらとワイン"),
//        onTap: () {
//          showDialog(
//                 context: context,
//                 builder: (context) {
//                   return AlertDialog(
//                     title: Text('天ぷらとワイン'),
//                     content: Text("店舗詳細を見ますか？"),
//                     actions: [
//                       TextButton(
//                         child: Text("Cancel"),
//                         onPressed: (){
//                           // （1） 指定した画面に遷移する
//                           Navigator.push(context, MaterialPageRoute(
//                             // （2） 実際に表示するページ(ウィジェット)を指定する
//                             builder: (context) => SecondPage()
//                           ));
//                         },
//                       ),
//                       TextButton(
//                       child: Text("OK"),
//                       onPressed: () => launchUrl_2(),
//                     ),
//                   ],
//                   );
//                 });
//      },
//     ),
//  };
// }

//    Future<void> launchUrl() async {
//     final url = "https://www.oreno.co.jp/restaurant/yakitori_ginza9";
//     if (await canLaunchUrlString(url)) {
//       await launchUrlString(url);
//     } else {
//       final Error error = ArgumentError('Error launching $url');
//       throw error;
//     }
//   }
//      Future<void> launchUrl_2() async {
//     final url = "https://tabelog.com/tokyo/A1301/A130103/13250016/";
//     if (await canLaunchUrlString(url)) {
//       await launchUrlString(url);
//     } else {
//       final Error error = ArgumentError('Error launching $url');
//       throw error;
//     }
//   }

  
// }
