-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Generation Time: Oct 12, 2025 at 04:46 PM
-- Server version: 10.4.32-MariaDB
-- PHP Version: 8.2.12

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `flutter_video_streaming`
--

-- --------------------------------------------------------

--
-- Table structure for table `genres`
--

CREATE TABLE `genres` (
  `id` int(11) NOT NULL,
  `name` varchar(191) NOT NULL,
  `type` varchar(191) NOT NULL,
  `created_at` datetime(3) NOT NULL DEFAULT current_timestamp(3)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `genres`
--

INSERT INTO `genres` (`id`, `name`, `type`, `created_at`) VALUES
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

-- --------------------------------------------------------

--
-- Table structure for table `movies`
--

CREATE TABLE `movies` (
  `id` int(11) NOT NULL,
  `title` varchar(191) NOT NULL,
  `overview` varchar(191) DEFAULT NULL,
  `release_date` datetime(3) DEFAULT NULL,
  `vote_average` double DEFAULT NULL,
  `poster_path` varchar(191) DEFAULT NULL,
  `backdrop_path` varchar(191) DEFAULT NULL,
  `genre_ids` varchar(191) DEFAULT NULL,
  `original_language` varchar(191) DEFAULT NULL,
  `created_at` datetime(3) NOT NULL DEFAULT current_timestamp(3),
  `updated_at` datetime(3) DEFAULT NULL,
  `video` tinyint(1),
  `video_url` varchar(191) DEFAULT NULL,
  `trailer_url` varchar(191) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `movies`
--

INSERT INTO `movies` (`id`, `title`, `overview`, `release_date`, `vote_average`, `poster_path`, `backdrop_path`, `genre_ids`, `original_language`, `created_at`, `updated_at`, `video`, `video_url`, `trailer_url`) VALUES
(1, 'ANTERVYATHAA', 'A psychological thriller that explores the depths of human consciousness and the haunting question: \"Do you also hear voices?\" This award-winning film has been nominated for 15+ awards at nat', '2021-06-01 00:00:00.000', 8.7, '/images/movies/9.jpeg', '/images/movies/9.jpeg', '[\"53\",\"27\",\"18\"]', 'hi', '2025-09-06 18:17:08.000', '2025-10-12 13:55:37.283', 1, 'https://firebasestorage.googleapis.com/v0/b/namkeen-tv-2e1b5.appspot.com/o/ANTERVYATHAA%20-%20AMAZON%20PRIME%20-%20June%202021.mp4?alt=media&token=1c75ecd0-1551-4ea7-9453-a3a60949d5eb', 'https://youtu.be/rcERXIpD3SI?si=w8utbsnpzuPMA1AU'),
(5, 'Chunky Ponky', NULL, NULL, NULL, '/images/movies/posterImage-1758264858587-836182551.jpeg', '/images/movies/posterImage-1758264640756-215014902.jpeg', '[18]', 'en', '2025-09-19 06:50:40.000', '2025-09-19 06:54:18.000', NULL, NULL, NULL);

-- --------------------------------------------------------

--
-- Table structure for table `rating`
--

CREATE TABLE `rating` (
  `id` int(11) NOT NULL,
  `userId` int(11) NOT NULL,
  `contentId` varchar(191) NOT NULL,
  `contentType` varchar(191) NOT NULL,
  `rating` int(11) NOT NULL,
  `review` varchar(191) DEFAULT NULL,
  `title` varchar(191) DEFAULT NULL,
  `helpful` varchar(191) DEFAULT NULL,
  `spoiler` tinyint(1) NOT NULL DEFAULT 0,
  `tags` varchar(191) DEFAULT NULL,
  `createdAt` datetime(3) NOT NULL DEFAULT current_timestamp(3),
  `updatedAt` datetime(3) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `rating`
--

INSERT INTO `rating` (`id`, `userId`, `contentId`, `contentType`, `rating`, `review`, `title`, `helpful`, `spoiler`, `tags`, `createdAt`, `updatedAt`) VALUES
(1, 10, '2', 'movie', 8, NULL, NULL, NULL, 0, NULL, '2025-10-12 13:49:07.392', '2025-10-12 13:49:07.392'),
(2, 10, '3', 'movie', 8, NULL, NULL, NULL, 0, NULL, '2025-10-12 13:49:31.993', '2025-10-12 13:49:56.014');

-- --------------------------------------------------------

--
-- Table structure for table `seasons`
--

CREATE TABLE `seasons` (
  `id` int(11) NOT NULL,
  `tv_series_id` int(11) DEFAULT NULL,
  `season_number` int(11) DEFAULT NULL,
  `name` varchar(191) DEFAULT NULL,
  `overview` varchar(191) DEFAULT NULL,
  `poster_path` varchar(191) DEFAULT NULL,
  `air_date` datetime(3) DEFAULT NULL,
  `created_at` datetime(3) NOT NULL DEFAULT current_timestamp(3),
  `updated_at` datetime(3) DEFAULT NULL,
  `episode_count` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `seasons`
--

INSERT INTO `seasons` (`id`, `tv_series_id`, `season_number`, `name`, `overview`, `poster_path`, `air_date`, `created_at`, `updated_at`, `episode_count`) VALUES
(1, 1, 1, NULL, NULL, '/images/tv_series/default-season-poster.jpg', NULL, '2025-09-19 07:09:59.000', '2025-09-19 07:09:59.000', NULL);

-- --------------------------------------------------------

--
-- Table structure for table `tv_series`
--

CREATE TABLE `tv_series` (
  `id` int(11) NOT NULL,
  `overview` varchar(191) DEFAULT NULL,
  `first_air_date` datetime(3) DEFAULT NULL,
  `last_air_date` datetime(3) DEFAULT NULL,
  `vote_average` double DEFAULT NULL,
  `poster_path` varchar(191) DEFAULT NULL,
  `backdrop_path` varchar(191) DEFAULT NULL,
  `genre_ids` varchar(191) DEFAULT NULL,
  `original_language` varchar(191) DEFAULT NULL,
  `created_at` datetime(3) NOT NULL DEFAULT current_timestamp(3),
  `updated_at` datetime(3) DEFAULT NULL,
  `video` tinyint(1),
  `video_url` varchar(191) DEFAULT NULL,
  `trailer_url` varchar(191) DEFAULT NULL,
  `name` varchar(191) NOT NULL,
  `number_of_episodes` int(11) DEFAULT NULL,
  `number_of_seasons` int(11) DEFAULT NULL,
  `seasons` varchar(191) DEFAULT NULL,
  `status` varchar(191) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `tv_series`
--

INSERT INTO `tv_series` (`id`, `overview`, `first_air_date`, `last_air_date`, `vote_average`, `poster_path`, `backdrop_path`, `genre_ids`, `original_language`, `created_at`, `updated_at`, `video`, `video_url`, `trailer_url`, `name`, `number_of_episodes`, `number_of_seasons`, `seasons`, `status`) VALUES
(1, NULL, NULL, NULL, NULL, '/images/tv_series/posterImage-1758265351021-660240754.jpeg', '/images/tv_series/posterImage-1758265200614-911729768.jpeg', '[18]', 'en', '2025-09-19 07:00:00.000', '2025-09-19 07:02:44.000', 0, NULL, NULL, 'poopoo', NULL, NULL, NULL, NULL);

-- --------------------------------------------------------

--
-- Table structure for table `user`
--

CREATE TABLE `user` (
  `id` int(11) NOT NULL,
  `email` varchar(191) NOT NULL,
  `password` varchar(191) NOT NULL,
  `username` varchar(191) NOT NULL,
  `profileName` varchar(191) NOT NULL,
  `profileAvatar` varchar(191) DEFAULT NULL,
  `profileAge` int(11) DEFAULT NULL,
  `profileLanguage` varchar(191) DEFAULT NULL,
  `profileMaturity` varchar(191) DEFAULT NULL,
  `preferencesGenres` varchar(191) DEFAULT NULL,
  `preferencesTypes` varchar(191) DEFAULT NULL,
  `preferencesLangs` varchar(191) DEFAULT NULL,
  `preferencesSubtitles` tinyint(1) NOT NULL DEFAULT 0,
  `subscriptionPlan` varchar(191) NOT NULL DEFAULT 'basic',
  `subscriptionStatus` varchar(191) NOT NULL DEFAULT 'active',
  `subscriptionStart` datetime(3) NOT NULL DEFAULT current_timestamp(3),
  `subscriptionEnd` datetime(3) DEFAULT NULL,
  `watchHistory` varchar(191) DEFAULT NULL,
  `isActive` tinyint(1) NOT NULL DEFAULT 1,
  `lastLogin` datetime(3) NOT NULL DEFAULT current_timestamp(3),
  `verificationToken` varchar(191) DEFAULT NULL,
  `resetPasswordToken` varchar(191) DEFAULT NULL,
  `resetPasswordExpires` datetime(3) DEFAULT NULL,
  `createdAt` datetime(3) NOT NULL DEFAULT current_timestamp(3),
  `updatedAt` datetime(3) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `user`
--

INSERT INTO `user` (`id`, `email`, `password`, `username`, `profileName`, `profileAvatar`, `profileAge`, `profileLanguage`, `profileMaturity`, `preferencesGenres`, `preferencesTypes`, `preferencesLangs`, `preferencesSubtitles`, `subscriptionPlan`, `subscriptionStatus`, `subscriptionStart`, `subscriptionEnd`, `watchHistory`, `isActive`, `lastLogin`, `verificationToken`, `resetPasswordToken`, `resetPasswordExpires`, `createdAt`, `updatedAt`) VALUES
(10, 'admin@example.com', '$2a$12$3P5je1p6J6qd5Rf1PIQCaeAvX0gwBTVpqhEhSncOvs0J6Ler5eyu2', 'admin', 'Admin', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 'premium', 'active', '2025-10-12 13:43:29.290', NULL, NULL, 1, '2025-10-12 14:28:18.071', NULL, NULL, NULL, '2025-10-12 13:43:29.290', '2025-10-12 14:28:18.074');

-- --------------------------------------------------------

--
-- Table structure for table `watchlist`
--

CREATE TABLE `watchlist` (
  `id` int(11) NOT NULL,
  `title` varchar(191) NOT NULL,
  `addedAt` datetime(3) NOT NULL DEFAULT current_timestamp(3),
  `backdropPath` varchar(191) DEFAULT NULL,
  `contentId` varchar(191) NOT NULL,
  `contentType` varchar(191) NOT NULL,
  `createdAt` datetime(3) NOT NULL DEFAULT current_timestamp(3),
  `genreIds` varchar(191) DEFAULT NULL,
  `notes` varchar(191) DEFAULT NULL,
  `overview` varchar(191) DEFAULT NULL,
  `posterPath` varchar(191) DEFAULT NULL,
  `priority` varchar(191) NOT NULL DEFAULT 'medium',
  `rating` int(11) DEFAULT NULL,
  `releaseDate` datetime(3) DEFAULT NULL,
  `tags` varchar(191) DEFAULT NULL,
  `updatedAt` datetime(3) NOT NULL,
  `userId` int(11) NOT NULL,
  `voteAverage` double DEFAULT NULL,
  `watched` tinyint(1) NOT NULL DEFAULT 0,
  `watchedAt` datetime(3) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `_prisma_migrations`
--

CREATE TABLE `_prisma_migrations` (
  `id` varchar(36) NOT NULL,
  `checksum` varchar(64) NOT NULL,
  `finished_at` datetime(3) DEFAULT NULL,
  `migration_name` varchar(255) NOT NULL,
  `logs` text DEFAULT NULL,
  `rolled_back_at` datetime(3) DEFAULT NULL,
  `started_at` datetime(3) NOT NULL DEFAULT current_timestamp(3),
  `applied_steps_count` int(10) UNSIGNED NOT NULL DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `_prisma_migrations`
--

INSERT INTO `_prisma_migrations` (`id`, `checksum`, `finished_at`, `migration_name`, `logs`, `rolled_back_at`, `started_at`, `applied_steps_count`) VALUES
('585a02b9-5270-49bf-b43f-76487615b593', 'f248259097ccd842af28a7f41149cba949ddca95815aeba69d1766332b99fd2c', '2025-10-12 13:28:15.425', '20251012132815_dummy', NULL, NULL, '2025-10-12 13:28:15.408', 1),
('7f1d7d38-8574-4bf5-a60e-b1a7daac1317', '395bda2bdfd714ac1545fe156c94c9470d4f6703a254fa463f589ee6f2fa9a0f', '2025-10-12 13:28:10.390', '20251012132704_add_tv_series_fields', NULL, NULL, '2025-10-12 13:28:09.926', 1),
('d60f0814-d23d-4888-806b-78d73437c5bf', '6ea6e7955371bbb94217c8dc27533a841f6ffb26d09e2fdf69c3ab47a5b638d9', '2025-10-12 13:26:27.208', '0001_init', NULL, NULL, '2025-10-12 13:26:27.005', 1);

--
-- Indexes for dumped tables
--

--
-- Indexes for table `genres`
--
ALTER TABLE `genres`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `movies`
--
ALTER TABLE `movies`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `rating`
--
ALTER TABLE `rating`
  ADD PRIMARY KEY (`id`),
  ADD KEY `Rating_userId_fkey` (`userId`);

--
-- Indexes for table `seasons`
--
ALTER TABLE `seasons`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `tv_series`
--
ALTER TABLE `tv_series`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `user`
--
ALTER TABLE `user`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `User_email_key` (`email`),
  ADD UNIQUE KEY `User_username_key` (`username`);

--
-- Indexes for table `watchlist`
--
ALTER TABLE `watchlist`
  ADD PRIMARY KEY (`id`),
  ADD KEY `Watchlist_userId_fkey` (`userId`);

--
-- Indexes for table `_prisma_migrations`
--
ALTER TABLE `_prisma_migrations`
  ADD PRIMARY KEY (`id`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `genres`
--
ALTER TABLE `genres`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=28;

--
-- AUTO_INCREMENT for table `movies`
--
ALTER TABLE `movies`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=12;

--
-- AUTO_INCREMENT for table `rating`
--
ALTER TABLE `rating`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT for table `seasons`
--
ALTER TABLE `seasons`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT for table `tv_series`
--
ALTER TABLE `tv_series`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT for table `user`
--
ALTER TABLE `user`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=11;

--
-- AUTO_INCREMENT for table `watchlist`
--
ALTER TABLE `watchlist`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `rating`
--
ALTER TABLE `rating`
  ADD CONSTRAINT `Rating_userId_fkey` FOREIGN KEY (`userId`) REFERENCES `user` (`id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints for table `watchlist`
--
ALTER TABLE `watchlist`
  ADD CONSTRAINT `Watchlist_userId_fkey` FOREIGN KEY (`userId`) REFERENCES `user` (`id`) ON DELETE CASCADE ON UPDATE CASCADE;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
