class FoodData {
  int id;
  String name;
  double weight;
  double calories;

  FoodData({required this.id, required this.name, required this.weight, required this.calories});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'weight': weight,
      'calories': calories,
    };
  }

  static FoodData fromMap(Map<String, dynamic> map) {
    return FoodData(
      id: map['id'],
      name: map['name'],
      weight: map['weight'],
      calories: map['calories'],
    );
  }
}
