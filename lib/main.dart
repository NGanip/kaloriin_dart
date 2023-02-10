import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'database_helper.dart';
import 'food_data.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Nutrition App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Bluetooth
  BluetoothConnection connection;
  StreamSubscription<BluetoothDataEvent> subscription;
  String weight;

  // Database
  DatabaseHelper helper = DatabaseHelper();
  List<FoodData> foodDataList = List<FoodData>();

  // Search bar
  TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();

    // Connect to ESP32
    connect();

    // Load food data
    helper.getFoodMapList().then((foodMapList) {
      setState(() {
        for (int i = 0; i < foodMapList.length; i++) {
          foodDataList.add(FoodData.fromMapObject(foodMapList[i]));
        }
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
    subscription?.cancel();
    connection?.dispose();
  }

  void connect() async {
    BluetoothDevice device = await BluetoothConnection.toAddress(
      '00:00:00:00:00:00',
    );
    connection = BluetoothConnection(device);
    subscription = connection.input.listen(null).asBroadcastStream().listen((event) {
      setState(() {
        weight = event.data;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Nutrition App'),
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SearchFood(),
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
          children: [
      Padding(
      padding: EdgeInsets.all(8.0),
      child: Text('Weight: $weight'),
    ),
    Expanded(
    child: ListView.builder(
    itemCount: food
    itemBuilder: (BuildContext context, int index) {
    FoodData foodData = foodDataList[index];
    return ListTile(
    title: Text(foodData.name),
    subtitle: Text(foodData.calories.toString() + " cal"),
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
  @override
  _SearchFoodState createState() => _SearchFoodState();
}

class _SearchFoodState extends State<SearchFood> {
  List<FoodData> _searchResult = [];
  TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      if (_controller.text.isEmpty) {
        setState(() {
          _searchResult = [];
        });
        return;
      }
      setState(() {
        _searchResult = foodDataList
            .where((foodData) => foodData.name
            .toLowerCase()
            .contains(_controller.text.toLowerCase()))
            .toList();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Search Food"),
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(8.0),
            child: TextField(
              controller: _controller,
              decoration: InputDecoration(
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
                  subtitle: Text(foodData.calories.toString() + " cal"),
                  onTap: () {
                    // Use foodData from selected row
                    // Calculate calories
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
