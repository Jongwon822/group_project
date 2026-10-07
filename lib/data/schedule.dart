//달력에 표시되는 일정 1개를 나타내는 클래스
class ScheduleItem{
    final String id;
    final String title;
    final String company;
    final DateTime date;

    const ScheduleItem({
        required this.id,
        required this.title,
        required this.company,
        required this.date,
    });

    Map<String, dynamic> toJson() => {
            'id': id,
            'title':title,
            'company': company,
            'date': date.toIso8601String(),
        };
    factory ScheduleItem.fromJson(Map<String, dynamic> json) => ScheduleItem(
        id: json['id']as String,
        title: json['title'] as String,
        company: json['company'] as String,
        date: DateTime.parse(json['date'] as String),
        );

}
