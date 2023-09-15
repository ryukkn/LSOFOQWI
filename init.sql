-- phpMyAdmin SQL Dump
-- version 5.2.0
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Generation Time: Jun 05, 2023 at 02:00 PM
-- Server version: 10.4.27-MariaDB
-- PHP Version: 8.2.0

DROP DATABASE comlabmanagement;

CREATE DATABASE comlabmanagement;

USE comlabmanagement;

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";

--
-- Table Creation
--
CREATE TABLE `schedules` (  
  `ID` int(15) NOT NULL,
  `LabID` int(15)  NOT NULL,
  `CourseID` int(15) NOT NULL,
  `schedule` varchar(255) NOT NULL,
  PRIMARY KEY (`ID`)
);

CREATE TABLE `students` (
  `ID` varchar(15) NOT NULL,
  `email` varchar(255) NOT NULL,
  `password` varchar(255) NOT NULL,
  `contact` int(11) NOT NULL,
  `schedule` int(15) DEFAULT NULL,
  `fullname` varchar(255)  NOT NULL,
  `year` varchar(20)  DEFAULT NULL,
  `block` varchar(20)  DEFAULT NULL,
  `QR` varchar(255) DEFAULT NULL,
  `status` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`ID`),
  FOREIGN KEY (`schedule`) REFERENCES `schedules`(`ID`)
);

CREATE TABLE `faculty` (
  `ID` varchar(15) NOT NULL,
  `email` varchar(255) NOT NULL,
  `password` varchar(255) NOT NULL,
  `schedule` int(15) DEFAULT NULL,
  `fullname` varchar(255)  NOT NULL,
  `department` varchar(255) DEFAULT NULL,
  `contact` int(11) DEFAULT NULL,
  `status` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`ID`),
  FOREIGN KEY (`schedule`) REFERENCES `schedules`(`ID`)
);

CREATE TABLE `admin` (
  `ID` varchar(15) NOT NULL,
  `fullname` varchar(255)  NOT NULL,
  `email` varchar(255) NOT NULL,
  `contact` int(11) NOT NULL,
  `password` varchar(255) NOT NULL,
  PRIMARY KEY (`ID`)
);


CREATE TABLE `student_notifications` (
  `ID` int(15) NOT NULL,
  `StudentID` varchar(15)  NOT NULL,
  `Type` varchar(15) DEFAULT "Message",
  `Message` varchar(255) DEFAULT NULL,
  FOREIGN KEY (`StudentID`) REFERENCES `students` (`ID`),
  PRIMARY KEY (`ID`)
);

CREATE TABLE `faculty_notifications` (
  `ID` int(15) NOT NULL,
  `FacultyID` varchar(15)  NOT NULL,
  `Type` varchar(15) DEFAULT "Message",
  `Message` varchar(255) DEFAULT NULL,
  FOREIGN KEY (`FacultyID`) REFERENCES `faculty` (`ID`),
  PRIMARY KEY (`ID`)
);

CREATE TABLE `laboratories` (
  `ID` varchar(15) NOT NULL,
  `Room` varchar(255)  NOT NULL,
  `Building` varchar(255) NOT NULL,
  `units` int(15) DEFAULT 0,
  PRIMARY KEY (`ID`)
);

CREATE TABLE `devices` (
  `ID` varchar(15) NOT NULL,
  `Name` varchar(255)  DEFAULT "PC",
  `LabID` varchar(15) NOT NULL,
  `QR` varchar(255) DEFAULT NULL,
  FOREIGN KEY (`LabID`) REFERENCES `laboratories` (`ID`) ON DELETE CASCADE,
  PRIMARY KEY (`ID`)
);

CREATE TABLE `courses` (
  `ID` varchar(15) NOT NULL,
  `Course` varchar(15)  NOT NULL,
  PRIMARY KEY (`ID`)
);

CREATE TABLE `sessions` (
  `ID` int(15) NOT NULL,
  `Date` date NOT NULL,
  `StudentID` varchar(15) NOT NULL,
  `FacultyID` varchar(15) NOT NULL,
  `DeviceID` varchar(15) NOT NULL,
  `LaboratoryID` varchar(15) NOT NULL,
  `SystemUnit`varchar(10)  DEFAULT "F"  ,
  `Monitor`varchar(10)  DEFAULT "F",
  `Mouse`varchar(10)  DEFAULT "F",
  `Keyboard`varchar(10)  DEFAULT "F",
  `AVRUPS`varchar(10)  DEFAULT "F",
  `WIFIDONGLE`varchar(10)  DEFAULT "F",
  `Remarks`varchar(255)  DEFAULT "F",
  PRIMARY KEY(`ID`),
  FOREIGN KEY (`StudentID`) REFERENCES `students` (`ID`) ON DELETE CASCADE,
  FOREIGN KEY (`DeviceID`) REFERENCES `devices` (`ID`) ON DELETE CASCADE,
  FOREIGN KEY (`FacultyID`) REFERENCES `faculty` (`ID`) ON DELETE CASCADE,
  FOREIGN KEY (`LaboratoryID`) REFERENCES `laboratories` (`ID`) ON DELETE CASCADE
);

COMMIT;
