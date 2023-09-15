class Laboratory{
  String id;
  String room;
  String building;
  int units;

  Laboratory({
    required this.id,
    required this.room,
    required this.building,
    this.units= 0,
  });

  Map toJson() => {
        'id': id,
        'room': room,
        'building': building,
        'units': units
      };
}