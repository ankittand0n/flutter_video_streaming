-- phpMyAdmin SQL Dump
-- version 5.2.2
-- https://www.phpmyadmin.net/
--
-- Host: localhost:3306
-- Generation Time: Nov 01, 2025 at 08:58 AM
-- Server version: 11.4.8-MariaDB-cll-lve-log
-- PHP Version: 8.3.26

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `namkasgl_newnamkeen`
--

-- --------------------------------------------------------

--
-- Table structure for table `movie_videos`
--

CREATE TABLE `movie_videos` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `video_access` varchar(255) NOT NULL DEFAULT 'Paid',
  `movie_lang_id` int(11) NOT NULL,
  `movie_genre_id` text NOT NULL,
  `upcoming` int(1) NOT NULL DEFAULT 0,
  `video_title` text NOT NULL,
  `release_date` int(11) DEFAULT NULL,
  `duration` varchar(255) DEFAULT NULL,
  `video_description` text DEFAULT NULL,
  `actor_id` text DEFAULT NULL,
  `director_id` text DEFAULT NULL,
  `video_slug` varchar(200) DEFAULT NULL,
  `video_image_thumb` varchar(255) DEFAULT NULL,
  `video_image` varchar(200) DEFAULT NULL,
  `trailer_url` text DEFAULT NULL,
  `video_type` varchar(255) DEFAULT NULL,
  `video_quality` int(1) DEFAULT NULL,
  `video_url` longtext DEFAULT NULL,
  `video_url_480` varchar(255) DEFAULT NULL,
  `video_url_720` varchar(255) DEFAULT NULL,
  `video_url_1080` varchar(255) DEFAULT NULL,
  `download_enable` int(1) DEFAULT NULL,
  `download_url` varchar(500) DEFAULT NULL,
  `subtitle_on_off` int(1) DEFAULT NULL,
  `subtitle_language1` varchar(255) DEFAULT NULL,
  `subtitle_url1` varchar(500) DEFAULT NULL,
  `subtitle_language2` varchar(255) DEFAULT NULL,
  `subtitle_url2` varchar(255) DEFAULT NULL,
  `subtitle_language3` varchar(255) DEFAULT NULL,
  `subtitle_url3` varchar(255) DEFAULT NULL,
  `imdb_id` varchar(255) DEFAULT NULL,
  `imdb_rating` varchar(255) DEFAULT NULL,
  `imdb_votes` varchar(255) DEFAULT NULL,
  `seo_title` varchar(255) DEFAULT NULL,
  `seo_description` varchar(500) DEFAULT NULL,
  `seo_keyword` varchar(500) DEFAULT NULL,
  `views` bigint(20) NOT NULL DEFAULT 0,
  `content_rating` varchar(255) DEFAULT NULL,
  `status` int(1) NOT NULL DEFAULT 1,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `movie_videos`
--

INSERT INTO `movie_videos` (`id`, `video_access`, `movie_lang_id`, `movie_genre_id`, `upcoming`, `video_title`, `release_date`, `duration`, `video_description`, `actor_id`, `director_id`, `video_slug`, `video_image_thumb`, `video_image`, `trailer_url`, `video_type`, `video_quality`, `video_url`, `video_url_480`, `video_url_720`, `video_url_1080`, `download_enable`, `download_url`, `subtitle_on_off`, `subtitle_language1`, `subtitle_url1`, `subtitle_language2`, `subtitle_url2`, `subtitle_language3`, `subtitle_url3`, `imdb_id`, `imdb_rating`, `imdb_votes`, `seo_title`, `seo_description`, `seo_keyword`, `views`, `content_rating`, `status`, `created_at`, `updated_at`) VALUES
(45, 'Free', 1, '1', 0, 'Pehal Kaun Karega', 1698258600, '70 Minutes', '<p>Namkeen TV | Pehal Kaun Karega&nbsp;</p>', '224,260,258,225', NULL, 'pehal-kaun-karega', 'upload/WhatsApp Image 2023-12-21 at 8.24.53 PM.jpeg', 'upload/WhatsApp Image 2023-12-21 at 8.24.52 PM.jpeg', 'https://firebasestorage.googleapis.com/v0/b/sushilamediatech-1650894594037.appspot.com/o/Pahal%20Kaun%20Karega%20Trailer%20_UPDATED.mp4?alt=media&token=3611a185-e598-433d-91ff-aa10d2c305d6&_gl=1*14r0608*_ga*Njg4NDA0MTkyLjE2OTgyMTQ0NTk.*_ga_CW55HF8NVT*MTY5ODIzMDgyNS4yLjEuMTY5ODIzMDg2Ni4xOS4wLjA.', 'URL', 1, 'https://namkeentv.s3.ap-south-1.amazonaws.com/480+p.mp4', 'https://namkeentv.s3.ap-south-1.amazonaws.com/480+p.mp4', 'https://namkeentv.s3.ap-south-1.amazonaws.com/720new.mp4', NULL, 0, NULL, 0, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'Namkeen TV | Pehal Kaun Karega', 'Namkeen TV | Pehal Kaun Karega', 'Namkeen TV | Pehal Kaun Karega', 3294, NULL, 1, NULL, '2024-12-26 07:57:21'),
(46, 'Paid', 1, '1', 0, 'Katputali', 1702578600, NULL, '<h1 class=\\\"style-scope ytd-watch-metadata\\\">Katputali | Watch This Upcoming Series Only on Namkeen TV</h1>', NULL, NULL, 'katputali', 'upload/WhatsApp Image 2023-10-26 at 08.21.44.jpeg', NULL, 'https://firebasestorage.googleapis.com/v0/b/sushilamediatech-1650894594037.appspot.com/o/Katputli_trailar_L%20(2).mp4?alt=media&token=19741eb8-becc-4e73-966d-4966ab1ddd16&_gl=1*kt5lvn*_ga*Njg4NDA0MTkyLjE2OTgyMTQ0NTk.*_ga_CW55HF8NVT*MTY5ODI0NzY4NS40LjEuMTY5ODI0ODc5Mi40OC4wLjA.', 'Local', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'Katputali | Watch This Upcoming Series Only on Namkeen TV', 'Katputali | Watch This Upcoming Series Only on Namkeen TV', 'Katputali | Watch This Upcoming Series Only on Namkeen TV', 468, NULL, 1, NULL, '2024-12-10 08:23:13'),
(47, 'Paid', 1, '2', 0, 'Reddy Garintlo Rowdyism', 1631817000, 'N/A', '<p>N/A</p>\r\n<p><strong>Director</strong>: Ramesh Gopi</p>\r\n<p><strong>Writer</strong>: N/A</p>\r\n<p><strong>Actors</strong>: Ankitha, Pavani, Priyanka</p>\r\n<p><strong>Production</strong>: N/A</p>', '227,228,229', '226', 'reddy-garintlo-rowdyism', 'upload/images/MV5BYTRhNDRiMTQtYjU3OS00NmNmLWE5MmUtMjI2NjgxZjQ0OGRmXkEyXkFqcGdeQXVyOTc2MTgwNjY@._V1_SX300.jpg', 'upload/maxresdefault.jpg', 'https://namkeentv.s3.ap-south-1.amazonaws.com/Redygar+Trailer+.mp4', 'URL', 0, 'https://firebasestorage.googleapis.com/v0/b/sushilamediatech-1650894594037.appspot.com/o/REDDYGAR%20IN%20HINDI%20MASTER.mp4?alt=media&token=7fb61cff-102b-43ec-88bc-346b71e013c0&_gl=1*15s2imk*_ga*Njg4NDA0MTkyLjE2OTgyMTQ0NTk.*_ga_CW55HF8NVT*MTY5ODMxMTU4Ny4xNC4wLjE2OTgzMTE1ODcuNjAuMC4w', NULL, NULL, NULL, 0, NULL, 0, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'N/A', NULL, '', '', '', 48, NULL, 1, NULL, '2024-08-31 16:09:37'),
(48, 'Paid', 1, '2', 1, 'Royal Mechanic', -19800, NULL, '<h1 class=\\\"style-scope ytd-watch-metadata\\\">Shravya Rao (Rose Fame) Royal Mechanic Action Hindi Dubbed Movie | Dhanush, Raghavendra Rajkumar |</h1>', NULL, NULL, 'royal-mechanic', 'upload/Untitled design.png', 'upload/maxresdefault (1).jpg', 'https://firebasestorage.googleapis.com/v0/b/sushilamediatech-1650894594037.appspot.com/o/ROYAL%20MECH%20TRAILER.mp4?alt=media&token=bfb4a1f5-d733-4d4f-826a-828aee781dda&_gl=1*46p8pi*_ga*Njg4NDA0MTkyLjE2OTgyMTQ0NTk.*_ga_CW55HF8NVT*MTY5ODI0NzY4NS40LjEuMTY5ODI0OTM0NS42MC4wLjA.', 'URL', 0, 'https://firebasestorage.googleapis.com/v0/b/sushilamediatech-1650894594037.appspot.com/o/ROYAL%20MECH%20IN%20HINDI%20MASTER.mp4?alt=media&token=ab0777fb-867d-4152-a1f8-bcedce3b16c8&_gl=1*1etrtqo*_ga*Njg4NDA0MTkyLjE2OTgyMTQ0NTk.*_ga_CW55HF8NVT*MTY5ODI5OTYyMS4xMS4xLjE2OTgyOTk3MzMuNjAuMC4w', NULL, NULL, NULL, 0, NULL, 0, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'Shravya Rao (Rose Fame) Royal Mechanic Action Hindi Dubbed Movie | Dhanush, Raghavendra Rajkumar |', 'Shravya Rao (Rose Fame) Royal Mechanic Action Hindi Dubbed Movie | Dhanush, Raghavendra Rajkumar |', 'Shravya Rao (Rose Fame) Royal Mechanic Action Hindi Dubbed Movie | Dhanush, Raghavendra Rajkumar |', 70, NULL, 1, NULL, '2024-11-30 10:59:44'),
(49, 'Paid', 1, '8', 1, 'Love Story 1998', -19800, NULL, '<h1 class=\\\"banner__EventHeading-sc-qswwm9-6 bzWuzb\\\">Love Story 1998</h1>', NULL, NULL, 'love-story-1998', 'upload/96551932.jpg', 'upload/bg.jpg', 'https://firebasestorage.googleapis.com/v0/b/sushilamediatech-1650894594037.appspot.com/o/Love%20Story%20Trailer.mp4?alt=media&token=de3e6845-0044-49fb-8de2-893f59a3be7b&_gl=1*5h01ld*_ga*Njg4NDA0MTkyLjE2OTgyMTQ0NTk.*_ga_CW55HF8NVT*MTY5ODI1NzkxNy43LjAuMTY5ODI1NzkxNy42MC4wLjA.', 'URL', 0, 'https://firebasestorage.googleapis.com/v0/b/sushilamediatech-1650894594037.appspot.com/o/Love%20Story%20Coreected.mp4?alt=media&token=cbb41fe9-8725-4668-821e-c4341c71c933&_gl=1*q38n0a*_ga*Njg4NDA0MTkyLjE2OTgyMTQ0NTk.*_ga_CW55HF8NVT*MTY5ODMwNjkwOS4xMy4wLjE2OTgzMDY5MDkuNjAuMC4w', NULL, NULL, NULL, 0, NULL, 0, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '', '', '', 151, NULL, 1, NULL, '2024-12-25 15:41:18'),
(50, 'Paid', 1, '1', 0, 'Jaala', -19800, NULL, '<h3 class=\\\"MCLffc cS4Vcb-pGL6qe-fwJd0c\\\">JAALA&nbsp;</h3>', NULL, NULL, 'jaala', 'upload/JAALA.jpg', 'upload/Untitled design (1).png', 'https://firebasestorage.googleapis.com/v0/b/sushilamediatech-1650894594037.appspot.com/o/Jaala%20TRAILER.mp4?alt=media&token=aa73590d-ac10-4787-92b7-109e6a9ad040&_gl=1*1sysx60*_ga*Njg4NDA0MTkyLjE2OTgyMTQ0NTk.*_ga_CW55HF8NVT*MTY5ODI1NzkxNy43LjEuMTY5ODI1ODI3NC42MC4wLjA.', 'URL', 0, 'https://firebasestorage.googleapis.com/v0/b/sushilamediatech-1650894594037.appspot.com/o/JAALA%20Corrected.mp4?alt=media&token=377728ec-a00d-4deb-a87f-9be843920cf8&_gl=1*xb3wlc*_ga*Njg4NDA0MTkyLjE2OTgyMTQ0NTk.*_ga_CW55HF8NVT*MTY5ODMwMzA2NS4xMi4xLjE2OTgzMDMxOTAuNjAuMC4w', NULL, NULL, NULL, 0, NULL, 0, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '', '', '', 49, NULL, 1, NULL, '2024-10-01 23:17:36'),
(51, 'Paid', 1, '5', 1, 'Jagamemaya', 1671042600, 'N/A', '<p>A swindler tricks a widow into a marriage to settle for life but soon realizes that he is the one who got tricked and the wife is not who she seems and holds dark secrets.</p>\r\n<p><strong>Director</strong>: Sunil Puppala</p>\r\n<p><strong>Writer</strong>: Addala Ajay Sharann, Carthyk-Arjun, Sunil Puppala</p>\r\n<p><strong>Actors</strong>: Teja Ainampudi, Dhanya Balakrishna, Keshavdeepak Ballari</p>\r\n<p><strong>Production</strong>: N/A</p>', '232,233,231', '230', 'jagamemaya', 'upload/images/MV5BZTA0Yjg5OTUtYzk4NC00OTQ1LWFiMTMtMDg2OGI0ZjVhMTFkXkEyXkFqcGdeQXVyMTQ2NTg1MzAz._V1_SX300.jpg', 'upload/download.jfif', 'https://firebasestorage.googleapis.com/v0/b/sushilamediatech-1650894594037.appspot.com/o/Jamame%20Maya%20HINDI%20Trailer.mp4?alt=media&token=1d75e2e8-2cbc-478b-8e42-8f02091dc3cc&_gl=1*1sz3sz4*_ga*Njg4NDA0MTkyLjE2OTgyMTQ0NTk.*_ga_CW55HF8NVT*MTY5ODI1NzkxNy43LjEuMTY5ODI1ODgzMy42MC4wLjA.', 'URL', 0, 'https://firebasestorage.googleapis.com/v0/b/sushilamediatech-1650894594037.appspot.com/o/JAGAME%20MAYA%20IN%20HINDI%20MASTER.mp4?alt=media&token=725287a9-c81c-48e6-9d98-36d88e2bab89&_gl=1*1fwjywc*_ga*Njg4NDA0MTkyLjE2OTgyMTQ0NTk.*_ga_CW55HF8NVT*MTY5ODI5MDA5NC4xMC4wLjE2OTgyOTAwOTQuNjAuMC4w', NULL, NULL, NULL, 0, NULL, 0, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'N/A', NULL, '', '', '', 187, NULL, 1, NULL, '2024-12-13 02:13:00'),
(52, 'Paid', 1, '11,6', 0, 'Skull: The Mask', 1622053800, '90 min', '<p>In the year 1944, an artifact is used in a military experiment. The artifact is the Mask of Anhang&aacute;, the executioner of Tahawantinsupay, a Pre-Columbian God. The experience fails. Nowadays, the Mask arrives at Sao Paulo. The Mask possesses a body and starts to commit visceral sacrifices on vengeance for the incarnation of its God, initiating a blood bath. The policewoman Beatriz Obdias is in charge of the crimes, challenging her beliefs. A true mystical slasher film in the city of Sao Paulo.</p>\r\n<p><strong>Director</strong>: Armando Fonseca, Kapel Furman</p>\r\n<p><strong>Writer</strong>: Armando Fonseca, Kapel Furman</p>\r\n<p><strong>Actors</strong>: Ivo M&uuml;ller, L&iacute;via Inhudes, Thiago Carvalho</p>\r\n<p><strong>Production</strong>: N/A</p>', '236,237,238', '234,235', 'skull-the-mask', 'upload/images/MV5BZDQyNTMyNTAtNTQxYi00NjgwLWJlMDMtYzVkYjdiMDU2OGUxXkEyXkFqcGdeQXVyNTgwMjE3NzA@._V1_SX300.jpg', 'upload/maxresdefault (3).jpg', 'https://firebasestorage.googleapis.com/v0/b/sushilamediatech-1650894594037.appspot.com/o/9.Skull%20The%20Mask%20Trailer.mp4?alt=media&token=b95490a8-6f6f-441d-9ad9-0e906231968b&_gl=1*1qkx3i3*_ga*Njg4NDA0MTkyLjE2OTgyMTQ0NTk.*_ga_CW55HF8NVT*MTY5ODI1NzkxNy43LjEuMTY5ODI1OTM4NC42MC4wLjA.', 'URL', 0, 'https://firebasestorage.googleapis.com/v0/b/sushilamediatech-1650894594037.appspot.com/o/9.Skull%20The%20Mask%20Trailer.mp4?alt=media&token=b95490a8-6f6f-441d-9ad9-0e906231968b&_gl=1*1qkx3i3*_ga*Njg4NDA0MTkyLjE2OTgyMTQ0NTk.*_ga_CW55HF8NVT*MTY5ODI1NzkxNy43LjEuMTY5ODI1OTM4NC42MC4wLjA.', NULL, NULL, NULL, 0, NULL, 0, NULL, NULL, NULL, NULL, NULL, NULL, 'tt8447170', '4.9', '909', '', '', '', 26, NULL, 1, NULL, '2024-11-30 10:59:04'),
(53, 'Paid', 1, '6', 0, 'Barbarous Mexico', 1440268200, '114 min', '<p>Eight Mexican directors unite to bring tales of the most brutally terrifying Mexican traditions and legends to vividly shocking life. MEXICO BARBARO presents haunting stories that have been woven into the fabric of a nation\\\'s culture, some passed down through the centuries and some new, but all equally frightening. Stories of boogeymen, trolls, ghosts, monsters, Aztec sacrifices, and of course the Day of the Dead all come together in urban and rural settings to create an anthology that is as original as it is familiar and as important as it is horrifying.</p>\r\n<p><strong>Director</strong>: Isaac Ezban, Laurette Flores Bornn, Jorge Michel Grau</p>\r\n<p><strong>Writer</strong>: Isaac Ezban, Laurette Flores Bornn, Jorge Michel Grau</p>\r\n<p><strong>Actors</strong>: Guillermo Villegas, Marco Zapata, Antonio Monroi</p>\r\n<p><strong>Production</strong>: N/A</p>', '242,243,244', '239,240,241', 'barbarous-mexico', 'upload/images/MV5BMjM4NDA4MDc3MV5BMl5BanBnXkFtZTgwOTc1NTkxNzE@._V1_SX300.jpg', 'upload/maxresdefault (4).jpg', 'https://firebasestorage.googleapis.com/v0/b/sushilamediatech-1650894594037.appspot.com/o/8Barbarous%20Mexico%20%20Trailer.mp4?alt=media&token=1a7fb7c2-3a0e-4819-9d4a-07076a7ed23a&_gl=1*l4q7yx*_ga*Njg4NDA0MTkyLjE2OTgyMTQ0NTk.*_ga_CW55HF8NVT*MTY5ODI1NzkxNy43LjEuMTY5ODI1OTU1Ny42MC4wLjA.', 'URL', 0, 'https://firebasestorage.googleapis.com/v0/b/sushilamediatech-1650894594037.appspot.com/o/8Barbarous%20Mexico%20%20Trailer.mp4?alt=media&token=1a7fb7c2-3a0e-4819-9d4a-07076a7ed23a&_gl=1*l4q7yx*_ga*Njg4NDA0MTkyLjE2OTgyMTQ0NTk.*_ga_CW55HF8NVT*MTY5ODI1NzkxNy43LjEuMTY5ODI1OTU1Ny42MC4wLjA.', NULL, NULL, NULL, 0, NULL, 0, NULL, NULL, NULL, NULL, NULL, NULL, 'tt3363888', '4.7', '1,003', '', '', '', 87, NULL, 1, NULL, '2024-12-21 08:38:41'),
(54, 'Paid', 1, '3,6', 0, 'Ghost Killers vs. Bloody Mary', 1543429800, '108 min', '<p>Four YouTubers with expertise in supernatural events are seeking recognition from the audience whilst solving the urban legend of the Bathroom Blonde Case: the spirit that haunts the schools\\\' bathroom in Brazil.</p>\r\n<p><strong>Director</strong>: Fabr&iacute;cio Bittar</p>\r\n<p><strong>Writer</strong>: Danilo Gentili, Fabr&iacute;cio Bittar, Andre Catarinacho</p>\r\n<p><strong>Actors</strong>: Danilo Gentili, Murilo Couto, L&eacute;o Lins</p>\r\n<p><strong>Production</strong>: N/A</p>', '246,247,248', '245', 'ghost-killers-vs-bloody-mary', 'upload/ghost-killers-uk-art.jpg', 'upload/61d16a2c9b6fb9117bcbc58c930ba76a19cda6706c2d0520460967fc35d3d66f.png', 'https://firebasestorage.googleapis.com/v0/b/sushilamediatech-1650894594037.appspot.com/o/7Ghost%20Killers%20vs.%20Bloody%20Mary%20Trailer.mp4?alt=media&token=7a7c432b-8fb1-4732-80f0-4ec559689a70&_gl=1*yjpkln*_ga*Njg4NDA0MTkyLjE2OTgyMTQ0NTk.*_ga_CW55HF8NVT*MTY5ODI1NzkxNy43LjEuMTY5ODI1OTY4MS42MC4wLjA.', 'URL', 0, 'https://firebasestorage.googleapis.com/v0/b/sushilamediatech-1650894594037.appspot.com/o/7Ghost%20Killers%20vs.%20Bloody%20Mary%20Trailer.mp4?alt=media&token=7a7c432b-8fb1-4732-80f0-4ec559689a70&_gl=1*yjpkln*_ga*Njg4NDA0MTkyLjE2OTgyMTQ0NTk.*_ga_CW55HF8NVT*MTY5ODI1NzkxNy43LjEuMTY5ODI1OTY4MS42MC4wLjA.', NULL, NULL, NULL, 0, NULL, 0, NULL, NULL, NULL, NULL, NULL, NULL, 'tt8753660', '5.6', '1,710', '', '', '', 136, NULL, 1, NULL, '2024-12-13 09:40:08'),
(55, 'Paid', 2, '6', 0, 'The Barge People', 1574533800, '83 min', '<p>Four fellas take a barge n explore the canals in the rural side. Unknown to them that tons of toxic waste and hazardous chemicals have been dumped in the water by multinational companies which has caused genetic mutations among some people who have resorted to cannibalism.</p>\r\n<p><strong>Director</strong>: Charlie Steeds</p>\r\n<p><strong>Writer</strong>: Christopher Lombard</p>\r\n<p><strong>Actors</strong>: Kate Speak, Mark McKirdy, Makenna Guyler</p>\r\n<p><strong>Production</strong>: N/A</p>', '250,251,252', '249', 'the-barge-people', 'upload/images/MV5BYzg3NTgxMjEtMzY2Zi00ZmI4LTg0MDAtYmI1MjdiOWY4MmY3XkEyXkFqcGdeQXVyMTEyNDk0MjM@._V1_SX300.jpg', 'upload/g38K4vriHzvRRfWATNWsxC77wa4.jpg', 'https://firebasestorage.googleapis.com/v0/b/sushilamediatech-1650894594037.appspot.com/o/6The%20Barge%20People%20Trailer.mp4?alt=media&token=c82d1d13-17f4-43d8-a54a-82f62c1e073d&_gl=1*1x6f6ya*_ga*Njg4NDA0MTkyLjE2OTgyMTQ0NTk.*_ga_CW55HF8NVT*MTY5ODI1NzkxNy43LjEuMTY5ODI2MDAyMy42MC4wLjA.', 'URL', 0, 'https://firebasestorage.googleapis.com/v0/b/sushilamediatech-1650894594037.appspot.com/o/6The%20Barge%20People%20Trailer.mp4?alt=media&token=c82d1d13-17f4-43d8-a54a-82f62c1e073d&_gl=1*1x6f6ya*_ga*Njg4NDA0MTkyLjE2OTgyMTQ0NTk.*_ga_CW55HF8NVT*MTY5ODI1NzkxNy43LjEuMTY5ODI2MDAyMy42MC4wLjA.', NULL, NULL, NULL, 0, NULL, 0, NULL, NULL, NULL, NULL, NULL, NULL, 'tt7545216', '4.2', '548', '', '', '', 35, NULL, 1, NULL, '2024-12-10 08:23:27'),
(56, 'Paid', 1, '2,1', 0, 'Bangkok Hell', 1014921000, '90 min', '<p>Ray\\\'s life is turned upside down when he is jailed for the accidental vehicular homicide. Life behind bars is bitter and violent. Over crowding, male rape, and drug abuse are the order of the day. The warden offers him a way out from this daily torment by working for him. He does his job well but he soon begins to realize that many of those incarcerated are innocent or victims of bad circumstances - but what can he do to help and how much danger is he placing himself in?</p>\r\n<p><strong>Director</strong>: Manop Janjarasskul</p>\r\n<p><strong>Writer</strong>: Manop Janjarasskul</p>\r\n<p><strong>Actors</strong>: Chalad Na Songkhla, Sahatchai \\\'Stop\\\' Chumrum, Pornchai Hongrattanaporn</p>\r\n<p><strong>Production</strong>: N/A</p>', '254,,256', '253', 'bangkok-hell', 'upload/images/MV5BZmEyZDNmMTYtZTVhOS00NTBmLWIzOGMtMTMxZjcwYTNiZWUxXkEyXkFqcGdeQXVyMzgxODI0MTk@._V1_SX300.jpg', 'upload/test_pic1674020677007.jpg', 'https://firebasestorage.googleapis.com/v0/b/sushilamediatech-1650894594037.appspot.com/o/5BANGKOK%20HELL%20TRAILER.mp4?alt=media&token=e3e1bb33-7b02-4a8b-a8c0-1fe8a56fa79f&_gl=1*w44q6o*_ga*Njg4NDA0MTkyLjE2OTgyMTQ0NTk.*_ga_CW55HF8NVT*MTY5ODI1NzkxNy43LjEuMTY5ODI2MDE2My4zMC4wLjA.', 'URL', 0, 'https://firebasestorage.googleapis.com/v0/b/sushilamediatech-1650894594037.appspot.com/o/5BANGKOK%20HELL%20TRAILER.mp4?alt=media&token=e3e1bb33-7b02-4a8b-a8c0-1fe8a56fa79f&_gl=1*w44q6o*_ga*Njg4NDA0MTkyLjE2OTgyMTQ0NTk.*_ga_CW55HF8NVT*MTY5ODI1NzkxNy43LjEuMTY5ODI2MDE2My4zMC4wLjA.', NULL, NULL, NULL, 0, NULL, 0, NULL, NULL, NULL, NULL, NULL, NULL, 'tt0470451', '5.5', '94', '', '', '', 98, NULL, 1, NULL, '2024-12-09 08:10:12'),
(57, 'Paid', 1, '1', 1, 'Antervyathaa', 1700764200, '115 min', '<p>An investigating officer is helped to a case by another person who uses his experiences with fear. He believes that they could use the feeling of insecurity, distress, and fright a criminal feels right after committing a crime to catch him. Will the two be able to make him crumble under his own fear of getting caught?</p>\r\n<p><strong>Director</strong>: Keshav Arya</p>\r\n<p><strong>Writer</strong>: N/A</p>\r\n<p><strong>Actors</strong>: Keshav Arya, Veena Chaudhary, Anuradha Khaira</p>\r\n<p><strong>Production</strong>: N/A</p>', '263,224,262', NULL, 'antervyathaa', 'upload/images/MV5BYWQ4ZTA2MjMtOGQ2MS00NWQzLTkyODQtNTdlZDY0MTZlNTQ0XkEyXkFqcGdeQXVyNjkwOTg4MTA@._V1_SX300.jpg', 'upload/sddefault.jpg', 'https://firebasestorage.googleapis.com/v0/b/sushilamediatech-1650894594037.appspot.com/o/ANTERVYATHAA%20_%20THEATRICAL%20TRAILER%20_%20Bollywood%20Film%20-%202020.mp4?alt=media&token=ea98df87-1588-4d35-8c51-8ad7338550e7', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'N/A', NULL, '', '', '', 451, NULL, 1, NULL, '2024-12-10 10:11:12');

--
-- Indexes for dumped tables
--

--
-- Indexes for table `movie_videos`
--
ALTER TABLE `movie_videos`
  ADD PRIMARY KEY (`id`),
  ADD KEY `type_status_date` (`id`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `movie_videos`
--
ALTER TABLE `movie_videos`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=58;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
