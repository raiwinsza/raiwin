import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/cart.dart';

class KaonaoePage extends StatefulWidget {
  const KaonaoePage({super.key});

  @override
  State<KaonaoePage> createState() => _KaonaoePageState();
}

class _KaonaoePageState extends State<KaonaoePage> {
  late YoutubePlayerController _ytController;

  final int price = 10; 
  int quantity = 1; 
  final TextEditingController commentCtrl = TextEditingController();
  int totalPrice = 10;

  // พิกัดร้านข้าวเหนียวสังขยา (ปรับตามพิกัดเดิมที่คุณระบุมา)
  final double shopLatitude = 18.283382297278465;
  final double shopLongitude = 99.46679956073392;

  final MapController _mapController = MapController();

  @override
  void initState() {
    super.initState();
    // วิดีโอสอนทำข้าวเหนียวสังขยา
    const videoUrl = 'https://www.youtube.com/watch?v=OpC053QOcLo';
    final videoId = YoutubePlayer.convertUrlToId(videoUrl);

    _ytController = YoutubePlayerController(
      initialVideoId: videoId ?? 'OpC053QOcLo',
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
    Cart.addItem("ข้าวเหนียวสังขยา${comment.isNotEmpty ? ' ($comment)' : ''}", price, quantity);
    _showMessage("เพิ่มข้าวเหนียวสังขยา $quantity ห่อ ลงตะกร้าแล้ว");
  }

  @override
  Widget build(BuildContext context) {
    final LatLng shopPoint = LatLng(shopLatitude, shopLongitude);

    return Scaffold(
      backgroundColor: const Color(0xFFFBFBFB),
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
            // ส่วนหัวรูปภาพ
            Container(
              height: 200,
              width: double.infinity,
              decoration: const BoxDecoration(
                image: DecorationImage(image: AssetImage('assets/kaonaoe.jpg'), fit: BoxFit.cover),
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
                      const Text("ข้าวเหนียวสังขยา", style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
                      Text("฿$price", style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.deepOrange)),
                    ],
                  ),
                  const Text("ข้าวเหนียวนุ่มมูนกะทิสด ราดสังขยาไข่รสละมุน", style: TextStyle(color: Colors.grey)),
                  const SizedBox(height: 25),

                  // ข้อมูลสูตร
                  _buildSectionCard(
                    title: "สูตรลับความอร่อย",
                    icon: Icons.auto_awesome,
                    child: Column(
                      children: [
                        _buildInfoRow(Icons.egg, "วัตถุดิบ: ข้าวเหนียวเขี้ยวงู, กะทิสด, ไข่เป็ด, น้ำตาลมะพร้าว"),
                        _buildInfoRow(Icons.timer, "จุดเด่น: ข้าวเหนียวนุ่มข้ามคืน สังขยาเนื้อเนียนหอมใบเตย"),
                      ],
                    ),
                  ),

                  const SizedBox(height: 15),

                  // วิดีโอแนะนำ
                  _buildSectionCard(
                    title: "วิดีโอแนะนำ",
                    icon: Icons.play_circle_fill,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(15),
                      child: YoutubePlayer(controller: _ytController, showVideoProgressIndicator: true),
                    ),
                  ),

                  const SizedBox(height: 15),

                  // พิกัดร้านและการเดินทาง
                  _buildSectionCard(
                    title: "พิกัดร้านและการเดินทาง",
                    icon: Icons.location_pin,
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
                                TileLayer(urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png", subdomains: const ['a', 'b', 'c']),
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

                  const SizedBox(height: 30),

                  // ส่วนเลือกจำนวน
                  const Text("ระบุจำนวนสั่งซื้อ", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 15),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("จำนวน (ห่อ)", style: TextStyle(fontSize: 16)),
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

                  // ช่องหมายเหตุ
                  TextField(
                    controller: commentCtrl,
                    decoration: InputDecoration(
                      hintText: "หมายเหตุ (เช่น ไม่รับถุงพลาสติก)",
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
                      filled: true,
                      fillColor: Colors.white,
                      prefixIcon: const Icon(Icons.edit_note, color: Colors.grey),
                    ),
                  ),

                  const SizedBox(height: 25),

                  // สรุปยอดและปุ่มสั่งซื้อ
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
                            icon: const Icon(Icons.shopping_cart),
                            label: const Text("เพิ่มลงตะกร้า", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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