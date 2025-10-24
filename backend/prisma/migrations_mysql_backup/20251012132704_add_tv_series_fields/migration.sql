/*
  Warnings:

  - You are about to alter the column `name` on the `genres` table. The data in that column could be lost. The data in that column will be cast from `VarChar(255)` to `VarChar(191)`.
  - You are about to alter the column `title` on the `movies` table. The data in that column could be lost. The data in that column will be cast from `VarChar(255)` to `VarChar(191)`.
  - You are about to alter the column `vote_average` on the `movies` table. The data in that column could be lost. The data in that column will be cast from `Decimal(3,1)` to `Double`.
  - You are about to alter the column `poster_path` on the `movies` table. The data in that column could be lost. The data in that column will be cast from `VarChar(255)` to `VarChar(191)`.
  - You are about to alter the column `backdrop_path` on the `movies` table. The data in that column could be lost. The data in that column will be cast from `VarChar(255)` to `VarChar(191)`.
  - You are about to alter the column `name` on the `seasons` table. The data in that column could be lost. The data in that column will be cast from `VarChar(255)` to `VarChar(191)`.
  - You are about to alter the column `poster_path` on the `seasons` table. The data in that column could be lost. The data in that column will be cast from `VarChar(255)` to `VarChar(191)`.
  - You are about to drop the column `title` on the `tv_series` table. All the data in the column will be lost.
  - You are about to alter the column `vote_average` on the `tv_series` table. The data in that column could be lost. The data in that column will be cast from `Decimal(3,1)` to `Double`.
  - You are about to alter the column `poster_path` on the `tv_series` table. The data in that column could be lost. The data in that column will be cast from `VarChar(255)` to `VarChar(191)`.
  - You are about to alter the column `backdrop_path` on the `tv_series` table. The data in that column could be lost. The data in that column will be cast from `VarChar(255)` to `VarChar(191)`.
  - You are about to drop the column `created_at` on the `watchlist` table. All the data in the column will be lost.
  - You are about to drop the column `media_id` on the `watchlist` table. All the data in the column will be lost.
  - You are about to drop the column `media_type` on the `watchlist` table. All the data in the column will be lost.
  - You are about to drop the column `poster_path` on the `watchlist` table. All the data in the column will be lost.
  - You are about to drop the column `user_id` on the `watchlist` table. All the data in the column will be lost.
  - You are about to alter the column `title` on the `watchlist` table. The data in that column could be lost. The data in that column will be cast from `VarChar(255)` to `VarChar(191)`.
  - You are about to drop the `ratings` table. If the table is not empty, all the data it contains will be lost.
  - You are about to drop the `users` table. If the table is not empty, all the data it contains will be lost.
  - Added the required column `name` to the `tv_series` table without a default value. This is not possible if the table is not empty.
  - Added the required column `contentId` to the `watchlist` table without a default value. This is not possible if the table is not empty.
  - Added the required column `contentType` to the `watchlist` table without a default value. This is not possible if the table is not empty.
  - Added the required column `updatedAt` to the `watchlist` table without a default value. This is not possible if the table is not empty.
  - Added the required column `userId` to the `watchlist` table without a default value. This is not possible if the table is not empty.

*/
-- DropForeignKey
ALTER TABLE `ratings` DROP FOREIGN KEY `ratings_ibfk_1`;

-- DropForeignKey
ALTER TABLE `seasons` DROP FOREIGN KEY `seasons_ibfk_1`;

-- DropForeignKey
ALTER TABLE `watchlist` DROP FOREIGN KEY `watchlist_ibfk_1`;

-- DropIndex
DROP INDEX `unique_user_media` ON `watchlist`;

-- AlterTable
ALTER TABLE `genres` MODIFY `name` VARCHAR(191) NOT NULL,
    MODIFY `type` VARCHAR(191) NOT NULL,
    MODIFY `created_at` DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3);

-- AlterTable
ALTER TABLE `movies` MODIFY `title` VARCHAR(191) NOT NULL,
    MODIFY `overview` VARCHAR(191) NULL,
    MODIFY `release_date` DATETIME(3) NULL,
    MODIFY `vote_average` DOUBLE NULL,
    MODIFY `poster_path` VARCHAR(191) NULL,
    MODIFY `backdrop_path` VARCHAR(191) NULL,
    MODIFY `genre_ids` VARCHAR(191) NULL,
    MODIFY `original_language` VARCHAR(191) NULL,
    MODIFY `created_at` DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
    MODIFY `updated_at` DATETIME(3) NULL,
    ALTER COLUMN `video` DROP DEFAULT,
    MODIFY `video_url` VARCHAR(191) NULL,
    MODIFY `trailer_url` VARCHAR(191) NULL;

-- AlterTable
ALTER TABLE `seasons` ADD COLUMN `episode_count` INTEGER NULL,
    MODIFY `name` VARCHAR(191) NULL,
    MODIFY `overview` VARCHAR(191) NULL,
    MODIFY `poster_path` VARCHAR(191) NULL,
    MODIFY `air_date` DATETIME(3) NULL,
    MODIFY `created_at` DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
    MODIFY `updated_at` DATETIME(3) NULL;

-- AlterTable
ALTER TABLE `tv_series` ADD COLUMN `name` VARCHAR(191) NULL,
    ADD COLUMN `number_of_episodes` INTEGER NULL,
    ADD COLUMN `number_of_seasons` INTEGER NULL,
    ADD COLUMN `seasons` VARCHAR(191) NULL,
    ADD COLUMN `status` VARCHAR(191) NULL,
    MODIFY `overview` VARCHAR(191) NULL,
    MODIFY `first_air_date` DATETIME(3) NULL,
    MODIFY `last_air_date` DATETIME(3) NULL,
    MODIFY `vote_average` DOUBLE NULL,
    MODIFY `poster_path` VARCHAR(191) NULL,
    MODIFY `backdrop_path` VARCHAR(191) NULL,
    MODIFY `genre_ids` VARCHAR(191) NULL,
    MODIFY `original_language` VARCHAR(191) NULL,
    MODIFY `created_at` DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
    MODIFY `updated_at` DATETIME(3) NULL,
    ALTER COLUMN `video` DROP DEFAULT,
    MODIFY `video_url` VARCHAR(191) NULL,
    MODIFY `trailer_url` VARCHAR(191) NULL;

-- Copy title data to name column
UPDATE `tv_series` SET `name` = `title` WHERE `name` IS NULL;

-- Drop the title column
ALTER TABLE `tv_series` DROP COLUMN `title`;

-- Make name column NOT NULL
ALTER TABLE `tv_series` MODIFY `name` VARCHAR(191) NOT NULL;

-- AlterTable
ALTER TABLE `watchlist` DROP COLUMN `created_at`,
    DROP COLUMN `media_id`,
    DROP COLUMN `media_type`,
    DROP COLUMN `poster_path`,
    DROP COLUMN `user_id`,
    ADD COLUMN `addedAt` DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
    ADD COLUMN `backdropPath` VARCHAR(191) NULL,
    ADD COLUMN `contentId` VARCHAR(191) NOT NULL,
    ADD COLUMN `contentType` VARCHAR(191) NOT NULL,
    ADD COLUMN `createdAt` DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
    ADD COLUMN `genreIds` VARCHAR(191) NULL,
    ADD COLUMN `notes` VARCHAR(191) NULL,
    ADD COLUMN `overview` VARCHAR(191) NULL,
    ADD COLUMN `posterPath` VARCHAR(191) NULL,
    ADD COLUMN `priority` VARCHAR(191) NOT NULL DEFAULT 'medium',
    ADD COLUMN `rating` INTEGER NULL,
    ADD COLUMN `releaseDate` DATETIME(3) NULL,
    ADD COLUMN `tags` VARCHAR(191) NULL,
    ADD COLUMN `updatedAt` DATETIME(3) NOT NULL,
    ADD COLUMN `userId` INTEGER NOT NULL,
    ADD COLUMN `voteAverage` DOUBLE NULL,
    ADD COLUMN `watched` BOOLEAN NOT NULL DEFAULT false,
    ADD COLUMN `watchedAt` DATETIME(3) NULL,
    MODIFY `title` VARCHAR(191) NOT NULL;

-- DropTable
DROP TABLE `ratings`;

-- DropTable
DROP TABLE `users`;

-- CreateTable
CREATE TABLE `rating` (
    `id` INTEGER NOT NULL AUTO_INCREMENT,
    `userId` INTEGER NOT NULL,
    `contentId` VARCHAR(191) NOT NULL,
    `contentType` VARCHAR(191) NOT NULL,
    `rating` INTEGER NOT NULL,
    `review` VARCHAR(191) NULL,
    `title` VARCHAR(191) NULL,
    `helpful` VARCHAR(191) NULL,
    `spoiler` BOOLEAN NOT NULL DEFAULT false,
    `tags` VARCHAR(191) NULL,
    `createdAt` DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
    `updatedAt` DATETIME(3) NOT NULL,

    INDEX `Rating_userId_fkey`(`userId`),
    PRIMARY KEY (`id`)
) DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- CreateTable
CREATE TABLE `user` (
    `id` INTEGER NOT NULL AUTO_INCREMENT,
    `email` VARCHAR(191) NOT NULL,
    `password` VARCHAR(191) NOT NULL,
    `username` VARCHAR(191) NOT NULL,
    `profileName` VARCHAR(191) NOT NULL,
    `profileAvatar` VARCHAR(191) NULL,
    `profileAge` INTEGER NULL,
    `profileLanguage` VARCHAR(191) NULL,
    `profileMaturity` VARCHAR(191) NULL,
    `preferencesGenres` VARCHAR(191) NULL,
    `preferencesTypes` VARCHAR(191) NULL,
    `preferencesLangs` VARCHAR(191) NULL,
    `preferencesSubtitles` BOOLEAN NOT NULL DEFAULT false,
    `subscriptionPlan` VARCHAR(191) NOT NULL DEFAULT 'basic',
    `subscriptionStatus` VARCHAR(191) NOT NULL DEFAULT 'active',
    `subscriptionStart` DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
    `subscriptionEnd` DATETIME(3) NULL,
    `watchHistory` VARCHAR(191) NULL,
    `isActive` BOOLEAN NOT NULL DEFAULT true,
    `lastLogin` DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
    `verificationToken` VARCHAR(191) NULL,
    `resetPasswordToken` VARCHAR(191) NULL,
    `resetPasswordExpires` DATETIME(3) NULL,
    `createdAt` DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
    `updatedAt` DATETIME(3) NOT NULL,

    UNIQUE INDEX `User_email_key`(`email`),
    UNIQUE INDEX `User_username_key`(`username`),
    PRIMARY KEY (`id`)
) DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- CreateIndex
CREATE INDEX `Watchlist_userId_fkey` ON `watchlist`(`userId`);

-- AddForeignKey
ALTER TABLE `rating` ADD CONSTRAINT `Rating_userId_fkey` FOREIGN KEY (`userId`) REFERENCES `user`(`id`) ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE `watchlist` ADD CONSTRAINT `Watchlist_userId_fkey` FOREIGN KEY (`userId`) REFERENCES `user`(`id`) ON DELETE CASCADE ON UPDATE CASCADE;
