import 'dart:convert'; // ใช้สำหรับแปลงข้อมูล JSON
import 'package:flutter/material.dart';
import 'package:http/http.dart'
    as http; // ตั้งชื่อเล่นเป็น http เพื่อเรียกใช้ง่าย

void main() {
  runApp(const MainApp());
}

/// -----------------------------
/// Widget หลักของแอป
/// -----------------------------
class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PokeAPI Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.red, useMaterial3: true),

      /// ปิดแถบ DEBUG มุมขวาบน
      home: const PokemonListScreen(),

      /// หน้าแรกของแอป คือหน้ารายชื่อ  Pokemon
    );
  }
}

/// -----------------------------
/// หน้าจอที่ 1  แสดงรายชื่อ  Pokemon
/// -----------------------------
class PokemonListScreen extends StatefulWidget {
  const PokemonListScreen({super.key});

  @override
  State<PokemonListScreen> createState() => _PokemonListScreenState();
}

class _PokemonListScreenState extends State<PokemonListScreen> {
  /// เก็บรายชื่อโปเกมอนที่ได้จาก API
  List<dynamic> pokemonList = [];

  /// ตัวแปรควบคุมการโหลดข้อมูลเพิ่ม
  int limit = 20;
  int offset = 0;
  bool isLoading = false;

  /// ใช้สลับการแสดงผล List / Grid
  bool isGrid = false;

  /// ใช้ตรวจจับการเลื่อนหน้าจอ
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    fetchPokemonList();

    /// เมื่อเลื่อนถึงล่างสุด จะโหลดข้อมูลเพิ่ม (Load more)
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        fetchPokemonList();
      }
    });
  }

  /// ฟังก์ชันดึงข้อมูล Pokemon จาก PokeAPI
  Future<void> fetchPokemonList() async {
    if (isLoading) return;

    setState(() => isLoading = true);

    /// สร้าง URL สำหรับเรียก API
    final url = Uri.parse(
      'https://pokeapi.co/api/v2/pokemon?limit=$limit&offset=$offset',
    );

    final response = await http.get(url);

    /// เรียก API
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      /// แปลง JSON เป็น Map

      setState(() {
        pokemonList.addAll(data['results']);

        /// เพิ่มข้อมูล Pokémon ใหม่เข้า List เดิม
        offset += limit;
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pokédex'),
        actions: [
          /// ปุ่มสลับ List / Grid
          IconButton(
            icon: Icon(isGrid ? Icons.list : Icons.grid_view),
            onPressed: () {
              setState(() => isGrid = !isGrid);
            },
          ),
        ],
      ),
      body: isGrid ? buildGridView() : buildListView(),
    );
  }

  /// ---------- แสดงแบบ List ----------
  Widget buildListView() {
    return ListView.builder(
      controller: _scrollController,
      itemCount: pokemonList.length,
      itemBuilder: (context, index) {
        final id = index + 1;
        return PokemonCard(
          id: id,
          name: pokemonList[index]['name'],
          url: pokemonList[index]['url'],
        );
      },
    );
  }

  /// ---------- แสดงแบบ Grid ----------
  Widget buildGridView() {
    return GridView.builder(
      controller: _scrollController,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
      ),
      itemCount: pokemonList.length,
      itemBuilder: (context, index) {
        final id = index + 1;
        return PokemonCard(
          id: id,
          name: pokemonList[index]['name'],
          url: pokemonList[index]['url'],
        );
      },
    );
  }
}

/// -----------------------------
/// การ์ดแสดง Pokemon แต่ละตัว
/// -----------------------------
class PokemonCard extends StatelessWidget {
  final int id;
  final String name;
  final String url;

  const PokemonCard({
    super.key,
    required this.id,
    required this.name,
    required this.url,
  });

  @override
  Widget build(BuildContext context) {
    /// URL รูปโปเกมอน
    final imageUrl =
        'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/$id.png';

    return GestureDetector(
      /// เมื่อกด → ไปหน้ารายละเอียด
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => PokemonDetailScreen(name: name, url: url, id: id),
          ),
        );
      },
      child: Card(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            /// Hero ใช้ทำ Animation ระหว่างหน้า
            Hero(tag: name, child: Image.network(imageUrl, height: 80)),
            const SizedBox(height: 8),
            Text('#$id', style: const TextStyle(color: Colors.grey)),
            Text(
              name.toUpperCase(),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}

/// -----------------------------
/// หน้าจอที่ 2 รายละเอียด Pokemon
/// -----------------------------
class PokemonDetailScreen extends StatefulWidget {
  final String name;
  final String url;
  final int id;

  const PokemonDetailScreen({
    super.key,
    required this.name,
    required this.url,
    required this.id,
  });

  @override
  State<PokemonDetailScreen> createState() => _PokemonDetailScreenState();
}

class _PokemonDetailScreenState extends State<PokemonDetailScreen> {
  /// เก็บข้อมูลรายละเอียดของPokemon
  Map<String, dynamic>? pokemonDetail;

  @override
  void initState() {
    super.initState();
    fetchPokemonDetail();
  }

  /// ดึงข้อมูลรายละเอียด Pokemon
  Future<void> fetchPokemonDetail() async {
    final response = await http.get(Uri.parse(widget.url));
    setState(() {
      pokemonDetail = jsonDecode(response.body);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (pokemonDetail == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    return Scaffold(
      appBar: AppBar(title: Text(widget.name.toUpperCase())),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            /// รูปใหญ่ + Hero
            Hero(
              tag: widget.name,
              child: Image.network(
                pokemonDetail!['sprites']['other']['official-artwork']['front_default'],
                height: 200,
              ),
            ),

            const SizedBox(height: 16),

            /// แสดงประเภท (Types)
            Wrap(
              spacing: 8,
              children: pokemonDetail!['types']
                  .map<Widget>((t) => Chip(label: Text(t['type']['name'])))
                  .toList(),
            ),

            const SizedBox(height: 16),

            /// แสดงค่าพลัง (Stats)
            Column(
              children: pokemonDetail!['stats'].map<Widget>((s) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(s['stat']['name']),
                    LinearProgressIndicator(value: s['base_stat'] / 200),
                    const SizedBox(height: 8),
                  ],
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
