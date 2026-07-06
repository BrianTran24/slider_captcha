class CaptchaModel {
  final String? requestID;
  final String? puzzleImage;
  final String? pieceImage;
  final double? y;

  CaptchaModel({this.requestID, this.puzzleImage, this.pieceImage, this.y});

  factory CaptchaModel.fromJson(Map<String, dynamic> json) {
    String? requestID = json['request_id'];
    String? puzzleImage = json['puzzle_image'];
    String? pieceImage = json['piece_image'];
    double y = json['y'];

    return CaptchaModel(
        requestID: requestID,
        puzzleImage: puzzleImage,
        pieceImage: pieceImage,
        y: y);
  }
}
