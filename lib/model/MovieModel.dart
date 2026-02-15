class MovieModel {
  String? id;
  String? title;
  String? year;
  String? poster;
  String? type;

  MovieModel({this.id, this.title, this.year, this.poster, this.type});

  MovieModel.fromJson(Map<String, dynamic> json) {
    id = json['imdbID']?.toString();
    title = json['Title']?.toString();
    year = json['Year']?.toString();
    poster = json['Poster']?.toString();
    type = json['Type']?.toString();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['imdbID'] = id;
    data['Title'] = title;
    data['Year'] = year;
    data['Poster'] = poster;
    data['Type'] = type;
    return data;
  }
}
