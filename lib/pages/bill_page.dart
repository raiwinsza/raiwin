import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/cart.dart';

class BillPage extends StatefulWidget {
  const BillPage({super.key});

  @override
  State<BillPage> createState() => _BillPageState();
}

class _BillPageState extends State<BillPage> {
  
  // ฟังก์ชันส่งคำสั่งซื้อพร้อมระบบยืนยัน 2 ชั้น
  Future<void> submitOrder() async {
    if (Cart.items.isEmpty) {
      _showSnackBar("ตะกร้าว่างเปล่า กรุณาเลือกอาหารก่อนครับ", Colors.orange);
      return;
    }

    // รอบที่ 1: ยืนยันเบื้องต้น
    bool? firstConfirm = await _showConfirmDialog(
      "ยืนยันการสั่งอาหาร",
      "คุณต้องการส่งรายการอาหารทั้งหมดนี้ไปยังครัวใช่หรือไม่?",
      "ตกลง",
      Colors.deepOrange,
    );

    if (firstConfirm != true) return;

    // รอบที่ 2: ยืนยันเพื่อความแน่ใจ (Double Check)
    bool? secondConfirm = await _showConfirmDialog(
      "ตรวจสอบอีกครั้ง",
      "เมื่อกดยืนยันแล้วจะไม่สามารถยกเลิกรายการได้ คุณแน่ใจแล้วใช่หรือไม่?",
      "ใช่, สั่งเลย",
      Colors.redAccent,
    );

    if (secondConfirm != true) return;

    // แสดง Loading ระหว่างส่งข้อมูล
    _showLoadingDialog();

    try {
      await FirebaseFirestore.instance.collection("orders").add({
        "items": Cart.items.map((item) => {
          "name": item.name,
          "price": item.price,
          "qty": item.qty,
          "subtotal": item.price * item.qty,
        }).toList(),
        "totalPrice": Cart.totalPrice(),
        "totalItems": Cart.totalItems(),
        "status": "pending", // สถานะเริ่มต้น
        "timestamp": FieldValue.serverTimestamp(),
      });

      Cart.clear();
      if (mounted) {
        Navigator.pop(context); // ปิด Loading Dialog
        setState(() {}); // รีเฟรชหน้าจอ
        _showSnackBar("สั่งอาหารเรียบร้อยแล้ว เตรียมรอรับความอร่อย! 🍽️", Colors.green);
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context); // ปิด Loading Dialog
        _showSnackBar("เกิดข้อผิดพลาด: $e", Colors.red);
      }
    }
  }

  // Helper: สำหรับแสดง Dialog ยืนยัน
  Future<bool?> _showConfirmDialog(String title, String content, String confirmText, Color confirmColor) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("ยกเลิก", style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: confirmColor),
            onPressed: () => Navigator.pop(context, true),
            child: Text(confirmText, style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showLoadingDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator(color: Colors.deepOrange)),
    );
  }

  void _showSnackBar(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: color, behavior: SnackBarBehavior.floating),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text("รายการคำสั่งซื้อ", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        centerTitle: true,
      ),
      body: Cart.items.isEmpty
          ? _buildEmptyCart()
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: Cart.items.length,
                    itemBuilder: (context, index) {
                      final item = Cart.items[index];
                      return Card(
                        elevation: 0,
                        margin: const EdgeInsets.only(bottom: 10),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          title: Text(item.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text(
                            "${item.price} x ${item.qty} = ${item.price * item.qty} บาท",
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.remove_circle_outline, color: Colors.redAccent),
                            onPressed: () {
                              setState(() {
                                Cart.removeItem(item.name);
                              });
                            },
                          ),
                        ),
                      );
                    },
                  ),
                ),
                _buildOrderSummary(),
              ],
            ),
    );
  }

  Widget _buildEmptyCart() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.shopping_basket_outlined, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text("ยังไม่มีรายการอาหารในตะกร้า", style: TextStyle(fontSize: 18, color: Colors.grey[600])),
        ],
      ),
    );
  }

  Widget _buildOrderSummary() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, spreadRadius: 1)],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("จำนวนรายการทั้งหมด:", style: TextStyle(fontSize: 16)),
                Text("${Cart.totalItems()} รายการ", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("ราคาสุทธิ:", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                Text(
                  "${Cart.totalPrice()} บาท",
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.deepOrange),
                ),
              ],
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepOrange,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  elevation: 0,
                ),
                onPressed: submitOrder,
                child: const Text(
                  "ยืนยันและสั่งซื้อ",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
        
      ),
    );
  }
}