// This class is a Model for checkanswerresult

class CheckAnswerResult {
  bool correct;
  int totalPoints;
  int newPoints;

  CheckAnswerResult(this.correct, this.totalPoints, this.newPoints);

  factory CheckAnswerResult.fromJson(Map<String, dynamic> json) {
    return CheckAnswerResult(
      json['correct'],
      json['totalPoints'],
      json['newPoints'],
    );
  }
}
