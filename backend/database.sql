-- Create database if it doesn't exist
CREATE DATABASE IF NOT EXISTS flutter_video_streaming;
USE flutter_video_streaming;

-- Users table
CREATE TABLE IF NOT EXISTS users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(255) NOT NULL UNIQUE,
    email VARCHAR(255) NOT NULL UNIQUE,
    password VARCHAR(255) NOT NULL,
    is_admin BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- Watchlist table
CREATE TABLE IF NOT EXISTS watchlist (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    media_type ENUM('movie', 'tv') NOT NULL,
    media_id INT NOT NULL,
    title VARCHAR(255) NOT NULL,
    poster_path VARCHAR(255),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    UNIQUE KEY unique_user_media (user_id, media_type, media_id)
);

-- Ratings table
CREATE TABLE IF NOT EXISTS ratings (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    media_type ENUM('movie', 'tv') NOT NULL,
    media_id INT NOT NULL,
    rating DECIMAL(3,1) NOT NULL CHECK (rating >= 0 AND rating <= 10),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    UNIQUE KEY unique_user_rating (user_id, media_type, media_id)
);

-- Create tables
CREATE TABLE IF NOT EXISTS genres (
  id INT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(255) NOT NULL,
  type VARCHAR(50) NOT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS movies (
  id INT AUTO_INCREMENT PRIMARY KEY,
  title VARCHAR(255) NOT NULL,
  overview TEXT,
  release_date DATE,
  vote_average DECIMAL(3,1),
  poster_path VARCHAR(255),
  backdrop_path VARCHAR(255),
  genre_ids JSON,
  original_language VARCHAR(10),
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  video BOOLEAN DEFAULT FALSE,
  video_url TEXT,
  trailer_url TEXT
);

CREATE TABLE IF NOT EXISTS tv_series (
  id INT AUTO_INCREMENT PRIMARY KEY,
  title VARCHAR(255) NOT NULL,
  overview TEXT,
  first_air_date DATE,
  last_air_date DATE,
  vote_average DECIMAL(3,1),
  poster_path VARCHAR(255),
  backdrop_path VARCHAR(255),
  genre_ids JSON,
  original_language VARCHAR(10),
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  video BOOLEAN DEFAULT FALSE,
  video_url TEXT,
  trailer_url TEXT
);

CREATE TABLE IF NOT EXISTS seasons (
  id INT AUTO_INCREMENT PRIMARY KEY,
  tv_series_id INT,
  season_number INT,
  name VARCHAR(255),
  overview TEXT,
  poster_path VARCHAR(255),
  air_date DATE,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (tv_series_id) REFERENCES tv_series(id) ON DELETE CASCADE
);

-- Insert genres data
INSERT INTO genres (name, type, created_at) VALUES
('Action', 'movie', '2025-09-06 18:17:08'),
('Adventure', 'movie', '2025-09-06 18:17:08'),
('Animation', 'tv', '2025-09-06 18:17:09'),
('Comedy', 'tv', '2025-09-06 18:17:09'),
('Crime', 'tv', '2025-09-06 18:17:09'),
('Documentary', 'tv', '2025-09-06 18:17:09'),
('Drama', 'tv', '2025-09-06 18:17:09'),
('Family', 'tv', '2025-09-06 18:17:09'),
('Fantasy', 'movie', '2025-09-06 18:17:09'),
('History', 'movie', '2025-09-06 18:17:09'),
('Horror', 'movie', '2025-09-06 18:17:09'),
('Music', 'movie', '2025-09-06 18:17:09'),
('Mystery', 'tv', '2025-09-06 18:17:09'),
('Romance', 'movie', '2025-09-06 18:17:09'),
('Science Fiction', 'movie', '2025-09-06 18:17:09'),
('TV Movie', 'movie', '2025-09-06 18:17:09'),
('Thriller', 'movie', '2025-09-06 18:17:09'),
('War', 'movie', '2025-09-06 18:17:09'),
('Western', 'tv', '2025-09-06 18:17:09'),
('Action & Adventure', 'tv', '2025-09-06 18:17:09'),
('Kids', 'tv', '2025-09-06 18:17:09'),
('News', 'tv', '2025-09-06 18:17:09'),
('Reality', 'tv', '2025-09-06 18:17:09'),
('Sci-Fi & Fantasy', 'tv', '2025-09-06 18:17:09'),
('Soap', 'tv', '2025-09-06 18:17:09'),
('Talk', 'tv', '2025-09-06 18:17:09'),
('War & Politics', 'tv', '2025-09-06 18:17:09');

-- Insert movies data
INSERT INTO movies (title, overview, release_date, vote_average, poster_path, backdrop_path, genre_ids, original_language, created_at, updated_at, video, video_url, trailer_url) VALUES
('ANTERVYATHAA', 'A psychological thriller that explores the depths of human consciousness and the haunting question: "Do you also hear voices?" This award-winning film has been nominated for 15+ awards at national and international film festivals.', 
'2021-06-01', 8.7, '/images/movies/9.jpeg', '/images/movies/9.jpeg', '[53,27,18]', 'hi', 
'2025-09-06 18:17:08', '2025-09-06 18:17:08', true,
'https://firebasestorage.googleapis.com/v0/b/namkeen-tv-2e1b5.appspot.com/o/ANTERVYATHAA%20-%20AMAZON%20PRIME%20-%20June%202021.mp4?alt=media&token=1c75ecd0-1551-4ea7-9453-a3a60949d5eb',
'https://youtu.be/rcERXIpD3SI?si=w8utbsnpzuPMA1AU'),
('Chunky Pandey', NULL, NULL, NULL, '/images/movies/posterImage-1758264640756-215014902.jpeg', '/images/movies/posterImage-1758264640756-215014902.jpeg', '[18]', 'en',
'2025-09-19 06:50:40', '2025-09-19 06:50:40', NULL, NULL, NULL),
('Chunky Pandey', NULL, NULL, NULL, '/images/movies/posterImage-1758264642841-117682372.jpeg', '/images/movies/posterImage-1758264642841-117682372.jpeg', '[18]', 'en',
'2025-09-19 06:50:42', '2025-09-19 06:50:42', NULL, NULL, NULL),
('Chunky Pandey', NULL, NULL, NULL, '/images/movies/posterImage-1758264650060-623848046.jpeg', '/images/movies/posterImage-1758264650060-623848046.jpeg', '[18]', 'en',
'2025-09-19 06:50:50', '2025-09-19 06:50:50', NULL, NULL, NULL),
('Chunky Ponky', NULL, NULL, NULL, '/images/movies/posterImage-1758264858587-836182551.jpeg', '/images/movies/posterImage-1758264640756-215014902.jpeg', '[18]', 'en',
'2025-09-19 06:50:40', '2025-09-19 06:54:18', NULL, NULL, NULL);

-- Insert tv_series data
INSERT INTO tv_series (title, poster_path, backdrop_path, genre_ids, original_language, created_at, updated_at) VALUES
('poopoo', '/images/tv_series/posterImage-1758265351021-660240754.jpeg', '/images/tv_series/posterImage-1758265200614-911729768.jpeg', '[18]', 'en',
'2025-09-19 07:00:00', '2025-09-19 07:02:44');

-- Insert seasons data
INSERT INTO seasons (tv_series_id, season_number, poster_path, created_at, updated_at) VALUES
(1, 1, '/images/tv_series/default-season-poster.jpg', '2025-09-19 07:09:59', '2025-09-19 07:09:59');