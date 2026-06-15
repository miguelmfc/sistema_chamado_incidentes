class Incident {
  final int id;
  final String title;
  final String description;
  final String severity;
  final String status;
  final String reporterName;
  final String? analystName;
  final String createdAt;
  final String updatedAt;

  Incident({
    required this.id,
    required this.title,
    required this.description,
    required this.severity,
    required this.status,
    required this.reporterName,
    this.analystName,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Incident.fromJson(Map<String, dynamic> json) {
    return Incident(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      severity: json['severity'],
      status: json['status'],
      reporterName: json['reporter_name'],
      analystName: json['analyst_name'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }
}