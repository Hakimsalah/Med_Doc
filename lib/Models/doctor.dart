class Doctor {
  final String id;
  final String name;
  final String specialty;
  final String bio;
  final int experience;
  final String location;
  final String workingHours;
  final List<String> workingDays;
  final String image;
  final double rating;

  Doctor({
    required this.id,
    required this.name,
    required this.specialty,
    required this.bio,
    required this.experience,
    required this.location,
    required this.workingHours,
    required this.workingDays,
    required this.image,
    required this.rating,
  });
}
