import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

// ส่วนของ Imports (โครงสร้างเดิมของคุณ)
import 'foods/kaomontkai_page.dart';
import 'foods/somtum_page.dart';
import 'foods/kaprao_page.dart';
import 'foods/larb_page.dart';
import 'snacks/kanomkro_page.dart';
import 'snacks/saku_page.dart';
import 'snacks/kaonaoe_page.dart';
import 'pages/bill_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const FoodApp());
}

class FoodApp extends StatelessWidget {
  const FoodApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'Kanit',
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.black),
      ),
      home: const FoodMenuPage(),
      routes: {
        '/kaomontkai': (_) => const KaomontkaiPage(),
        '/krapao': (_) => const KrapaoPage(),
        '/larb': (_) => const LarbPage(),
        '/somtum': (_) => const SomtumPage(),
        '/kanomkro': (_) => const KanomkroPage(),
        '/kaonaoe': (_) => const KaonaoePage(),
        '/saku': (_) => const SakuPage(),
      },
    );
  }
}

class FoodMenuPage extends StatelessWidget {
  const FoodMenuPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text("FOOD APP", 
          style: TextStyle(letterSpacing: 6, fontWeight: FontWeight.w200, fontSize: 14)),
      ),
      body: CustomScrollView(
        slivers: [
          // --- หัวข้อหมวดหมู่ ---
          const SliverToBoxAdapter(child: _SectionTitle(title: "อาหารคาว")),

          // --- ส่วนจานหลัก (โครงสร้าง SliverGrid เดิม แต่รูปทรงเป็นวงกลม) ---
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 25),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 30,
                crossAxisSpacing: 20,
                childAspectRatio: 0.8,
              ),
              delegate: SliverChildListDelegate([
                _CircleFoodCard(context, "ข้าวมันไก่", "assets/kaomontkai.jpg", "/kaomontkai", "50"),
                _CircleFoodCard(context, "ผัดกะเพรา", "assets/krapao.jpg", "/krapao", "50"),
                _CircleFoodCard(context, "ส้มตำไทย", "assets/somtum.jpg", "/somtum", "40"),
                _CircleFoodCard(context, "ลาบหมู", "assets/larb.jpg", "/larb", "40"),
              ]),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 50)),

          // --- หัวข้อหมวดหมู่ของหวาน ---
          const SliverToBoxAdapter(child: _SectionTitle(title: "ของหวาน")),

          // --- ส่วนของหวาน (โครงสร้าง SliverList เดิม แต่จัดวางแบบใหม่) ---
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 25),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _MinimalRow(context, "ขนมครก", "assets/kanomkro.jpg", "/kanomkro", "20"),
                _MinimalRow(context, "ข้าวเหนียวสังขยา", "assets/kaonaoe.jpg", "/kaonaoe", "10"),
                _MinimalRow(context, "สาคูน้ำกะทิ", "assets/saku.jpg", "/saku", "20"),
              ]),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 120)),
        ],
      ),
      // ปุ่มตะกร้าแบบ Floating ทรงสี่เหลี่ยมผืนผ้าโค้งมน
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const BillPage())),
        backgroundColor: Colors.black,
        elevation: 10,
        label: const Text("ตะกร้า", style: TextStyle(color: Colors.white, letterSpacing: 1)),
        icon: const Icon(Icons.shopping_cart_outlined, color: Colors.white),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(25, 20, 25, 30),
      child: Center(
        child: Column(
          children: [
            Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Container(width: 30, height: 2, color: Colors.black),
          ],
        ),
      ),
    );
  }
}

// การ์ดทรงวงกลม พร้อมราคาลอย (Circle & Badge)
class _CircleFoodCard extends StatelessWidget {
  final BuildContext context;
  final String title, img, route, price;

  const _CircleFoodCard(this.context, this.title, this.img, this.route, this.price);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, route),
      child: Column(
        children: [
          Stack(
            alignment: Alignment.topRight,
            children: [
              // รูปวงกลมหลัก
              Container(
                width: 130,
                height: 130,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 15, offset: const Offset(0, 8))
                  ],
                  image: DecorationImage(image: AssetImage(img), fit: BoxFit.cover),
                ),
              ),
              // วงกลมราคาที่ลอยอยู่
              Container(
                padding: const EdgeInsets.all(10),
                decoration: const BoxDecoration(color: Colors.black, shape: BoxShape.circle),
                child: Text(price, style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: 15),
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        ],
      ),
    );
  }
}

// แถวลิสต์แบบบางเฉียบ (Ultra Thin Row)
class _MinimalRow extends StatelessWidget {
  final BuildContext context;
  final String title, img, route, price;

  const _MinimalRow(this.context, this.title, this.img, this.route, this.price);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, route),
      child: Padding(
        padding: const EdgeInsets.only(bottom: 25),
        child: Row(
          children: [
            // รูปขนาดเล็กทรงแคปซูล
            Container(
              width: 60,
              height: 40,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                image: DecorationImage(image: AssetImage(img), fit: BoxFit.cover),
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Text(title, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 16)),
            ),
            Text("฿$price", style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
          ],
        ),
      ),
    );
  }
}