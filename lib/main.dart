import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'database_helper.dart';
import 'food_data.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Nutrition App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  BluetoothConnection? connection;
  String? weight;

  final DatabaseHelper helper = DatabaseHelper();
  List<FoodData> foodDataList = [];
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadFoodData();
  }

  void _loadFoodData() async {
    try {
      final foodMapList = await helper.getFoodMapList();
      setState(() {
        for (var foodMap in foodMapList) {
          foodDataList.add(FoodData.fromMap(Map<String, dynamic>.from(foodMap)));
        }
      });
    } catch (e) {
      debugPrint('Error loading food data: $e');
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    connection?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nutrition App'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SearchFood(foodDataList: foodDataList),
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text('Weight: ${weight ?? "--"}'),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: foodDataList.length,
              itemBuilder: (BuildContext context, int index) {
                FoodData foodData = foodDataList[index];
                return ListTile(
                  title: Text(foodData.name),
                  subtitle: Text('${foodData.calories} cal'),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class SearchFood extends StatefulWidget {
  final List<FoodData> foodDataList;

  const SearchFood({super.key, required this.foodDataList});

  @override
  _SearchFoodState createState() => _SearchFoodState();
}

class _SearchFoodState extends State<SearchFood> {
  List<FoodData> _searchResult = [];
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onSearchChanged);
  }

  void _onSearchChanged() {
    if (_controller.text.isEmpty) {
      setState(() {
        _searchResult = [];
      });
      return;
    }
    setState(() {
      _searchResult = widget.foodDataList
          .where((foodData) => foodData.name
              .toLowerCase()
              .contains(_controller.text.toLowerCase()))
          .toList();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Search Food"),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _controller,
              decoration: const InputDecoration(
                hintText: "Search food",
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _searchResult.length,
              itemBuilder: (BuildContext context, int index) {
                FoodData foodData = _searchResult[index];
                return ListTile(
                  title: Text(foodData.name),
                  subtitle: Text('${foodData.calories} cal'),
                  onTap: () {
                    // Calculate calories based on weight
                    Navigator.pop(context, foodData);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
