-- PostgreSQL schema for flutter_video_streaming

-- Table: genres
CREATE TABLE genres (
  id SERIAL PRIMARY KEY,
  name varchar(191) NOT NULL,
  type varchar(191) NOT NULL,
  created_at timestamp(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3)
);

INSERT INTO genres (id, name, type, created_at) VALUES
(1, 'Action', 'movie', '2025-09-06 18:17:08.000'),
(2, 'Adventure', 'movie', '2025-09-06 18:17:08.000'),
(3, 'Animation', 'tv', '2025-09-06 18:17:09.000'),
(4, 'Comedy', 'tv', '2025-09-06 18:17:09.000'),
(5, 'Crime', 'tv', '2025-09-06 18:17:09.000'),
(6, 'Documentary', 'tv', '2025-09-06 18:17:09.000'),
(7, 'Drama', 'tv', '2025-09-06 18:17:09.000'),
(8, 'Family', 'tv', '2025-09-06 18:17:09.000'),
(9, 'Fantasy', 'movie', '2025-09-06 18:17:09.000'),
(10, 'History', 'movie', '2025-09-06 18:17:09.000'),
(11, 'Horror', 'movie', '2025-09-06 18:17:09.000'),
(12, 'Music', 'movie', '2025-09-06 18:17:09.000'),
(13, 'Mystery', 'tv', '2025-09-06 18:17:09.000'),
(14, 'Romance', 'movie', '2025-09-06 18:17:09.000'),
(15, 'Science Fiction', 'movie', '2025-09-06 18:17:09.000'),
(16, 'TV Movie', 'movie', '2025-09-06 18:17:09.000'),
(17, 'Thriller', 'movie', '2025-09-06 18:17:09.000'),
(18, 'War', 'movie', '2025-09-06 18:17:09.000'),
(19, 'Western', 'tv', '2025-09-06 18:17:09.000'),
(20, 'Action & Adventure', 'tv', '2025-09-06 18:17:09.000'),
(21, 'Kids', 'tv', '2025-09-06 18:17:09.000'),
(22, 'News', 'tv', '2025-09-06 18:17:09.000'),
(23, 'Reality', 'tv', '2025-09-06 18:17:09.000'),
(24, 'Sci-Fi & Fantasy', 'tv', '2025-09-06 18:17:09.000'),
(25, 'Soap', 'tv', '2025-09-06 18:17:09.000'),
(26, 'Talk', 'tv', '2025-09-06 18:17:09.000'),
(27, 'War & Politics', 'tv', '2025-09-06 18:17:09.000');

-- Table: movies
CREATE TABLE movies (
  id SERIAL PRIMARY KEY,
  title varchar(191) NOT NULL,
  overview varchar(191),
  release_date timestamp(3),
  vote_average double precision,
  poster_path varchar(191),
  backdrop_path varchar(191),
  genre_ids varchar(191),
  original_language varchar(191),
  created_at timestamp(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  updated_at timestamp(3),
  video boolean,
  video_url varchar(191),
  trailer_url varchar(191)
);

INSERT INTO movies (id, title, overview, release_date, vote_average, poster_path, backdrop_path, genre_ids, original_language, created_at, updated_at, video, video_url, trailer_url) VALUES
(1, 'ANTERVYATHAA', 'A psychological thriller that explores the depths of human consciousness and the haunting question: "Do you also hear voices?" This award-winning film has been nominated for 15+ awards at nat', '2021-06-01 00:00:00.000', 8.7, '/images/movies/9.jpeg', '/images/movies/9.jpeg', '["53","27","18"]', 'hi', '2025-09-06 18:17:08.000', '2025-10-12 13:55:37.283', true, 'https://firebasestorage.googleapis.com/v0/b/namkeen-tv-2e1b5.appspot.com/o/ANTERVYATHAA%20-%20AMAZON%20PRIME%20-%20June%202021.mp4?alt=media&token=1c75ecd0-1551-4ea7-9453-a3a60949d5eb', 'https://youtu.be/rcERXIpD3SI?si=w8utbsnpzuPMA1AU'),
(5, 'Chunky Ponky', NULL, NULL, NULL, '/images/movies/posterImage-1758264858587-836182551.jpeg', '/images/movies/posterImage-1758264640756-215014902.jpeg', '[18]', 'en', '2025-09-19 06:50:40.000', '2025-09-19 06:54:18.000', NULL, NULL, NULL);

-- Table: rating
CREATE TABLE rating (
  id SERIAL PRIMARY KEY,
  userId int NOT NULL,
  contentId varchar(191) NOT NULL,
  contentType varchar(191) NOT NULL,
  rating int NOT NULL,
  review varchar(191),
  title varchar(191),
  helpful varchar(191),
  spoiler boolean NOT NULL DEFAULT false,
  tags varchar(191),
  createdAt timestamp(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  updatedAt timestamp(3) NOT NULL
);

INSERT INTO rating (id, userId, contentId, contentType, rating, review, title, helpful, spoiler, tags, createdAt, updatedAt) VALUES
(1, 10, '2', 'movie', 8, NULL, NULL, NULL, false, NULL, '2025-10-12 13:49:07.392', '2025-10-12 13:49:07.392'),
(2, 10, '3', 'movie', 8, NULL, NULL, NULL, false, NULL, '2025-10-12 13:49:31.993', '2025-10-12 13:49:56.014');

-- Table: seasons
CREATE TABLE seasons (
  id SERIAL PRIMARY KEY,
  tv_series_id int,
  season_number int,
  name varchar(191),
  overview varchar(191),
  poster_path varchar(191),
  air_date timestamp(3),
  created_at timestamp(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  updated_at timestamp(3),
  episode_count int
);

INSERT INTO seasons (id, tv_series_id, season_number, name, overview, poster_path, air_date, created_at, updated_at, episode_count) VALUES
(1, 1, 1, NULL, NULL, '/images/tv_series/default-season-poster.jpg', NULL, '2025-09-19 07:09:59.000', '2025-09-19 07:09:59.000', NULL);

-- Table: tv_series
CREATE TABLE tv_series (
  id SERIAL PRIMARY KEY,
  overview varchar(191),
  first_air_date timestamp(3),
  last_air_date timestamp(3),
  vote_average double precision,
  poster_path varchar(191),
  backdrop_path varchar(191),
  genre_ids varchar(191),
  original_language varchar(191),
  created_at timestamp(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  updated_at timestamp(3),
  video boolean,
  video_url varchar(191),
  trailer_url varchar(191),
  name varchar(191) NOT NULL,
  number_of_episodes int,
  number_of_seasons int,
  seasons varchar(191),
  status varchar(191)
);

INSERT INTO tv_series (id, overview, first_air_date, last_air_date, vote_average, poster_path, backdrop_path, genre_ids, original_language, created_at, updated_at, video, video_url, trailer_url, name, number_of_episodes, number_of_seasons, seasons, status) VALUES
(1, NULL, NULL, NULL, NULL, '/images/tv_series/posterImage-1758265351021-660240754.jpeg', '/images/tv_series/posterImage-1758265200614-911729768.jpeg', '[18]', 'en', '2025-09-19 07:00:00.000', '2025-09-19 07:02:44.000', false, NULL, NULL, 'poopoo', NULL, NULL, NULL, NULL);

-- Table: "user"
CREATE TABLE "user" (
  id SERIAL PRIMARY KEY,
  email varchar(191) NOT NULL UNIQUE,
  password varchar(191) NOT NULL,
  username varchar(191) NOT NULL UNIQUE,
  profileName varchar(191) NOT NULL,
  profileAvatar varchar(191),
  profileAge int,
  profileLanguage varchar(191),
  profileMaturity varchar(191),
  preferencesGenres varchar(191),
  preferencesTypes varchar(191),
  preferencesLangs varchar(191),
  preferencesSubtitles boolean NOT NULL DEFAULT false,
  subscriptionPlan varchar(191) NOT NULL DEFAULT 'basic',
  subscriptionStatus varchar(191) NOT NULL DEFAULT 'active',
  subscriptionStart timestamp(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  subscriptionEnd timestamp(3),
  watchHistory varchar(191),
  isActive boolean NOT NULL DEFAULT true,
  lastLogin timestamp(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  verificationToken varchar(191),
  resetPasswordToken varchar(191),
  resetPasswordExpires timestamp(3),
  createdAt timestamp(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  updatedAt timestamp(3) NOT NULL
);

INSERT INTO "user" (id, email, password, username, profileName, profileAvatar, profileAge, profileLanguage, profileMaturity, preferencesGenres, preferencesTypes, preferencesLangs, preferencesSubtitles, subscriptionPlan, subscriptionStatus, subscriptionStart, subscriptionEnd, watchHistory, isActive, lastLogin, verificationToken, resetPasswordToken, resetPasswordExpires, createdAt, updatedAt) VALUES
(10, 'admin@example.com', '$2a$12$3P5je1p6J6qd5Rf1PIQCaeAvX0gwBTVpqhEhSncOvs0J6Ler5eyu2', 'admin', 'Admin', NULL, NULL, NULL, NULL, NULL, NULL, NULL, false, 'premium', 'active', '2025-10-12 13:43:29.290', NULL, NULL, true, '2025-10-12 14:28:18.071', NULL, NULL, NULL, '2025-10-12 13:43:29.290', '2025-10-12 14:28:18.074');

-- Table: watchlist
CREATE TABLE watchlist (
  id SERIAL PRIMARY KEY,
  title varchar(191) NOT NULL,
  addedAt timestamp(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  backdropPath varchar(191),
  contentId varchar(191) NOT NULL,
  contentType varchar(191) NOT NULL,
  createdAt timestamp(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  genreIds varchar(191),
  notes varchar(191),
  overview varchar(191),
  posterPath varchar(191),
  priority varchar(191) NOT NULL DEFAULT 'medium',
  rating int,
  releaseDate timestamp(3),
  tags varchar(191),
  updatedAt timestamp(3) NOT NULL,
  userId int NOT NULL,
  voteAverage double precision,
  watched boolean NOT NULL DEFAULT false,
  watchedAt timestamp(3)
);

-- Table: rating FK
ALTER TABLE rating
  ADD CONSTRAINT Rating_userId_fkey FOREIGN KEY (userId) REFERENCES "user"(id) ON DELETE CASCADE;

-- Table: watchlist FK
ALTER TABLE watchlist
  ADD CONSTRAINT Watchlist_userId_fkey FOREIGN KEY (userId) REFERENCES "user"(id) ON DELETE CASCADE;
