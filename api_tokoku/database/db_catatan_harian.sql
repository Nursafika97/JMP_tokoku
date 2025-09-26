-- phpMyAdmin SQL Dump
-- version 5.2.0
-- https://www.phpmyadmin.net/
--
-- Host: localhost:3306
-- Generation Time: Sep 24, 2025 at 12:40 PM
-- Server version: 8.0.30
-- PHP Version: 8.3.20

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `db_catatan_harian`
--

-- --------------------------------------------------------

--
-- Table structure for table `catatan`
--

CREATE TABLE `catatan` (
  `id` int NOT NULL,
  `judul` varchar(255) NOT NULL,
  `isi_catatan` text,
  `latitude` decimal(10,8) NOT NULL,
  `longitude` decimal(11,8) NOT NULL,
  `waktu_dibuat` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `gambar` varchar(255) DEFAULT NULL,
  `alamat` text
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `catatan`
--

INSERT INTO `catatan` (`id`, `judul`, `isi_catatan`, `latitude`, `longitude`, `waktu_dibuat`, `gambar`, `alamat`) VALUES
(3, 'tes', 'kicak', '-6.20880000', '106.84560000', '2025-09-24 10:34:34', '1758710074_scaled_1000352287.jpg', NULL),
(4, 'wkwk', 'wowo', '-6.20880000', '106.84560000', '2025-09-24 10:56:18', '1758711378_scaled_1000313752.jpg', NULL),
(5, 'bajaia', 'iwiwua', '1.45888830', '102.14871330', '2025-09-24 11:52:14', '1758714734_scaled_1000330812.jpg', 'F45X+JFP, Sungai Alam, Kecamatan Bengkalis, Riau 28714'),
(6, 'mgjcjvj', 'cdyfhch', '1.45888830', '102.14871330', '2025-09-24 12:32:34', '1758717154_scaled_c245275a-2958-48c2-a1ac-f7edd72f95574468422083439938694.jpg', 'Sungai Alam, Kecamatan Bengkalis');

--
-- Indexes for dumped tables
--

--
-- Indexes for table `catatan`
--
ALTER TABLE `catatan`
  ADD PRIMARY KEY (`id`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `catatan`
--
ALTER TABLE `catatan`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=7;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
