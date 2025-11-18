class FeedbackRequest {
  final String appVersion;
  final String buildNumber;
  final String location;
  final String deviceId;
  final String deviceVersion;
  final String deviceName;
  final String option1;
  final String option2;
  final String option3;
  final String option4;
  final String comment;

  FeedbackRequest({
    required this.appVersion,
    required this.buildNumber,
    required this.location,
    required this.deviceId,
    required this.deviceVersion,
    required this.deviceName,
    required this.option1,
    required this.option2,
    required this.option3,
    required this.option4,
    required this.comment,
  });

  Map<String, dynamic> toJson() {
    return {
      'appVersion': appVersion,
      'buildNumber': buildNumber,
      'location': location,
      'deviceId': deviceId,
      'deviceVersion': deviceVersion,
      'deviceName': deviceName,
      'option1': option1,
      'option2': option2,
      'option3': option3,
      'option4': option4,
      'comment': comment,
    };
  }
}