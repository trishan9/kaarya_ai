class JobModel {
  final int id;
  final String badge;
  final String badgeType;
  final String title;
  final String company;
  final String logo;
  final String location;
  final String jobType;
  final String experience;
  final String salary;
  final String postedAgo;

  JobModel({
    required this.id,
    required this.badge,
    required this.badgeType,
    required this.title,
    required this.company,
    required this.logo,
    required this.location,
    required this.jobType,
    required this.experience,
    required this.salary,
    required this.postedAgo,
  });
}
