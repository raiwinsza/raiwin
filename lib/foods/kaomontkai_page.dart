import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart'; // เพิ่มสำหรับเปิด Google Maps

import '../models/cart.dart';

class KaomontkaiPage extends StatefulWidget {
  const KaomontkaiPage({super.key});

  @override
  State<KaomontkaiPage> createState() => _KaomontkaiPageState();
}

class _KaomontkaiPageState extends State<KaomontkaiPage> {
  late YoutubePlayerController _ytController;

  final int price = 50;
  int quantity = 1; 
  final TextEditingController commentCtrl = TextEditingController();
  int totalPrice = 50;

  final double shopLatitude = 18.28966;
  final double shopLongitude = 99.49139;

  final MapController _mapController = MapController();

  @override
  void initState() {
    super.initState();
    final videoId = YoutubePlayer.convertUrlToId('https://youtu.be/7M9PLNgzuYI?si=sAZQPY4nnOJX0F9_');
    _ytController = YoutubePlayerController(
      initialVideoId: videoId ?? 'sAZQPY4nnOJX0F9',
      flags: const YoutubePlayerFlags(autoPlay: false),
    );
    calcPrice();
  }

  @override
  void dispose() {
    _ytController.dispose();
    commentCtrl.dispose();
    super.dispose();
  }

  void calcPrice() {
    setState(() {
      totalPrice = quantity * price;
    });
  }

  void _increment() {
    setState(() {
      quantity++;
      calcPrice();
    });
  }

  void _decrement() {
    if (quantity > 1) {
      setState(() {
        quantity--;
        calcPrice();
      });
    }
  }

  // --- ปรับปรุง: ฟังก์ชันเปิด Google Maps แทนการวาดเส้น ---
  Future<void> _launchGoogleMaps() async {
    final String googleMapsUrl = "https://www.google.com/maps/search/?api=1&query=$shopLatitude,$shopLongitude";
    final Uri url = Uri.parse(googleMapsUrl);

    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      _showMessage("ไม่สามารถเปิดแอปแผนที่ได้");
    }
  }

  void _showMessage(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), behavior: SnackBarBehavior.floating));
  }

  void _addToCart() {
    final comment = commentCtrl.text.trim();
    Cart.addItem("ข้าวมันไก่${comment.isNotEmpty ? ' ($comment)' : ''}", price, quantity);
    _showMessage("เพิ่มข้าวมันไก่ $quantity จาน ลงตะกร้าแล้ว");
  }

  @override
  Widget build(BuildContext context) {
    final LatLng shopPoint = LatLng(shopLatitude, shopLongitude);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text("รายละเอียดเมนู", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              height: 220,
              width: double.infinity,
              decoration: const BoxDecoration(
                image: DecorationImage(image: AssetImage('assets/kaomontkai.jpg'), fit: BoxFit.cover),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("ข้าวมันไก่", style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
                      Text("฿$price", style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.deepOrangeAccent)),
                    ],
                  ),
                  const Text("สูตรดั้งเดิม ไก่นุ่ม ข้าวมันหอมกรุ่น", style: TextStyle(color: Colors.grey)),
                  const SizedBox(height: 25),

                  _buildSectionCard(
                    title: "วัตถุดิบและวิธีทำ",
                    icon: Icons.restaurant_menu,
                    child: Column(
                      children: [
                        _buildInfoRow(Icons.kitchen, "วัตถุดิบหลัก: ไก่สด, ข้าวหอม, ขิง, กระเทียม"),
                        _buildInfoRow(Icons.auto_stories, "สูตรลับเฉพาะ: หุงข้าวด้วยน้ำซุปไก่เข้มข้น"),
                      ],
                    ),
                  ),

                  const SizedBox(height: 15),

                  _buildSectionCard(
                    title: "วิดีโอแนะนำความอร่อย",
                    icon: Icons.play_circle_fill,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(15),
                      child: YoutubePlayer(controller: _ytController, showVideoProgressIndicator: true),
                    ),
                  ),

                  const SizedBox(height: 15),

                  _buildSectionCard(
                    title: "พิกัดร้าน",
                    icon: Icons.location_on,
                    child: Column(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(15),
                          child: SizedBox(
                            height: 180,
                            child: FlutterMap(
                              mapController: _mapController,
                              options: MapOptions(
                                center: shopPoint, // v4.0.0 ใช้ center
                                zoom: 15
                              ),
                              children: [
                                TileLayer(
                                  urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                                  subdomains: const ['a', 'b', 'c']
                                ),
                                MarkerLayer(
                                  markers: [
                                    Marker(
                                      point: shopPoint,
                                      width: 40,
                                      height: 40,
                                      builder: (_) => const Icon(Icons.location_on, color: Colors.red, size: 35) // v4.0.0 ใช้ builder
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        // ปรับปุ่มให้นำทางผ่าน Google Maps
                        TextButton.icon(
                          onPressed: _launchGoogleMaps, 
                          icon: const Icon(Icons.directions), 
                          label: const Text("นำทางด้วย Google Maps")
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 25),

                  const Text("ระบุรายละเอียด", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 15),
                  
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("จำนวน", style: TextStyle(fontSize: 16)),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(30),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: Row(
                          children: [
                            IconButton(onPressed: _decrement, icon: const Icon(Icons.remove_circle_outline, color: Colors.orange)),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 12),
                              child: Text("$quantity", style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                            ),
                            IconButton(onPressed: _increment, icon: const Icon(Icons.add_circle_outline, color: Colors.orange)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 20),
                  
                  TextField(
                    controller: commentCtrl,
                    decoration: InputDecoration(
                      hintText: "หมายเหตุ (เช่น ไม่เอาหนัง, พิเศษเนื้อ...)",
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
                      filled: true,
                      fillColor: Colors.white,
                      prefixIcon: const Icon(Icons.edit_note, color: Colors.grey),
                    ),
                  ),

                  const SizedBox(height: 25),

                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text("ยอดรวมรายการนี้", style: TextStyle(fontSize: 16)),
                            Text("฿$totalPrice", style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.deepOrangeAccent)),
                          ],
                        ),
                        const SizedBox(height: 15),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.deepOrangeAccent,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 15),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                            ),
                            onPressed: _addToCart,
                            icon: const Icon(Icons.shopping_basket),
                            label: const Text("ใส่ตะกร้า", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionCard({required String title, required IconData icon, required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 5)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: Colors.deepOrangeAccent),
              const SizedBox(width: 8),
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ],
          ),
          const Divider(height: 25),
          child,
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.grey),
          const SizedBox(width: 10),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 14))),
        ],
      ),
    );
  }
}