class Person {
  final int id;
  final String location;
  final String uuid;
  final String timestamp;
  final String gender;
  final int child;
  final int pregnantwoman;

  Person(
      {required this.id,
      required this.location,
      required this.uuid,
      required this.timestamp,
      required this.gender,
      required this.child,
      required this.pregnantwoman});

  factory Person.fromJson(Map<String, dynamic> json) {
    return Person(
        id: json['id'],
        location: json['location'],
        uuid: json['uuid'],
        timestamp: json['timestamp'],
        gender: json['gender'],
        child: json['child'],
        pregnantwoman: json['pregnantwoman']);
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'location': location,
      'uuid': uuid,
      'timestamp': timestamp,
      'gender': gender,
      'child': child,
      'pregnantWoman': pregnantwoman
    };
  }

  @override
  String toString() {
    return 'Person(uuid: $uuid, timestamp: $timestamp), gender: $gender, child: $child, pregnantWoman: $pregnantwoman';
  }
}
