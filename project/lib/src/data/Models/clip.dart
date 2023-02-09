// This is the Model class for each Clip

class Clip {
  int? clipID;
  List<String>? categories;
  String? title;
  String? uploaderName;
  int? likes;

  Clip(
      {required this.clipID,
      this.categories,
      this.title,
      this.uploaderName,
      this.likes});

  Clip.empty();

  factory Clip.fromJson(Map<String, dynamic> json) {
    return Clip(
      clipID: json['clipID'],
      categories:
          List<String>.from(json['categories'].map((e) => Clip.fromJson(e))),
      title: json['title'],
      uploaderName: json['uploaderName'],
      likes: json['likes'],
    );
  }

  Map<String, dynamic> toJson(Clip clip) {
    return {
      "clipID": clip.clipID,
      "categories": clip.categories,
      "title": clip.title,
      "uploaderName": clip.uploaderName,
      "likes": clip.likes,
    };
  }

  @override
  String toString() {
    return 'Clip{clipID: $clipID,'
        ' categories: $categories,'
        ' title: $title,'
        ' uploaderName: $uploaderName'
        ' likes: $likes'
        '}';
  }
}
