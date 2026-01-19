import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart'; // ใช้เปิด Google Maps จริง

import '../models/cart.dart';

class KrapaoPage extends StatefulWidget {
  const KrapaoPage({super.key});

  @override
  State<KrapaoPage> createState() => _KrapaoPageState();
}

class _KrapaoPageState extends State<KrapaoPage> {
  late YoutubePlayerController _ytController;

  final int price = 50;
  int quantity = 1; 
  final TextEditingController commentCtrl = TextEditingController();
  int totalPrice = 50;

  // พิกัดร้านกะเพรา (ใช้พิกัดที่คุณให้มา)
  final double shopLatitude = 18.28507;
  final double shopLongitude = 99.50031;

  final MapController _mapController = MapController();

  @override
  void initState() {
    super.initState();
    // Video ID สำหรับกะเพรา
    final videoId = YoutubePlayer.convertUrlToId('https://youtu.be/noQTuNaSItI?si=xxQdEjtfffqflTOs');
    _ytController = YoutubePlayerController(
      initialVideoId: videoId ?? 'noQTuNaSItI',
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

  // ฟังก์ชันนำทางด้วย Google Maps (แก้ปัญหาเรื่อง API Key และ Lookup failed)
  Future<void> _launchGoogleMaps() async {
    // สร้างลิงก์นำทางไปยังพิกัดร้าน
    final String googleMapsUrl = "https://www.google.com/maps/search/?api=1&query=$shopLatitude,$shopLongitude";
    final Uri url = Uri.parse(googleMapsUrl);

    try {
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      } else {
        _showMessage("ไม่สามารถเปิดแอปแผนที่ได้");
      }
    } catch (e) {
      // Fallback สำหรับเวอร์ชั่นที่มีปัญหาเรื่อง LaunchMode
      await launch(googleMapsUrl); 
    }
  }

  void _showMessage(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), behavior: SnackBarBehavior.floating));
  }

  void _addToCart() {
    final comment = commentCtrl.text.trim();
    Cart.addItem("กะเพราหมูสับ${comment.isNotEmpty ? ' ($comment)' : ''}", price, quantity);
    _showMessage("เพิ่มกะเพราหมูสับ $quantity จาน ลงตะกร้าแล้ว");
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
            // ส่วนแสดงรูปภาพอาหารจาก Assets
            Container(
              height: 220,
              width: double.infinity,
              decoration: const BoxDecoration(
                image: DecorationImage(image: AssetImage('assets/krapao.jpg'), fit: BoxFit.cover),
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
                      const Text("กะเพราหมูสับ", style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
                      Text("฿$price", style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.redAccent)),
                    ],
                  ),
                  const Text("ผัดแห้ง รสจัดจ้าน หอมใบกะเพราแท้ๆ", style: TextStyle(color: Colors.grey)),
                  const SizedBox(height: 25),

                  // ส่วนที่ 1: ข้อมูลอาหาร
                  _buildSectionCard(
                    title: "ข้อมูลอาหาร",
                    icon: Icons.restaurant,
                    child: Column(
                      children: [
                        _buildInfoRow(Icons.kitchen, "วัตถุดิบ: หมูสับคัดเกรด, ใบกะเพราป่า, พริกแห้ง"),
                        _buildInfoRow(Icons.auto_stories, "เคล็ดลับ: ผัดไฟแรงจนแห้ง หอมกลิ่นกระทะ"),
                      ],
                    ),
                  ),

                  const SizedBox(height: 15),

                  // ส่วนที่ 2: วิดีโอ YouTube
                  _buildSectionCard(
                    title: "วิดีโอแนะนำ",
                    icon: Icons.play_circle_fill,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(15),
                      child: YoutubePlayer(controller: _ytController, showVideoProgressIndicator: true),
                    ),
                  ),

                  const SizedBox(height: 15),

                  // ส่วนที่ 3: แผนที่ (รองรับ flutter_map 4.0.0)
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
                                center: shopPoint, // v4.0.0
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
                                      builder: (_) => const Icon(Icons.location_on, color: Colors.red, size: 35)
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        // ปุ่มนำทางแบบเปิดแอปภายนอก
                        TextButton.icon(
                          onPressed: _launchGoogleMaps, 
                          icon: const Icon(Icons.directions), 
                          label: const Text("เปิดการนำทางด้วย Google Maps")
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 25),

                  // ส่วนที่ 4: ระบุรายละเอียดและจำนวน
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
                            IconButton(onPressed: _decrement, icon: const Icon(Icons.remove_circle_outline, color: Colors.redAccent)),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 12),
                              child: Text("$quantity", style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                            ),
                            IconButton(onPressed: _increment, icon: const Icon(Icons.add_circle_outline, color: Colors.redAccent)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 20),
                  
                  TextField(
                    controller: commentCtrl,
                    decoration: InputDecoration(
                      hintText: "หมายเหตุ (เช่น เผ็ดน้อย, ไม่ใส่พริก...)",
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
                      filled: true,
                      fillColor: Colors.white,
                      prefixIcon: const Icon(Icons.edit_note, color: Colors.grey),
                    ),
                  ),

                  const SizedBox(height: 25),

                  // ส่วนที่ 5: ปุ่มใส่ตะกร้า (Full Width)
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
                            Text("฿$totalPrice", style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.redAccent)),
                          ],
                        ),
                        const SizedBox(height: 15),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.redAccent,
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

  // ฟังก์ชันสร้าง Card แบ่งส่วน
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
              Icon(icon, size: 20, color: Colors.redAccent),
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

  // ฟังก์ชันสร้างแถวข้อมูล
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