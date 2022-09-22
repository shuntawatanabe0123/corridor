import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:corridor/review_post.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:url_launcher/url_launcher_string.dart';

import 'main.dart';

class DialogNew extends StatefulWidget {
  const DialogNew({super.key});

  @override
  State<DialogNew> createState() => _DialogNewState();
}
double _rating = 0;

class _DialogNewState extends State<DialogNew> {
  final controller = TextEditingController();
  Future<void> sendPost(String text) async {
 // まずは user という変数にログイン中のユーザーデータを格納します
                final user = FirebaseAuth.instance.currentUser!;

                final posterId = user.uid; // ログイン中のユーザーのIDがとれます
                final posterName = user.displayName!; // Googleアカウントの名前がとれます
                final posterImageUrl = user.photoURL!; // Googleアカウントのアイコンデータがとれます

                // 先ほど作った postsReference からランダムなIDのドキュメントリファレンスを作成します
                // doc の引数を空にするとランダムなIDが採番されます
                final newDocumentReference = reviewsReference.doc();

                final NewReviewPost = Review_Post(
                  text: text,
                  createdAt: Timestamp.now(), // 投稿日時は現在とします
                  posterName: posterName,
                  posterImageUrl: posterImageUrl,
                  posterId: posterId,
                  reference: newDocumentReference,
                );

                // 先ほど作った newDocumentReference のset関数を実行するとそのドキュメントにデータが保存されます。
                // 引数として Post インスタンスを渡します。
                // 通常は Map しか受け付けませんが、withConverter を使用したことにより Post インスタンスを受け取れるようになります。
                newDocumentReference.set(NewReviewPost);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
                    title: Text('Aの動作の確認'),
                    content: SizedBox(
                      height: 200,
                      child: Column(
                        children: [
                          Text("この店舗をレビューする"),
                          TextFormField(
                            controller: controller,
                onFieldSubmitted: (text) {
                sendPost(text);
              },
            ),
                      TextButton(
                      child: Text("店舗詳細を見る"),
                      onPressed: () => launchUrl(),
                    ),
                                      ],
                      ),
                    ),

                    actions: [
                      TextButton(
                        child: Text("戻る"),
                        onPressed: () => Navigator.pop(context),
                      ),
                      TextButton(
                      child: Text("OK"),
                      onPressed: () async{
                        final text = controller.text;
                        sendPost(text);
                        Navigator.pop(context);
                      },
                    ),
                  ],
                  );
  }
  
}

class DialogNew2 extends StatefulWidget {
  const DialogNew2({super.key});

  @override
  State<DialogNew2> createState() => _DialogNewState2();
}

class _DialogNewState2 extends State<DialogNew2> {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
                    title: Text('天ぷらとワイン'),
                    content: Column(
                      children: [
                        Text("店舗詳細を見ますか？"),
                        RatingBar(
                        glow: false,
                        allowHalfRating: true,
                        updateOnDrag: true,
                        initialRating: 5,
                        minRating: 1,
                        maxRating: 5,
                        itemCount: 5,
                        itemSize: 30,
                        itemPadding: EdgeInsets.all(2),
                        ratingWidget: RatingWidget(
                            full: Icon(Icons.star, color: Colors.amber),
                            half: Icon(Icons.star_half, color: Colors.amber),
                            empty: Icon(Icons.star_border, color: Colors.grey)),
                        onRatingUpdate: (rating) {
                          _rating = rating;
                        },
                        ),
                      ],
                    ),
                    actions: [
                      TextButton(
                        child: Text("Cancel"),
                        onPressed: () => Navigator.pop(context),
                      ),
                      TextButton(
                      child: Text("OK"),
                      onPressed: () => launchUrl_2(),
                    ),
                  ],
                  );
  }
  
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

  
