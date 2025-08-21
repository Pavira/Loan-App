class ConfigurationModel {
  final int? finePercentage;

  ConfigurationModel({this.finePercentage});

  Map<String, dynamic> toMap() {
    return {'finePercentage': finePercentage ?? ''};
  }

  factory ConfigurationModel.fromMap(Map<String, dynamic> map) {
    return ConfigurationModel(
      finePercentage:
          (map['finePercentage'] != null)
              ? (map['finePercentage'] as num).toInt()
              : null,
    );
  }
}
