/// A message published by the admin and shown in the app's notification centre.
///
/// The app never creates them: the back office publishes from the API's Swagger
/// UI, so this is read-only apart from the read flag.
class AppNotification {
  const AppNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.link,
    required this.imageUrl,
    required this.date,
    this.isRead = false,
  });

  final String id;
  final String title;
  final String body;

  /// Optional in-app destination, e.g. `/shop`.
  final String link;
  final String imageUrl;
  final DateTime date;

  /// Whether the current user already opened it.
  final bool isRead;

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    return AppNotification(
      id: '${json['id']}',
      title: json['title']?.toString() ?? '',
      body: json['body']?.toString() ?? '',
      link: json['link']?.toString() ?? '',
      imageUrl: json['imageUrl']?.toString() ?? '',
      date: DateTime.tryParse('${json['createdAt']}') ?? DateTime.now(),
      isRead: json['isRead'] == true,
    );
  }

  AppNotification copyWith({bool? isRead}) {
    return AppNotification(
      id: id,
      title: title,
      body: body,
      link: link,
      imageUrl: imageUrl,
      date: date,
      isRead: isRead ?? this.isRead,
    );
  }
}
