class Laboratory{
  String id;
  String department;
  String laboratory;
  int units;

  Laboratory({
    required this.id,
    required this.department,
    required this.laboratory,
    this.units= 0,
  });

  Map toJson() => {
        'id': id,
        'department': department,
        'laboratory': laboratory,
        'units': units
      };
}