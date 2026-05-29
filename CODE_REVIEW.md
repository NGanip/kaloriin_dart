# Kaloriin Dart App - Code Review & Test Report
# Date: May 29, 2026

## Project Overview
- **Name**: kaloriin_dart
- **Language**: Dart (Flutter)
- **Purpose**: Calorie calculation / nutrition tracking app
- **Dependencies**: flutter_bluetooth_serial, path_provider, sqflite, cupertino_icons
- **SDK Constraint**: >=2.19.2 <3.0.0

---

## 🔴 Critical Bugs

### 1. Broken ListView.builder in main.dart (line ~106)
The ListView.builder is MISSING `.count`:
```dart
ListView.builder(
  itemCount: food   // ❌ INCOMPLETE - should be: itemCount: foodDataList.length
```
This will NOT compile. `food` alone isn't a valid expression — this is a truncated/incorrect line.

### 2. Hardcoded null Bluetooth address (line 68-69)
```dart
BluetoothDevice device = await BluetoothConnection.toAddress(
  '00:00:00:00:00:00',  ❌ Will always fail - dummy address
);
```
The app will crash on startup when trying to connect to a fake Bluetooth device.
Also, `BluetoothConnection.toAddress()` returns a `BluetoothConnection`, NOT a `BluetoothDevice`.
The code then does `connection = connection(device)` which is wrong — double assignment.

Correct approach:
```dart
connection = await BluetoothConnection.toAddress('XX:XX:XX:XX:XX:XX');
```

### 3. BluetoothConnection API misuse (line 71)
```dart
connection = connection(device);  ❌ BluetoothConnection is not a factory/constructor like this
```
`BluetoothConnection` constructor doesn't work like this. The connection is already established by `toAddress()`.

### 4. Event handling type error (line 72-76)
```dart
subscription = connection.input.listen(null).asBroadcastStream().listen((event) {
  setState(() {
    weight = event.data;  ❌ event is List<int> (bytes), not a BluetoothDataEvent
  });
});
```
`connection.input` returns a `Stream<List<int>>`. The `.data` property doesn't exist on raw byte data.
Should be something like:
```dart
connection.input.listen((data) {
  setState(() {
    weight = String.fromCharCodes(data).trim();
  });
});
```

---

## 🟡 Medium Issues

### 5. Unhandled null safety on Bluetooth widgets (line 34, 102)
```dart
BluetoothConnection connection;        // ❌ Non-nullable but not initialized
String weight;                         // ❌ Non-nullable but not initialized
Text('Weight: $weight')                // Will show "Weight: null"
```
Should be nullable (`BluetoothConnection? connection;`) or initialize with defaults.

### 6. _HomePageState.disposed() doesn't cancel subscription properly (line 62-65)
```dart
void dispose() {
  super.dispose();          // ❌ super.dispose() should be LAST
  subscription?.cancel();
  connection?.dispose();
}
```
`super.dispose()` should always be called last in Flutter.

### 7. SearchFood uses undefined `foodDataList` (line 142)
```dart
_searchResult = foodDataList  // ❌ foodDataList is not defined in _SearchFoodState
    .where((foodData) => foodData.name
```
`_SearchFoodState` has no `foodDataList` field. It's defined in `_HomePageState`. The search page has no data source.

### 8. Missing super.dispose() order in SearchFood
Missing `dispose()` override entirely for the `TextEditingController` — potential memory leak.

### 9. Database _onCreate is empty (line 28-30)
```dart
void _onCreate(Database db, int newVersion) async {
  // code to create the database tables  // ❌ Tables are never created!
}
```
The `food_data` table will never be created, so all DB operations (SELECT, INSERT) will fail with "no such table" error.

Should be:
```dart
await db.execute('CREATE TABLE food_data(id INTEGER PRIMARY KEY, name TEXT, weight REAL, calories REAL)');
```

---

## 🟢 Minor Issues / Improvements

### 10. Deprecated API usage
- `List<FoodData> foodDataList = List<FoodData>();` — should be `[]` or `<FoodData>[]`
- `flutter_bluetooth_serial: ^0.4.0` — very old, consider `flutter_bluetooth_serial: ^0.4.2` or migrate to `flutter_blue_plus`

### 11. No error handling in connect()
No try/catch around Bluetooth connection — will crash silently or with unhandled exception.

### 12. No test files
No `test/` directory with any widget tests or unit tests.

### 13. Calorie calculation is empty (SearchFood line 178-179)
```dart
onTap: () {
  // Use foodData from selected row
  // Calculate calories  // ❌ Stub - not implemented
},
```
The core feature (calculating calories from weight × food data) isn't implemented.

---

## Summary

| Severity | Count |
|----------|-------|
| 🔴 Critical (won't compile/crash) | 4 |
| 🟡 Medium (runtime errors/bugs) | 5 |
| 🟢 Minor (code quality) | 4 |

### Can the app run as-is?
**No.** The app has multiple compile-time errors and runtime crashes:
1. `itemCount: food` is invalid syntax — won't compile
2. Bluetooth connection will crash on startup
3. Database table never created — all queries will fail
4. Search page references undefined variable

### Recommended Priority
1. Fix `itemCount` in ListView.builder
2. Fix Bluetooth connection logic or make it optional
3. Implement `_onCreate` to create the food_data table
5. Pass food data to SearchFood page
6. Implement calorie calculation logic
