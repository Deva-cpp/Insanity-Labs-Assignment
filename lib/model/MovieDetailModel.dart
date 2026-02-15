class RatingModel {
  String? source;
  String? value;

  RatingModel({this.source, this.value});

  RatingModel.fromJson(Map<String, dynamic> json) {
    source = json['Source']?.toString();
    value = json['Value']?.toString();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['Source'] = source;
    data['Value'] = value;
    return data;
  }
}

class MovieDetailModel {
  String? id;
  String? title;
  String? year;
  String? poster;
  String? rated;
  String? released;
  String? runtime;
  String? genre;
  String? director;
  String? writer;
  String? awards;
  String? country;
  String? language;
  String? metascore;
  String? plot;
  String? actors;
  String? type;
  String? totalSeasons;
  String? imdbRating;
  String? imdbVotes;
  List<RatingModel>? ratings;

  MovieDetailModel(
      {this.id,
      this.title,
      this.year,
      this.poster,
      this.rated,
      this.released,
      this.runtime,
      this.genre,
      this.director,
      this.writer,
      this.awards,
      this.country,
      this.language,
      this.metascore,
      this.plot,
      this.actors,
      this.type,
      this.totalSeasons,
      this.imdbRating,
      this.imdbVotes,
      this.ratings});

  MovieDetailModel.fromJson(Map<String, dynamic> json) {
    id = json['imdbID']?.toString();
    title = json['Title']?.toString();
    year = json['Year']?.toString();
    poster = json['Poster']?.toString();
    rated = json['Rated']?.toString();
    released = json['Released']?.toString();
    runtime = json['Runtime']?.toString();
    genre = json['Genre']?.toString();
    director = json['Director']?.toString();
    writer = json['Writer']?.toString();
    awards = json['Awards']?.toString();
    country = json['Country']?.toString();
    language = json['Language']?.toString();
    metascore = json['Metascore']?.toString();
    plot = json['Plot']?.toString();
    actors = json['Actors']?.toString();
    type = json['Type']?.toString();
    totalSeasons = json['totalSeasons']?.toString();
    imdbRating = json['imdbRating']?.toString();
    imdbVotes = json['imdbVotes']?.toString();

    if (json['Ratings'] != null) {
      ratings = <RatingModel>[];
      json['Ratings'].forEach((v) {
        ratings!.add(RatingModel.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['imdbID'] = id;
    data['Title'] = title;
    data['Year'] = year;
    data['Poster'] = poster;
    data['Rated'] = rated;
    data['Released'] = released;
    data['Runtime'] = runtime;
    data['Genre'] = genre;
    data['Director'] = director;
    data['Writer'] = writer;
    data['Awards'] = awards;
    data['Country'] = country;
    data['Language'] = language;
    data['Metascore'] = metascore;
    data['Plot'] = plot;
    data['Actors'] = actors;
    data['Type'] = type;
    data['totalSeasons'] = totalSeasons;
    data['imdbRating'] = imdbRating;
    data['imdbVotes'] = imdbVotes;
    if (ratings != null) {
      data['Ratings'] = ratings!.map((v) => v.toJson()).toList();
    }
    return data;
  }

  String ratingBy(String text) {
    if (ratings == null) return '';
    for (final item in ratings!) {
      if ((item.source ?? '').toLowerCase() == text.toLowerCase()) {
        return item.value ?? '';
      }
    }
    return '';
  }
}
