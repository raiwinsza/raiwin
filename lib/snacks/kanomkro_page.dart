import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/cart.dart';

class KanomkroPage extends StatefulWidget {
  const KanomkroPage({super.key});

  @override
  State<KanomkroPage> createState() => _KanomkroPageState();
}

class _KanomkroPageState extends State<KanomkroPage> {
  late YoutubePlayerController _ytController;

  final int price = 20; 
  int quantity = 1;
  final TextEditingController commentCtrl = TextEditingController();
  int totalPrice = 20;

  // พิกัดร้านขนมครก (ย่านสบตุ๋ย/สถานีรถไฟลำปาง ตามพิกัดที่คุณให้มา)
  final double shopLatitude = 18.262458542279873;
  final double shopLongitude = 99.46646410887065;

  final MapController _mapController = MapController();

  @override
  void initState() {
    super.initState();
    // Video: วิธีทำขนมครกชาววัง
    const videoUrl = 'https://youtu.be/wQhjnc9ElPA';
    final videoId = YoutubePlayer.convertUrlToId(videoUrl);

    _ytController = YoutubePlayerController(
      initialVideoId: videoId ?? 'wQhjnc9ElPA',
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

  // ฟังก์ชันนำทางด้วย Google Maps
  Future<void> _launchMaps() async {
    final String googleMapsUrl = "https://www.google.com/maps/search/?api=1&query=$shopLatitude,$shopLongitude";
    final Uri url = Uri.parse(googleMapsUrl);
    
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      _showMessage("ไม่สามารถเปิดแผนที่ได้");
    }
  }

  void _showMessage(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), behavior: SnackBarBehavior.floating));
  }

  void _addToCart() {
    final comment = commentCtrl.text.trim();
    Cart.addItem("ขนมครก${comment.isNotEmpty ? ' ($comment)' : ''}", price, quantity);
    _showMessage("เพิ่มขนมครก $quantity กล่อง ลงตะกร้าแล้ว");
  }

  @override
  Widget build(BuildContext context) {
    final LatLng shopPoint = LatLng(shopLatitude, shopLongitude);

    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
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
                image: DecorationImage(image: AssetImage('assets/kanomkro.jpg'), fit: BoxFit.cover),
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
                      const Text("ขนมครกชาววัง", style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
                      Text("฿$price", style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.deepOrange)),
                    ],
                  ),
                  const Text("กะทิสด หอมหวาน กรอบนอกนุ่มใน", style: TextStyle(color: Colors.grey)),
                  const SizedBox(height: 25),

                  _buildSectionCard(
                    title: "สูตรและวัตถุดิบ",
                    icon: Icons.auto_awesome,
                    child: Column(
                      children: [
                        _buildInfoRow(Icons.shopping_basket, "ส่วนผสม: แป้งข้าวเจ้า, กะทิข้น, น้ำตาลมะพร้าว, เกลือ"),
                        _buildInfoRow(Icons.restaurant, "หน้าขนม: ต้นหอม, ข้าวโพด, เผือก, ฟักทอง"),
                      ],
                    ),
                  ),

                  const SizedBox(height: 15),

                  _buildSectionCard(
                    title: "วิดีโอแนะนำ",
                    icon: Icons.video_library,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(15),
                      child: YoutubePlayer(controller: _ytController, showVideoProgressIndicator: true),
                    ),
                  ),

                  const SizedBox(height: 15),

                  _buildSectionCard(
                    title: "พิกัดร้าน & การเดินทาง",
                    icon: Icons.store_mall_directory,
                    child: Column(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(15),
                          child: SizedBox(
                            height: 180,
                            child: FlutterMap(
                              mapController: _mapController,
                              options: MapOptions(center: shopPoint, zoom: 16),
                              children: [
                                TileLayer(
                                  urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                                  subdomains: const ['a', 'b', 'c'],
                                ),
                                MarkerLayer(markers: [
                                  Marker(point: shopPoint, width: 40, height: 40, builder: (_) => const Icon(Icons.location_on, color: Colors.red, size: 40)),
                                ]),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        ElevatedButton.icon(
                          onPressed: _launchMaps, 
                          icon: const Icon(Icons.map), 
                          label: const Text("เปิด Google Maps เพื่อนำทาง"),
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.blueGrey, foregroundColor: Colors.white),
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
                      const Text("จำนวน (กล่อง)", style: TextStyle(fontSize: 16)),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(30),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: Row(
                          children: [
                            IconButton(onPressed: _decrement, icon: const Icon(Icons.remove_circle_outline, color: Colors.deepOrange)),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 12),
                              child: Text("$quantity", style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                            ),
                            IconButton(onPressed: _increment, icon: const Icon(Icons.add_circle_outline, color: Colors.deepOrange)),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  TextField(
                    controller: commentCtrl,
                    decoration: InputDecoration(
                      hintText: "หมายเหตุ (เช่น ไม่ใส่ต้นหอม, รับหน้าเผือกล้วน...)",
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
                            Text("฿$totalPrice", style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.deepOrange)),
                          ],
                        ),
                        const SizedBox(height: 15),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.deepOrange,
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
                  const SizedBox(height: 50),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- Helper Widgets ---
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
              Icon(icon, size: 20, color: Colors.deepOrange),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: Colors.grey),
          const SizedBox(width: 10),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 14))),
        ],
      ),
    );
  }
}