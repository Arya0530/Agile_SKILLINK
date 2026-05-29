-- --------------------------------------------------------
-- Host:                         127.0.0.1
-- Server version:               8.4.3 - MySQL Community Server - GPL
-- Server OS:                    Win64
-- HeidiSQL Version:             12.8.0.6908
-- --------------------------------------------------------

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET NAMES utf8 */;
/*!50503 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

-- Dumping data for table db_skillink.applications: ~14 rows (approximately)
INSERT INTO `applications` (`id`, `user_id`, `post_id`, `status`, `created_at`, `updated_at`) VALUES
	(1, 2, 4, 'pending', '2026-05-04 23:51:10', '2026-05-04 23:51:10'),
	(2, 3, 4, 'pending', '2026-05-05 04:51:57', '2026-05-05 04:51:57'),
	(3, 3, 6, 'accepted', '2026-05-05 04:53:14', '2026-05-10 05:34:58'),
	(4, 3, 8, 'rejected', '2026-05-05 23:08:30', '2026-05-10 05:35:21'),
	(5, 2, 7, 'pending', '2026-05-13 08:25:28', '2026-05-13 08:25:28'),
	(6, 2, 3, 'pending', '2026-05-13 08:25:36', '2026-05-13 08:25:36'),
	(7, 2, 2, 'pending', '2026-05-13 08:27:34', '2026-05-13 08:27:34'),
	(8, 2, 1, 'pending', '2026-05-13 08:27:47', '2026-05-13 08:27:47'),
	(9, 7, 9, 'pending', '2026-05-15 11:28:35', '2026-05-15 11:28:35'),
	(10, 7, 10, 'pending', '2026-05-15 11:45:56', '2026-05-15 11:45:56'),
	(11, 7, 8, 'pending', '2026-05-15 11:48:16', '2026-05-15 11:48:16'),
	(12, 7, 7, 'pending', '2026-05-15 11:52:29', '2026-05-15 11:52:29'),
	(13, 2, 15, 'pending', '2026-05-16 05:57:35', '2026-05-16 05:57:35'),
	(14, 2, 14, 'pending', '2026-05-17 02:43:32', '2026-05-17 02:43:32');

-- Dumping data for table db_skillink.cache: ~0 rows (approximately)

-- Dumping data for table db_skillink.cache_locks: ~0 rows (approximately)

-- Dumping data for table db_skillink.failed_jobs: ~0 rows (approximately)

-- Dumping data for table db_skillink.jobs: ~0 rows (approximately)

-- Dumping data for table db_skillink.job_batches: ~0 rows (approximately)

-- Dumping data for table db_skillink.migrations: ~12 rows (approximately)
INSERT INTO `migrations` (`id`, `migration`, `batch`) VALUES
	(1, '0001_01_01_000000_create_users_table', 1),
	(2, '0001_01_01_000001_create_cache_table', 1),
	(3, '0001_01_01_000002_create_jobs_table', 1),
	(4, '2026_03_08_071047_create_personal_access_tokens_table', 1),
	(5, '2026_03_08_071330_create_posts_table', 1),
	(6, '2026_03_20_230423_create_projects_table', 1),
	(7, '2026_03_20_230746_create_skills_table', 1),
	(8, '2026_03_21_204430_create_applications_table', 1),
	(9, '2026_05_08_000001_add_member_quota_to_posts_table', 2),
	(10, '2026_05_09_000001_add_status_columns_to_posts_table', 2),
	(11, '2026_05_09_000002_create_project_histories_table', 2),
	(12, '2026_05_12_000000_normalize_jurusan', 3);

-- Dumping data for table db_skillink.password_reset_tokens: ~1 rows (approximately)
INSERT INTO `password_reset_tokens` (`email`, `token`, `created_at`) VALUES
	('aryanugraha4305@gmail.com', '$2y$12$SR87vGi6Ntv2i079MyCro.UVR6mONdoDmCy2xelFQszbHCEkeCFBe', '2026-05-10 05:45:43');

-- Dumping data for table db_skillink.personal_access_tokens: ~43 rows (approximately)
INSERT INTO `personal_access_tokens` (`id`, `tokenable_type`, `tokenable_id`, `name`, `token`, `abilities`, `last_used_at`, `expires_at`, `created_at`, `updated_at`) VALUES
	(1, 'App\\Models\\User', 1, 'auth_token', '6fef520f675253f25f2f192e083f6b62b1838d98a5a62045704d9b5e76233c6c', '["*"]', '2026-05-04 23:49:32', NULL, '2026-05-04 23:48:41', '2026-05-04 23:49:32'),
	(2, 'App\\Models\\User', 2, 'auth_token', '8316477ea25a653224ec254e0cc79191840ebca02eb880d6db0632144a7f6bc0', '["*"]', NULL, NULL, '2026-05-04 23:50:49', '2026-05-04 23:50:49'),
	(3, 'App\\Models\\User', 2, 'auth_token', '61ba120a110539140f78f043de2841efe4c6cab902713a5a58101ead68b0b052', '["*"]', '2026-05-04 23:51:13', NULL, '2026-05-04 23:50:59', '2026-05-04 23:51:13'),
	(4, 'App\\Models\\User', 1, 'auth_token', '8c188dbbed228e7d84a06a9b84766c068b5835ecac7070d9ecfebc6c598eccf7', '["*"]', '2026-05-05 01:32:55', NULL, '2026-05-04 23:51:24', '2026-05-05 01:32:55'),
	(5, 'App\\Models\\User', 1, 'auth_token', '6015ff5d4262aaef980bc2708ce968b5136c3574d22f41a933facc9e6d670f89', '["*"]', '2026-05-05 01:49:18', NULL, '2026-05-05 01:34:54', '2026-05-05 01:49:18'),
	(6, 'App\\Models\\User', 1, 'auth_token', '87e9c613c507431f8ee3db5f4392028da94223381a52b9226187ba0aab351593', '["*"]', '2026-05-05 02:15:32', NULL, '2026-05-05 01:51:45', '2026-05-05 02:15:32'),
	(7, 'App\\Models\\User', 1, 'auth_token', '3094da017399b83c732bdd2a4df88976559c4c0bcbfab19f4850015a1dac30c8', '["*"]', '2026-05-05 02:19:58', NULL, '2026-05-05 02:16:54', '2026-05-05 02:19:58'),
	(8, 'App\\Models\\User', 1, 'auth_token', '68bab12cb1b26f7ea0a8f0526cfc939d6f0a4176aac008ae789bdb3d3f73f41c', '["*"]', '2026-05-05 02:36:44', NULL, '2026-05-05 02:20:49', '2026-05-05 02:36:44'),
	(9, 'App\\Models\\User', 1, 'auth_token', '99675ad019bde9516c95abdcbaa5ffdf50a033a76373aea2333ae52036195693', '["*"]', '2026-05-05 03:19:29', NULL, '2026-05-05 02:38:31', '2026-05-05 03:19:29'),
	(10, 'App\\Models\\User', 1, 'auth_token', '90c4432a3f85309364ddf712a206c60dd84a51c6b53f28ab6e88b2646d8939e2', '["*"]', '2026-05-05 03:28:59', NULL, '2026-05-05 03:26:45', '2026-05-05 03:28:59'),
	(11, 'App\\Models\\User', 1, 'auth_token', 'ac15925917224e0214ebf99aab0eea112bc7eb4b25f346e497d2baed937f8a2d', '["*"]', '2026-05-05 03:43:00', NULL, '2026-05-05 03:42:31', '2026-05-05 03:43:00'),
	(12, 'App\\Models\\User', 2, 'auth_token', '4c7381a961dd133fdd2fa6fd823cc86dec2cf5a1572fc4f2554e1a31acacb7cb', '["*"]', '2026-05-05 03:50:55', NULL, '2026-05-05 03:46:26', '2026-05-05 03:50:55'),
	(13, 'App\\Models\\User', 2, 'auth_token', 'e63b87112fea011a57888027ef0638c9d28da202e5a135853f3456626ce28150', '["*"]', '2026-05-05 03:54:10', NULL, '2026-05-05 03:51:50', '2026-05-05 03:54:10'),
	(14, 'App\\Models\\User', 2, 'auth_token', '22a8b7ad9ae376c1b56d6545a323c262eadf53e72af83cec4143a4fd2cf38bb0', '["*"]', '2026-05-05 04:13:21', NULL, '2026-05-05 03:58:33', '2026-05-05 04:13:21'),
	(15, 'App\\Models\\User', 2, 'auth_token', 'fe153f32bbde77aa75b96c6a5c138a9405fb22c2ca02f151d8941e37264557f5', '["*"]', '2026-05-05 04:21:24', NULL, '2026-05-05 04:14:17', '2026-05-05 04:21:24'),
	(16, 'App\\Models\\User', 2, 'auth_token', '6f1e81e4fcf77821adac210a1346f86c0c64921607ff33b1f898f5e1c21c9ec1', '["*"]', '2026-05-05 04:42:50', NULL, '2026-05-05 04:22:32', '2026-05-05 04:42:50'),
	(17, 'App\\Models\\User', 2, 'auth_token', '408e582f434b2ece4c75307ec12bb0e90c119ad4352fa3996f7850ab5e68a07c', '["*"]', '2026-05-05 04:50:01', NULL, '2026-05-05 04:45:10', '2026-05-05 04:50:01'),
	(18, 'App\\Models\\User', 3, 'auth_token', 'd5547a56f11febdad1e9dd0ebcaadf7c52c21d6d5b77d7580c6f4dab2590d305', '["*"]', NULL, NULL, '2026-05-05 04:51:41', '2026-05-05 04:51:41'),
	(19, 'App\\Models\\User', 3, 'auth_token', 'c234c23906e23b07bbe6dbc1ce77242ccec82e7235df6e41af40c982ad486327', '["*"]', '2026-05-05 04:52:09', NULL, '2026-05-05 04:51:51', '2026-05-05 04:52:09'),
	(20, 'App\\Models\\User', 2, 'auth_token', '084799bf70ffa0c90a9481da9883fd621be08d13839f9f4d7a2c0bf0a5621598', '["*"]', '2026-05-05 04:52:49', NULL, '2026-05-05 04:52:21', '2026-05-05 04:52:49'),
	(21, 'App\\Models\\User', 3, 'auth_token', '257126db2410686dd5585add0322ce21ed0ab408d97d85398d10d86670289e83', '["*"]', '2026-05-05 04:53:19', NULL, '2026-05-05 04:53:08', '2026-05-05 04:53:19'),
	(22, 'App\\Models\\User', 2, 'auth_token', '3ceef576fcf50b812bbdf89ff02c5ef117b4daf329f4a0becb27d6586facf7f4', '["*"]', '2026-05-05 04:53:39', NULL, '2026-05-05 04:53:33', '2026-05-05 04:53:39'),
	(23, 'App\\Models\\User', 2, 'auth_token', '41c8c3d9c5619e6b2d593d959735f9ad5410807efa6119fab7265d98c734941a', '["*"]', '2026-05-05 04:55:12', NULL, '2026-05-05 04:54:41', '2026-05-05 04:55:12'),
	(24, 'App\\Models\\User', 2, 'auth_token', '42f27cde98b394e87724f476eebdc5fc59a76553c6c873262217f92fdd8c2132', '["*"]', '2026-05-05 04:56:44', NULL, '2026-05-05 04:56:31', '2026-05-05 04:56:44'),
	(25, 'App\\Models\\User', 2, 'auth_token', '175e685a3b669960cd707a4e49112a07916a72df2f3ed32045ea262792701259', '["*"]', '2026-05-05 23:07:34', NULL, '2026-05-05 23:05:51', '2026-05-05 23:07:34'),
	(26, 'App\\Models\\User', 3, 'auth_token', '19c17dab3292dc2da268af9415b8e46fe4ea9172c3071fcf44ffa5f4ca90af2f', '["*"]', '2026-05-05 23:08:30', NULL, '2026-05-05 23:08:22', '2026-05-05 23:08:30'),
	(27, 'App\\Models\\User', 4, 'auth_token', 'ec53698755e207a79bc9d255352a7624da0abe65383962ae01f0f92779ac3486', '["*"]', NULL, NULL, '2026-05-06 01:44:03', '2026-05-06 01:44:03'),
	(28, 'App\\Models\\User', 5, 'auth_token', 'b65fd9e6155b137f7d3f05114e5cb23e76907511885cf530a2346357cf1ba1bb', '["*"]', NULL, NULL, '2026-05-06 02:44:09', '2026-05-06 02:44:09'),
	(29, 'App\\Models\\User', 5, 'auth_token', 'db9eaf8439eeb0f58971eb9422e05fb293e6a6299763d9901cb55d9b7be08bb2', '["*"]', '2026-05-06 02:44:55', NULL, '2026-05-06 02:44:14', '2026-05-06 02:44:55'),
	(30, 'App\\Models\\User', 5, 'auth_token', '79268f8ec5ecc43b43924fbb39b690ed39a74dae350390e9de30a0171e6229cc', '["*"]', '2026-05-06 02:45:39', NULL, '2026-05-06 02:45:37', '2026-05-06 02:45:39'),
	(31, 'App\\Models\\User', 6, 'auth_token', 'a719c7664a277e35c133359ee5fd96045624718958d02f0d08bd1314a399cdcf', '["*"]', NULL, NULL, '2026-05-07 09:32:30', '2026-05-07 09:32:30'),
	(32, 'App\\Models\\User', 6, 'auth_token', '0f61c1d642e3f0187bde0c530cea9dcca0de1f2ca0d6672ef97e2d482a2ccaba', '["*"]', '2026-05-07 09:32:57', NULL, '2026-05-07 09:32:43', '2026-05-07 09:32:57'),
	(33, 'App\\Models\\User', 4, 'auth_token', 'fc7473d2d1e1c9df98a64bb89698d47d345f71683c00d2b185fdde2c3ea0dbc4', '["*"]', '2026-05-07 10:14:44', NULL, '2026-05-07 10:14:41', '2026-05-07 10:14:44'),
	(34, 'App\\Models\\User', 2, 'auth_token', '61914ec7a79b36f66ff6a5257a8d2373cc1e7225bbe589c4fea21c0588048e0f', '["*"]', '2026-05-10 05:36:40', NULL, '2026-05-10 05:34:10', '2026-05-10 05:36:40'),
	(35, 'App\\Models\\User', 2, 'auth_token', '73b140366312c949a1856716736dd449a677f48229e8d0b1cde665e63cb2d2b6', '["*"]', '2026-05-13 08:19:00', NULL, '2026-05-13 08:15:25', '2026-05-13 08:19:00'),
	(36, 'App\\Models\\User', 2, 'auth_token', 'fe28c038f30ba94cb853068a0c404d8b57eaee3629e1798a87908d03761ec4d1', '["*"]', '2026-05-13 08:27:48', NULL, '2026-05-13 08:19:12', '2026-05-13 08:27:48'),
	(37, 'App\\Models\\User', 7, 'auth_token', '962e50aa6d0285381d529380722629d0eb088d85f04e56c4e476b8ffce3a1ba9', '["*"]', NULL, NULL, '2026-05-15 11:28:09', '2026-05-15 11:28:09'),
	(38, 'App\\Models\\User', 7, 'auth_token', 'cb4747752e8cbe975a46a8c02a70a5299373cb756f1aca5f012f0e973554ed1b', '["*"]', '2026-05-15 11:41:15', NULL, '2026-05-15 11:28:14', '2026-05-15 11:41:15'),
	(39, 'App\\Models\\User', 7, 'auth_token', 'b962a4275a2fb77326c168d53cc121c90160227ac8969dc340c8384740b829ae', '["*"]', '2026-05-15 11:50:36', NULL, '2026-05-15 11:42:48', '2026-05-15 11:50:36'),
	(40, 'App\\Models\\User', 7, 'auth_token', '04e3870724e74e1db6291e035e0cef35549f97a04cbc35fe1ba8b494f7af6223', '["*"]', '2026-05-15 11:55:03', NULL, '2026-05-15 11:50:50', '2026-05-15 11:55:03'),
	(41, 'App\\Models\\User', 2, 'auth_token', '4071e759358af8c5a030015e0bbda9688a0c241314b854f20676483d1cf663b6', '["*"]', '2026-05-16 06:00:15', NULL, '2026-05-16 05:56:25', '2026-05-16 06:00:15'),
	(42, 'App\\Models\\User', 2, 'auth_token', '63ed133559727ea75ea85735965139c9c2f044cca6fa4516eed60b8590f369b3', '["*"]', '2026-05-17 02:43:56', NULL, '2026-05-17 02:43:09', '2026-05-17 02:43:56'),
	(43, 'App\\Models\\User', 2, 'auth_token', '7d807bb564f557c96471f12b789f75955dcf5a706510fc1ec9de83a840b56bb0', '["*"]', '2026-05-17 05:29:43', NULL, '2026-05-17 05:29:34', '2026-05-17 05:29:43');

-- Dumping data for table db_skillink.posts: ~16 rows (approximately)
INSERT INTO `posts` (`id`, `user_id`, `author_name`, `author_major`, `post_type`, `content`, `tags`, `is_apply`, `is_closed`, `is_completed`, `completed_at`, `is_boosted`, `max_anggota`, `accepted_count`, `created_at`, `updated_at`) VALUES
	(1, 1, 'Arya', 'D3 Teknik Informatika', 'Kolaborasi Proyek', 'tertergsdg', 'gsdfgfdsg', 1, 0, 0, NULL, 0, 0, 0, '2026-05-04 23:48:55', '2026-05-04 23:48:55'),
	(2, 1, 'Arya', 'D3 Teknik Informatika', 'Kolaborasi Proyek', 'tertergsdg', 'gsdfgfdsg', 1, 0, 0, NULL, 0, 0, 0, '2026-05-04 23:48:56', '2026-05-04 23:48:56'),
	(3, 1, 'Arya', 'D3 Teknik Informatika', 'Kolaborasi Proyek', 'dfgfg', 'dgf', 1, 0, 0, NULL, 0, 0, 0, '2026-05-04 23:49:03', '2026-05-04 23:49:03'),
	(4, 1, 'Arya', 'D3 Teknik Informatika', 'Kolaborasi Proyek', 'Brownies kukus coklat yang lembut dan lembap (moist) dapat dibuat dengan melelehkan cokelat batangan (100-150g) dan mentega/minyak (100-120g), lalu kocok 4 telur, 150g gula, dan 1 sdt SP hingga kental. Campur tepung terigu (80-100g) dan cokelat bubuk (35-40g), aduk rata dengan adonan telur, masukkan cokelat leleh, dan kukus 30-40 menit.Berikut adalah resep brownies kukus lembut beserta langkah-langkahnya:Bahan-bahanBahan A (Lelehkan):100-150 gr Dark Cooking Chocolate (DCC), potong-potong120 gr Mentega/Butter atau Minyak GorengBahan B (Kocok):4 butir Telur150 gr Gula Pasir1 sdt SP/Ovalet/TBM1/2 sdt Vanili bubuk (opsional)Bahan C (Ayak):80-100 gr Tepung Terigu Protein Sedang35-40 gr Cokelat Bubuk1/2 sdt Baking PowderLangkah-langkah PembuatanPersiapan: Panaskan kukusan dengan api sedang. Olesi loyang (ukuran 18x18 cm atau 20x10 cm) dengan margarin dan alasi kertas roti (baking paper).Melelehkan Cokelat: Lelehkan Bahan A (DCC dan mentega/minyak) dengan cara ditim. Jangan sampai air mendidih masuk ke cokelat. Setelah leleh, sisihkan dan biarkan agak dingin.Mengocok Telur: Kocok Bahan B (telur, gula, SP, dan vanili) dengan mixer kecepatan tinggi hingga adonan mengembang, kental, putih, dan berjejak (kurang lebih 7-10 menit).Mencampur Bahan Kering: Turunkan kecepatan mixer ke paling rendah, masukkan Bahan C (terigu, cokelat bubuk, baking powder) yang sudah diayak secara bertahap. Aduk rata sebentar saja.Memasukkan Cokelat Leleh: Tuang Bahan A (cokelat leleh) ke dalam adonan. Gunakan spatula dengan teknik aduk balik (aduk dari bawah ke atas) hingga benar-benar tercampur rata. Pastikan tidak ada cairan cokelat yang mengendap di dasar wadah agar tidak bantat.Mengukus: Tuang adonan ke dalam loyang, hentakkan pelan agar udara keluar. Kukus selama 30-40 menit dengan api sedang.Pengecekan: Tes tusuk dengan lidi. Jika tidak ada adonan yang menempel, berarti brownies sudah matang.Penyelesaian: Angkat, biarkan dingin sebentar, lalu keluarkan dari loyang. Brownies siap disajikan.Tips Agar Tidak BantatBungkus tutup kukusan dengan kain bersih agar uap air tidak menetes ke brownies.Pastikan lelehan cokelat sudah tidak panas saat dicampur ke adonan telur.Gunakan api sedang agar adonan matang merata dan tidak meletup-letup.Jangan membuka tutup kukusan terlalu sering sebelum 20 menit pertama.', 'fsfdsfsf', 1, 0, 0, NULL, 0, 0, 0, '2026-05-04 23:49:32', '2026-05-04 23:49:32'),
	(5, 2, 'bbb', 'D3 Teknologi Multimedia Broadcasting (MMB)', 'Kolaborasi Proyek', 'kabahab', 'janababab', 1, 0, 0, NULL, 0, 0, 0, '2026-05-05 04:52:48', '2026-05-05 04:52:48'),
	(6, 2, 'bbb', 'D3 Teknologi Multimedia Broadcasting (MMB)', 'Kolaborasi Proyek', 'kabahab', 'janababab', 1, 0, 0, NULL, 0, 0, 1, '2026-05-05 04:52:49', '2026-05-10 05:34:58'),
	(7, 3, 'caca', 'D3 Teknologi Multimedia Broadcasting (MMB)', 'Kolaborasi Proyek', 'jsjsn', 'jensn', 1, 0, 0, NULL, 0, 0, 0, '2026-05-05 04:53:19', '2026-05-05 04:53:19'),
	(8, 2, 'bbb', 'D3 Teknologi Multimedia Broadcasting (MMB)', 'Kolaborasi Proyek', 'werewrew', 'wifhe', 1, 0, 0, NULL, 0, 0, 0, '2026-05-05 23:06:21', '2026-05-05 23:06:21'),
	(9, 2, 'bbb', 'D3 Teknologi Multimedia Broadcasting (MMB)', 'Kolaborasi Proyek', '9t87t', 'igi', 1, 0, 0, NULL, 0, 5, 0, '2026-05-10 05:35:53', '2026-05-10 05:35:53'),
	(10, 2, 'bbb', 'D3 Teknologi Multimedia Broadcasting (MMB)', 'Kolaborasi Proyek', '9t87t', 'igi', 1, 0, 0, NULL, 0, 5, 0, '2026-05-10 05:35:54', '2026-05-10 05:35:54'),
	(11, 2, 'bbb', 'D3 Teknologi Multimedia Broadcasting (MMB)', 'Kolaborasi Proyek', 'ghnghnh', 'grt', 0, 1, 1, '2026-05-10 05:36:32', 0, 5, 0, '2026-05-10 05:36:19', '2026-05-10 05:36:32'),
	(12, 7, 'axe', 'D3 Teknik Informatika', 'Kolaborasi Proyek', 'werew', 'dhfgh', 1, 0, 0, NULL, 0, 3, 0, '2026-05-15 11:29:04', '2026-05-15 11:29:04'),
	(13, 7, 'axe', 'D3 Teknik Informatika', 'Kolaborasi Proyek', 'werew', 'dhfgh', 1, 0, 0, NULL, 0, 3, 0, '2026-05-15 11:29:05', '2026-05-15 11:29:05'),
	(14, 7, 'axe', 'D3 Teknik Informatika', 'Kolaborasi Proyek', 'dfgfg', 'fgfd', 1, 0, 0, NULL, 0, 2343, 0, '2026-05-15 11:44:23', '2026-05-15 11:44:23'),
	(15, 7, 'axe', 'D3 Teknik Informatika', 'Kolaborasi Proyek', 'gdfgdf', 'fdfgd', 1, 0, 0, NULL, 0, 3, 0, '2026-05-15 11:49:08', '2026-05-15 11:49:08'),
	(16, 2, 'bbb', 'D3 Teknik Informatika', 'Kolaborasi Proyek', 'fdgfdg', '#gdfg', 1, 0, 0, NULL, 0, 3, 0, '2026-05-16 05:57:09', '2026-05-16 05:57:09');

-- Dumping data for table db_skillink.projects: ~2 rows (approximately)
INSERT INTO `projects` (`id`, `user_id`, `title`, `role`, `description`, `created_at`, `updated_at`) VALUES
	(2, 2, 'kensbb', 'kansbb', 'kansbbb', '2026-05-05 04:26:12', '2026-05-05 04:26:12'),
	(3, 2, 'wjbasbn', 'jwbwn', 'jansn', '2026-05-05 04:31:33', '2026-05-05 04:31:33');

-- Dumping data for table db_skillink.project_histories: ~1 rows (approximately)
INSERT INTO `project_histories` (`id`, `user_id`, `post_id`, `project_title`, `leader_name`, `start_date`, `end_date`, `created_at`, `updated_at`) VALUES
	(1, 2, 11, 'ghnghnh', 'bbb', '2026-05-10', '2026-05-10', '2026-05-10 05:36:32', '2026-05-10 05:36:32');

-- Dumping data for table db_skillink.sessions: ~0 rows (approximately)

-- Dumping data for table db_skillink.skills: ~6 rows (approximately)
INSERT INTO `skills` (`id`, `user_id`, `name`, `created_at`, `updated_at`) VALUES
	(9, 3, 'jajana sjsbann', '2026-05-05 04:52:07', '2026-05-05 04:52:07'),
	(11, 2, 'kaka janab', '2026-05-05 04:55:11', '2026-05-05 04:55:11'),
	(12, 2, 'kana', '2026-05-05 04:56:42', '2026-05-05 04:56:42'),
	(13, 2, 'janan', '2026-05-05 04:56:43', '2026-05-05 04:56:43'),
	(14, 2, 'fgfd', '2026-05-16 05:59:49', '2026-05-16 05:59:49'),
	(15, 2, 'dfgdfg', '2026-05-16 05:59:50', '2026-05-16 05:59:50');

-- Dumping data for table db_skillink.users: ~7 rows (approximately)
INSERT INTO `users` (`id`, `name`, `email`, `email_verified_at`, `password`, `jurusan`, `no_wa`, `remember_token`, `created_at`, `updated_at`) VALUES
	(1, 'Arya', 'a@gmail.com', NULL, '$2y$12$s3P99Eg/DVBcJkz8hNSYSu1ktw9U0AyGIHcPeNDi/zSNfPuQG.sjC', NULL, NULL, NULL, '2026-05-04 23:48:22', '2026-05-04 23:48:22'),
	(2, 'bbb', 'k@gmail.com', NULL, '$2y$12$CBQh5HW0SvxmqzEXBXIrYu1RRnIdMv7iHwReSMMk2cuMU59NrSEDC', 'D3 Teknik Informatika', '073423423432', NULL, '2026-05-04 23:50:49', '2026-05-16 05:58:26'),
	(3, 'caca', 'c@gmail.com', NULL, '$2y$12$yVJFTzG7FGeCgxNfDobSyOJdmpAZg2xYUj0kEpsYdJm.7NkOycOfe', 'D3 Teknologi Multimedia Broadcasting (MMB)', '081230813044', NULL, '2026-05-05 04:51:40', '2026-05-05 04:51:40'),
	(4, 'nugraha', 'aryanugraha4305@gmail.com', NULL, '$2y$12$k/DapP0yl9wduWGMDyhOouPQSCRNESmIOz/1zUSON.9QeP1IUQ9ke', 'D3 Teknologi Multimedia Broadcasting (MMB)', '081230813044', NULL, '2026-05-06 01:44:03', '2026-05-06 01:44:03'),
	(5, 'nugraha', 'nugraha@gmail.com', NULL, '$2y$12$5Q5zhdrgvHTRP6iARx/ke.pWD3.ngWHijIDmt3sgetb8W.QWaIe7.', 'D3 Teknologi Multimedia Broadcasting (MMB)', '081230813044', NULL, '2026-05-06 02:44:09', '2026-05-06 02:44:09'),
	(6, 'zuhri', 'zuhri@gmail.com', NULL, '$2y$12$8y.jgFgI26bUeiwa5ZXEreRGwSnrLH7slfDPbjmWkh.cKnRFWo6yS', 'D3 Teknologi Multimedia Broadcasting (MMB)', '08342341', NULL, '2026-05-07 09:32:29', '2026-05-07 09:32:29'),
	(7, 'axe', 'x@gmail.com', NULL, '$2y$12$CdwBtTQ.fwFTDD6.Tt5PV.JJrLYijJ7ydLVgrU.KrEJeVtool.yG2', 'D3 Teknik Informatika', '081230813044', NULL, '2026-05-15 11:28:09', '2026-05-15 11:51:10');

/*!40103 SET TIME_ZONE=IFNULL(@OLD_TIME_ZONE, 'system') */;
/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IFNULL(@OLD_FOREIGN_KEY_CHECKS, 1) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40111 SET SQL_NOTES=IFNULL(@OLD_SQL_NOTES, 1) */;
