-- Migration script to convert MySQL movie_videos to PostgreSQL Movie schema
-- Run this in your PostgreSQL database

-- Insert movies from old MySQL schema to new Prisma schema
INSERT INTO movies (
    id,
    title,
    overview,
    release_date,
    vote_average,
    poster_path,
    backdrop_path,
    genre_ids,
    original_language,
    video,
    video_url,
    trailer_url,
    created_at,
    updated_at
) VALUES

-- Movie 1: Antervyathaa
(
    1,
    'Antervyathaa',
    'A psychological thriller that explores the depths of human consciousness and the haunting question: "Do you also hear voices?" This award-winning film has been nominated for 15+ awards at national and international film festivals.',
    '2021-06-01 00:00:00',
    8.7,
    'https://storage.googleapis.com/namkeen-tv/content/1/images/poster-1.jpeg',
    'https://storage.googleapis.com/namkeen-tv/content/1/images/backdrop-1.jpeg',
    '[22,16,12]',
    'hi',
    TRUE,
    'https://storage.googleapis.com/namkeen-tv/content/1/movie/master.m3u8',
    'https://storage.googleapis.com/namkeen-tv/content/1/trailer/master.m3u8',
    NOW(),
    NOW()
),

-- Movie 2: Firauti
(
    2,
    'Firauti',
    'Firauti',
    '2025-10-18 14:09:09',
    8.0,
    'https://storage.googleapis.com/namkeen-tv/content/2/images/poster-1.jpeg',
    'https://storage.googleapis.com/namkeen-tv/content/2/images/backdrop-1.jpeg',
    '[22,16,12]',
    'hi',
    TRUE,
    NULL,
    'https://firebasestorage.googleapis.com/v0/b/namkeen-tv-2e1b5.appspot.com/o/Pahal%20Kaun%20Karega%20Trailer%20_UPDATED.mp4?alt=media&token=40f6c4dc-92c2-40ce-a9e8-0646c3ef2944',
    NOW(),
    NOW()
),

-- Movie 3: Pahal Kaun Karega
(
    3,
    'Pahal Kaun Karega',
    'Pahal',
    '2025-10-18 14:15:09',
    8.0,
    'https://storage.googleapis.com/namkeen-tv/content/3/images/poster-1.jpeg',
    'https://storage.googleapis.com/namkeen-tv/content/3/images/backdrop-1.jpeg',
    '[22,16,12]',
    'hi',
    TRUE,
    'https://storage.googleapis.com/namkeen-tv/content/3/movie/master.m3u8',
    'https://storage.googleapis.com/namkeen-tv/content/3/trailer/master.m3u8',
    NOW(),
    NOW()
),

-- Movie 4: Katputali
(
    4,
    'Katputali',
    'Katputali',
    '2025-10-18 14:05:09',
    8.0,
    'https://storage.googleapis.com/namkeen-tv/content/4/images/poster-1.jpeg',
    'https://storage.googleapis.com/namkeen-tv/content/4/images/backdrop-1.jpeg',
    '[22,16,12]',
    'hi',
    TRUE,
    NULL,
    'https://firebasestorage.googleapis.com/v0/b/namkeen-tv-2e1b5.appspot.com/o/Pahal%20Kaun%20Karega%20Trailer%20_UPDATED.mp4?alt=media&token=40f6c4dc-92c2-40ce-a9e8-0646c3ef2944',
    NOW(),
    NOW()
),

-- Movie 5: Love Story 1998
(
    5,
    'Love Story 1998',
    'Love Story 1998 - A romantic drama',
    NULL,
    NULL,
    'upload/96551932.jpg',
    'upload/bg.jpg',
    '[19,12]',
    'hi',
    TRUE,
    'https://firebasestorage.googleapis.com/v0/b/sushilamediatech-1650894594037.appspot.com/o/Love%20Story%20Coreected.mp4?alt=media&token=cbb41fe9-8725-4668-821e-c4341c71c933&_gl=1*q38n0a*_ga*Njg4NDA0MTkyLjE2OTgyMTQ0NTk.*_ga_CW55HF8NVT*MTY5ODMwNjkwOS4xMy4wLjE2OTgzMDY5MDkuNjAuMC4w',
    'https://firebasestorage.googleapis.com/v0/b/sushilamediatech-1650894594037.appspot.com/o/Love%20Story%20Trailer.mp4?alt=media&token=de3e6845-0044-49fb-8de2-893f59a3be7b&_gl=1*5h01ld*_ga*Njg4NDA0MTkyLjE2OTgyMTQ0NTk.*_ga_CW55HF8NVT*MTY5ODI1NzkxNy43LjAuMTY5ODI1NzkxNy42MC4wLjA.',
    NOW(),
    NOW()
),

-- Movie 6: Jaala
(
    6,
    'Jaala',
    'JAALA - A thrilling drama',
    NULL,
    NULL,
    'upload/JAALA.jpg',
    'upload/Untitled design (1).png',
    '[22,12]',
    'hi',
    TRUE,
    'https://firebasestorage.googleapis.com/v0/b/sushilamediatech-1650894594037.appspot.com/o/JAALA%20Corrected.mp4?alt=media&token=377728ec-a00d-4deb-a87f-9be843920cf8&_gl=1*xb3wlc*_ga*Njg4NDA0MTkyLjE2OTgyMTQ0NTk.*_ga_CW55HF8NVT*MTY5ODMwMzA2NS4xMi4xLjE2OTgzMDMxOTAuNjAuMC4w',
    'https://firebasestorage.googleapis.com/v0/b/sushilamediatech-1650894594037.appspot.com/o/Jaala%20TRAILER.mp4?alt=media&token=aa73590d-ac10-4787-92b7-109e6a9ad040&_gl=1*1sysx60*_ga*Njg4NDA0MTkyLjE2OTgyMTQ0NTk.*_ga_CW55HF8NVT*MTY5ODI1NzkxNy43LjEuMTY5ODI1ODI3NC42MC4wLjA.',
    NOW(),
    NOW()
),

-- Movie 7: Jagamemaya
(
    7,
    'Jagamemaya',
    'A swindler tricks a widow into a marriage to settle for life but soon realizes that he is the one who got tricked and the wife is not who she seems and holds dark secrets. Director: Sunil Puppala | Actors: Teja Ainampudi, Dhanya Balakrishna, Keshavdeepak Ballari',
    TO_TIMESTAMP(1671042600),
    NULL,
    'upload/images/MV5BZTA0Yjg5OTUtYzk4NC00OTQ1LWFiMTMtMDg2OGI0ZjVhMTFkXkEyXkFqcGdeQXVyMTQ2NTg1MzAz._V1_SX300.jpg',
    'upload/download.jfif',
    '[12,22]',
    'hi',
    TRUE,
    'https://firebasestorage.googleapis.com/v0/b/sushilamediatech-1650894594037.appspot.com/o/JAGAME%20MAYA%20IN%20HINDI%20MASTER.mp4?alt=media&token=725287a9-c81c-48e6-9d98-36d88e2bab89&_gl=1*1fwjywc*_ga*Njg4NDA0MTkyLjE2OTgyMTQ0NTk.*_ga_CW55HF8NVT*MTY5ODI5MDA5NC4xMC4wLjE2OTgyOTAwOTQuNjAuMC4w',
    'https://firebasestorage.googleapis.com/v0/b/sushilamediatech-1650894594037.appspot.com/o/Jamame%20Maya%20HINDI%20Trailer.mp4?alt=media&token=1d75e2e8-2cbc-478b-8e42-8f02091dc3cc&_gl=1*1sz3sz4*_ga*Njg4NDA0MTkyLjE2OTgyMTQ0NTk.*_ga_CW55HF8NVT*MTY5ODI1NzkxNy43LjEuMTY5ODI1ODgzMy42MC4wLjA.',
    NOW(),
    NOW()
),

-- Movie 8: Skull: The Mask
(
    8,
    'Skull: The Mask',
    'In the year 1944, an artifact is used in a military experiment. The artifact is the Mask of Anhangá, the executioner of Tahawantinsupay, a Pre-Columbian God. The experience fails. Nowadays, the Mask arrives at Sao Paulo. The Mask possesses a body and starts to commit visceral sacrifices on vengeance for the incarnation of its God, initiating a blood bath. Director: Armando Fonseca, Kapel Furman | Actors: Ivo Müller, Lívia Inhudes, Thiago Carvalho',
    TO_TIMESTAMP(1622053800),
    4.9,
    'upload/images/MV5BZDQyNTMyNTAtNTQxYi00NjgwLWJlMDMtYzVkYjdiMDU2OGUxXkEyXkFqcGdeQXVyNTgwMjE3NzA@._V1_SX300.jpg',
    'upload/maxresdefault (3).jpg',
    '[16,22]',
    'pt',
    TRUE,
    'https://firebasestorage.googleapis.com/v0/b/sushilamediatech-1650894594037.appspot.com/o/9.Skull%20The%20Mask%20Trailer.mp4?alt=media&token=b95490a8-6f6f-441d-9ad9-0e906231968b&_gl=1*1qkx3i3*_ga*Njg4NDA0MTkyLjE2OTgyMTQ0NTk.*_ga_CW55HF8NVT*MTY5ODI1NzkxNy43LjEuMTY5ODI1OTM4NC42MC4wLjA.',
    'https://firebasestorage.googleapis.com/v0/b/sushilamediatech-1650894594037.appspot.com/o/9.Skull%20The%20Mask%20Trailer.mp4?alt=media&token=b95490a8-6f6f-441d-9ad9-0e906231968b&_gl=1*1qkx3i3*_ga*Njg4NDA0MTkyLjE2OTgyMTQ0NTk.*_ga_CW55HF8NVT*MTY5ODI1NzkxNy43LjEuMTY5ODI1OTM4NC42MC4wLjA.',
    NOW(),
    NOW()
),

-- Movie 9: Barbarous Mexico
(
    9,
    'Barbarous Mexico',
    'Eight Mexican directors unite to bring tales of the most brutally terrifying Mexican traditions and legends to vividly shocking life. MEXICO BARBARO presents haunting stories that have been woven into the fabric of a nation''s culture, some passed down through the centuries and some new, but all equally frightening. Director: Isaac Ezban, Laurette Flores Bornn, Jorge Michel Grau | Actors: Guillermo Villegas, Marco Zapata, Antonio Monroi',
    TO_TIMESTAMP(1440268200),
    4.7,
    'upload/images/MV5BMjM4NDA4MDc3MV5BMl5BanBnXkFtZTgwOTc1NTkxNzE@._V1_SX300.jpg',
    'upload/maxresdefault (4).jpg',
    '[16]',
    'es',
    TRUE,
    'https://firebasestorage.googleapis.com/v0/b/sushilamediatech-1650894594037.appspot.com/o/8Barbarous%20Mexico%20%20Trailer.mp4?alt=media&token=1a7fb7c2-3a0e-4819-9d4a-07076a7ed23a&_gl=1*l4q7yx*_ga*Njg4NDA0MTkyLjE2OTgyMTQ0NTk.*_ga_CW55HF8NVT*MTY5ODI1NzkxNy43LjEuMTY5ODI1OTU1Ny42MC4wLjA.',
    'https://firebasestorage.googleapis.com/v0/b/sushilamediatech-1650894594037.appspot.com/o/8Barbarous%20Mexico%20%20Trailer.mp4?alt=media&token=1a7fb7c2-3a0e-4819-9d4a-07076a7ed23a&_gl=1*l4q7yx*_ga*Njg4NDA0MTkyLjE2OTgyMTQ0NTk.*_ga_CW55HF8NVT*MTY5ODI1NzkxNy43LjEuMTY5ODI1OTU1Ny42MC4wLjA.',
    NOW(),
    NOW()
),

-- Movie 10: Ghost Killers vs. Bloody Mary
(
    10,
    'Ghost Killers vs. Bloody Mary',
    'Four YouTubers with expertise in supernatural events are seeking recognition from the audience whilst solving the urban legend of the Bathroom Blonde Case: the spirit that haunts the schools'' bathroom in Brazil. Director: Fabrício Bittar | Actors: Danilo Gentili, Murilo Couto, Léo Lins',
    TO_TIMESTAMP(1543429800),
    5.6,
    'upload/ghost-killers-uk-art.jpg',
    'upload/61d16a2c9b6fb9117bcbc58c930ba76a19cda6706c2d0520460967fc35d3d66f.png',
    '[9,16]',
    'pt',
    TRUE,
    'https://firebasestorage.googleapis.com/v0/b/sushilamediatech-1650894594037.appspot.com/o/7Ghost%20Killers%20vs.%20Bloody%20Mary%20Trailer.mp4?alt=media&token=7a7c432b-8fb1-4732-80f0-4ec559689a70&_gl=1*yjpkln*_ga*Njg4NDA0MTkyLjE2OTgyMTQ0NTk.*_ga_CW55HF8NVT*MTY5ODI1NzkxNy43LjEuMTY5ODI1OTY4MS42MC4wLjA.',
    'https://firebasestorage.googleapis.com/v0/b/sushilamediatech-1650894594037.appspot.com/o/7Ghost%20Killers%20vs.%20Bloody%20Mary%20Trailer.mp4?alt=media&token=7a7c432b-8fb1-4732-80f0-4ec559689a70&_gl=1*yjpkln*_ga*Njg4NDA0MTkyLjE2OTgyMTQ0NTk.*_ga_CW55HF8NVT*MTY5ODI1NzkxNy43LjEuMTY5ODI1OTY4MS42MC4wLjA.',
    NOW(),
    NOW()
),

-- Movie 11: The Barge People
(
    11,
    'The Barge People',
    'Four fellas take a barge n explore the canals in the rural side. Unknown to them that tons of toxic waste and hazardous chemicals have been dumped in the water by multinational companies which has caused genetic mutations among some people who have resorted to cannibalism. Director: Charlie Steeds | Actors: Kate Speak, Mark McKirdy, Makenna Guyler',
    TO_TIMESTAMP(1574533800),
    4.2,
    'upload/images/MV5BYzg3NTgxMjEtMzY2Zi00ZmI4LTg0MDAtYmI1MjdiOWY4MmY3XkEyXkFqcGdeQXVyMTEyNDk0MjM@._V1_SX300.jpg',
    'upload/g38K4vriHzvRRfWATNWsxC77wa4.jpg',
    '[16]',
    'en',
    TRUE,
    'https://firebasestorage.googleapis.com/v0/b/sushilamediatech-1650894594037.appspot.com/o/6The%20Barge%20People%20Trailer.mp4?alt=media&token=c82d1d13-17f4-43d8-a54a-82f62c1e073d&_gl=1*1x6f6ya*_ga*Njg4NDA0MTkyLjE2OTgyMTQ0NTk.*_ga_CW55HF8NVT*MTY5ODI1NzkxNy43LjEuMTY5ODI2MDAyMy42MC4wLjA.',
    'https://firebasestorage.googleapis.com/v0/b/sushilamediatech-1650894594037.appspot.com/o/6The%20Barge%20People%20Trailer.mp4?alt=media&token=c82d1d13-17f4-43d8-a54a-82f62c1e073d&_gl=1*1x6f6ya*_ga*Njg4NDA0MTkyLjE2OTgyMTQ0NTk.*_ga_CW55HF8NVT*MTY5ODI1NzkxNy43LjEuMTY5ODI2MDAyMy42MC4wLjA.',
    NOW(),
    NOW()
),

-- Movie 12: Bangkok Hell
(
    12,
    'Bangkok Hell',
    'Ray''s life is turned upside down when he is jailed for the accidental vehicular homicide. Life behind bars is bitter and violent. Over crowding, male rape, and drug abuse are the order of the day. The warden offers him a way out from this daily torment by working for him. Director: Manop Janjarasskul | Actors: Chalad Na Songkhla, Sahatchai ''Stop'' Chumrum, Pornchai Hongrattanaporn',
    TO_TIMESTAMP(1014921000),
    5.5,
    'upload/images/MV5BZmEyZDNmMTYtZTVhOS00NTBmLWIzOGMtMTMxZjcwYTNiZWUxXkEyXkFqcGdeQXVyMzgxODI0MTk@._V1_SX300.jpg',
    'upload/test_pic1674020677007.jpg',
    '[6,12]',
    'th',
    TRUE,
    'https://firebasestorage.googleapis.com/v0/b/sushilamediatech-1650894594037.appspot.com/o/5BANGKOK%20HELL%20TRAILER.mp4?alt=media&token=e3e1bb33-7b02-4a8b-a8c0-1fe8a56fa79f&_gl=1*w44q6o*_ga*Njg4NDA0MTkyLjE2OTgyMTQ0NTk.*_ga_CW55HF8NVT*MTY5ODI1NzkxNy43LjEuMTY5ODI2MDE2My4zMC4wLjA.',
    'https://firebasestorage.googleapis.com/v0/b/sushilamediatech-1650894594037.appspot.com/o/5BANGKOK%20HELL%20TRAILER.mp4?alt=media&token=e3e1bb33-7b02-4a8b-a8c0-1fe8a56fa79f&_gl=1*w44q6o*_ga*Njg4NDA0MTkyLjE2OTgyMTQ0NTk.*_ga_CW55HF8NVT*MTY5ODI1NzkxNy43LjEuMTY5ODI2MDE2My4zMC4wLjA.',
    NOW(),
    NOW()
),

-- Movie 13: Antervyathaa (Duplicate - Old Entry)
(
    13,
    'Antervyathaa',
    'An investigating officer is helped to a case by another person who uses his experiences with fear. He believes that they could use the feeling of insecurity, distress, and fright a criminal feels right after committing a crime to catch him. Will the two be able to make him crumble under his own fear of getting caught? Director: Keshav Arya | Actors: Keshav Arya, Veena Chaudhary, Anuradha Khaira',
    TO_TIMESTAMP(1700764200),
    NULL,
    'upload/images/MV5BYWQ4ZTA2MjMtOGQ2MS00NWQzLTkyODQtNTdlZDY0MTZlNTQ0XkEyXkFqcGdeQXVyNjkwOTg4MTA@._V1_SX300.jpg',
    'upload/sddefault.jpg',
    '[22,12]',
    'hi',
    TRUE,
    NULL,
    'https://firebasestorage.googleapis.com/v0/b/sushilamediatech-1650894594037.appspot.com/o/ANTERVYATHAA%20_%20THEATRICAL%20TRAILER%20_%20Bollywood%20Film%20-%202020.mp4?alt=media&token=ea98df87-1588-4d35-8c51-8ad7338550e7',
    NOW(),
    NOW()
)

ON CONFLICT (id) DO UPDATE SET
    title = EXCLUDED.title,
    overview = EXCLUDED.overview,
    release_date = EXCLUDED.release_date,
    vote_average = EXCLUDED.vote_average,
    poster_path = EXCLUDED.poster_path,
    backdrop_path = EXCLUDED.backdrop_path,
    genre_ids = EXCLUDED.genre_ids,
    original_language = EXCLUDED.original_language,
    video = EXCLUDED.video,
    video_url = EXCLUDED.video_url,
    trailer_url = EXCLUDED.trailer_url,
    updated_at = NOW();

-- Update the sequence to continue from the last inserted ID
SELECT setval('movies_id_seq', (SELECT MAX(id) FROM movies));

-- Verify the data
SELECT id, title, original_language, video_url FROM movies ORDER BY id;
