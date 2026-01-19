import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/cart.dart';

class SakuPage extends StatefulWidget {
  const SakuPage({super.key});

  @override
  State<SakuPage> createState() => _SakuPageState();
}

class _SakuPageState extends State<SakuPage> {
  late YoutubePlayerController _ytController;

  final int price = 20; 
  int quantity = 1; 
  final TextEditingController commentCtrl = TextEditingController();
  int totalPrice = 20;

  // พิกัดร้านสาคูกะทิสด
  final double shopLatitude = 18.20173367459773;
  final double shopLongitude = 99.3899034621127;

  final MapController _mapController = MapController();

  @override
  void initState() {
    super.initState();
    // วิดีโอสอนทำสาคู
    const videoUrl = 'https://youtu.be/-55G63FAM3U';
    final videoId = YoutubePlayer.convertUrlToId(videoUrl);

    _ytController = YoutubePlayerController(
      initialVideoId: videoId ?? '-55G63FAM3U',
      flags: const YoutubePlayerFlags(autoPlay: false),
    );
    _updateTotalPrice();
  }

  @override
  void dispose() {
    _ytController.dispose();
    commentCtrl.dispose();
    super.dispose();
  }

  void _updateTotalPrice() {
    setState(() {
      totalPrice = quantity * price;
    });
  }

  void _increment() {
    setState(() {
      quantity++;
      _updateTotalPrice();
    });
  }

  void _decrement() {
    if (quantity > 1) {
      setState(() {
        quantity--;
        _updateTotalPrice();
      });
    }
  }

  // ฟังก์ชันเปิด Google Maps เพื่อนำทาง
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
    Cart.addItem("สาคู${comment.isNotEmpty ? ' ($comment)' : ''}", price, quantity);
    _showMessage("เพิ่มสาคู $quantity ชุด ลงตะกร้าแล้ว");
  }

  @override
  Widget build(BuildContext context) {
    final LatLng shopPoint = LatLng(shopLatitude, shopLongitude);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F8),
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
            // ส่วนแสดงรูปภาพ (ใช้สัดส่วนที่พอเหมาะ)
            Container(
              height: 220,
              width: double.infinity,
              decoration: const BoxDecoration(
                image: DecorationImage(image: AssetImage('assets/saku.jpg'), fit: BoxFit.cover),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ชื่อและราคา
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("สาคูกะทิสด", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
                      Text("฿$price", style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.deepOrange)),
                    ],
                  ),
                  const Text("เม็ดสาคูเหนียวนุ่ม ราดน้ำกะทิหอมมัน หวานกำลังดี", style: TextStyle(color: Colors.grey, fontSize: 16)),
                  const SizedBox(height: 25),

                  // ข้อมูลเมนู
                  _buildSectionCard(
                    title: "สูตรลับความอร่อย",
                    icon: Icons.menu_book,
                    child: Column(
                      children: [
                        _buildInfoRow(Icons.check_circle_outline, "วัตถุดิบ: เม็ดสาคูแท้, กะทิคั้นสด, น้ำตาลมะพร้าวแท้"),
                        _buildInfoRow(Icons.tips_and_updates, "เคล็ดลับ: เคี่ยวน้ำกะทิด้วยไฟอ่อนจนหอมจัด"),
                      ],
                    ),
                  ),

                  const SizedBox(height: 15),

                  // วิดีโอสอนทำ
                  _buildSectionCard(
                    title: "วิดีโอแนะนำ",
                    icon: Icons.play_circle_outline,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(15),
                      child: YoutubePlayer(controller: _ytController, showVideoProgressIndicator: true),
                    ),
                  ),

                  const SizedBox(height: 15),

                  // แผนที่ร้าน
                  _buildSectionCard(
                    title: "พิกัดร้าน",
                    icon: Icons.map_outlined,
                    child: Column(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(15),
                          child: SizedBox(
                            height: 180,
                            child: FlutterMap(
                              mapController: _mapController,
                              options: MapOptions(center: shopPoint, zoom: 15),
                              children: [
                                TileLayer(urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png", subdomains: const ['a', 'b', 'c']),
                                MarkerLayer(markers: [
                                  Marker(point: shopPoint, width: 40, height: 40, builder: (_) => const Icon(Icons.location_on, color: Colors.red, size: 40)),
                                ]),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            onPressed: _launchMaps, 
                            icon: const Icon(Icons.near_me), 
                            label: const Text("นำทางด้วย Google Maps"),
                            style: OutlinedButton.styleFrom(
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 30),

                  // ส่วนการเลือกจำนวน
                  const Text("ระบุจำนวนที่ต้องการ", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 15),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(30),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: Row(
                          children: [
                            IconButton(onPressed: _decrement, icon: const Icon(Icons.remove, color: Colors.deepOrange)),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 15),
                              child: Text("$quantity", style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                            ),
                            IconButton(onPressed: _increment, icon: const Icon(Icons.add, color: Colors.deepOrange)),
                          ],
                        ),
                      ),
                      const Text("ชุด", style: TextStyle(fontSize: 18)),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // ช่องหมายเหตุ
                  TextField(
                    controller: commentCtrl,
                    decoration: InputDecoration(
                      hintText: "หมายเหตุ (เช่น แยกน้ำกะthิ, หวานน้อย)",
                      prefixIcon: const Icon(Icons.note_alt_outlined),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                  ),

                  const SizedBox(height: 30),

                  // ปุ่มเพิ่มลงตะกร้า
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(25),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 15)],
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text("ราคารวม", style: TextStyle(fontSize: 18)),
                            Text("฿$totalPrice", style: const TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: Colors.deepOrange)),
                          ],
                        ),
                        const SizedBox(height: 20),
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
                            icon: const Icon(Icons.add_shopping_cart),
                            label: const Text("เพิ่มลงตะกร้าสินค้า", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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

  // Helper Widgets
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
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: Colors.grey),
          const SizedBox(width: 10),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 14, height: 1.4))),
        ],
      ),
    );
  }
}