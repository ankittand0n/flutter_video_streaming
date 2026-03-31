import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:namkeen_tv/model/configuration.dart';
import 'package:namkeen_tv/model/season.dart';
import 'package:namkeen_tv/repository/repository.dart';

import '../model/movie.dart';

part 'netflix_event.dart';
part 'netflix_state.dart';

class ProfileSelectorBloc extends Bloc<ProfileEvent, ProfileState> {
  ProfileSelectorBloc() : super(ProfileState(0)) {
    on<SelectProfile>((event, emit) async {
      emit(ProfileState(event.profile));
    });
  }
}

class TrendingMovieListWeeklyBloc extends Bloc<MovieEvent, MovieState> {
  final TMDBRepository repository;
  TrendingMovieListWeeklyBloc({required this.repository})
      : super(MovieInitial()) {
    on<FetchTrendingMovieListWeekly>((event, emit) async {
      try {
        emit(
            TrendingMovieListWeekly(await repository.getTrending(type: 'movie')));
      } catch (e) {
        emit(TrendingMovieListWeekly(const []));
      }
    });
  }
}

class TrendingMovieListDailyBloc extends Bloc<MovieEvent, MovieState> {
  final TMDBRepository repository;
  TrendingMovieListDailyBloc({required this.repository})
      : super(MovieInitial()) {
    on<FetchTrendingMovieListDaily>((event, emit) async {
      try {
        emit(TrendingMovieListDaily(
            await repository.getTrending(type: 'movie', time: 'day')));
      } catch (e) {
        emit(TrendingMovieListDaily(const []));
      }
    });
  }
}

class TrendingTvShowListWeeklyBloc extends Bloc<MovieEvent, MovieState> {
  final TMDBRepository repository;
  TrendingTvShowListWeeklyBloc({required this.repository})
      : super(MovieInitial()) {
    on<FetchTrendingTvShowListWeekly>((event, emit) async {
      try {
        emit(TrendingTvShowLisWeekly(await repository.getTrending(type: 'tv')));
      } catch (e) {
        emit(TrendingTvShowLisWeekly(const []));
      }
    });
  }
}

class TrendingTvShowListDailyBloc extends Bloc<MovieEvent, MovieState> {
  final TMDBRepository repository;
  TrendingTvShowListDailyBloc({required this.repository})
      : super(MovieInitial()) {
    on<FetchTrendingTvShowListDaily>((event, emit) async {
      try {
        emit(TrendingTvShowListDaily(
            await repository.getTrending(type: 'tv', time: 'day')));
      } catch (e) {
        emit(TrendingTvShowListDaily(const []));
      }
    });
  }
}

class ConfigurationBloc extends Bloc<ConfigurationEvent, ConfigurationState> {
  final TMDBRepository repository;
  ConfigurationBloc({required this.repository}) : super(ConfigurationState()) {
    on<FetchConfiguration>((event, emit) async {
      try {
        emit(ConfigurationState(data: await repository.getConfiguration()));
      } catch (e) {
        emit(ConfigurationState());
      }
    });
  }
}

class TvShowSeasonSelectorBloc extends Bloc<MovieEvent, MovieState> {
  final TMDBRepository repository;
  TvShowSeasonSelectorBloc({required this.repository}) : super(MovieInitial()) {
    on<SelectTvShowSeason>((event, emit) async {
      try {
        emit(SelectedTvShowSeason(
            await repository.getSeason(event.id, event.season)));
      } catch (e) {
        emit(MovieInitial());
      }
    });
  }
}

class DiscoverTvShowsBloc extends Bloc<MovieEvent, MovieState> {
  final TMDBRepository repository;
  DiscoverTvShowsBloc({required this.repository}) : super(MovieInitial()) {
    on<DiscoverTvShowsEvent>((event, emit) async {
      try {
        emit(DiscoverTvShows(await repository.discover('tv')));
      } catch (e) {
        emit(DiscoverTvShows(const []));
      }
    });
  }
}

class DiscoverMoviesBloc extends Bloc<MovieEvent, MovieState> {
  final TMDBRepository repository;
  DiscoverMoviesBloc({required this.repository}) : super(MovieInitial()) {
    on<DiscoverMoviesEvent>((event, emit) async {
      try {
        emit(DiscoverMovies(await repository.discover('movie')));
      } catch (e) {
        emit(DiscoverMovies(const []));
      }
    });
  }
}
