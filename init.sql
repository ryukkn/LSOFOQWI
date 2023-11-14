-- phpMyAdmin SQL Dump
-- version 5.2.0
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Generation Time: Jun 05, 2023 at 02:00 PM
-- Server version: 10.4.27-MariaDB
-- PHP Version: 8.2.0

-- DROP DATABASE comlabmanagement;

-- CREATE DATABASE comlabmanagement;

-- USE comlabmanagement;

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";

--
-- Table Creation
--



CREATE TABLE `courses` (
  `ID` int NOT NULL AUTO_INCREMENT,
  `course` varchar(50)  NOT NULL,
  PRIMARY KEY (`ID`)
);
CREATE TABLE `levels` (
  `ID` int NOT NULL AUTO_INCREMENT,
  `CourseID` int NOT NULL,
  `level` varchar(50)  NOT NULL,
  FOREIGN KEY (`CourseID`) REFERENCES `courses`(`ID`) ON DELETE CASCADE, 
  PRIMARY KEY (`ID`)
);
CREATE TABLE `blocks` (
  `ID` int NOT NULL AUTO_INCREMENT,
  `LevelID` int NOT NULL,
  `block` varchar(50)  NOT NULL,
   FOREIGN KEY (`LevelID`) REFERENCES `levels`(`ID`) ON DELETE CASCADE, 
  PRIMARY KEY (`ID`)
);


CREATE TABLE `faculty` (
  `ID` varchar(15) NOT NULL,
  `email` varchar(255) NOT NULL,
  `password` varchar(255) NOT NULL,
  `fullname` varchar(255)  NOT NULL,
  `department` varchar(255) DEFAULT "Computer Studies Department",
  `contact` varchar(11) DEFAULT NULL,
  `profile` varchar(255) DEFAULT NULL,
  `status` varchar(255) DEFAULT NULL,
  `devicetoken` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`ID`)
);

CREATE TABLE `students` (
  `ID` varchar(15) NOT NULL,
  `email` varchar(255) NOT NULL,
  `password` varchar(255) NOT NULL,
  `contact` varchar(11) NOT NULL,
  `fullname` varchar(255)  NOT NULL,
  `year` varchar(20)  DEFAULT NULL,
  `BlockID` int  DEFAULT NULL,
  `QR` varchar(255) DEFAULT NULL,
  `status` varchar(255) DEFAULT NULL,
  `profile` varchar(255) DEFAULT NULL,
  `devicetoken` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`ID`),
  FOREIGN KEY (`BlockID`) REFERENCES `blocks`(`ID`) ON DELETE CASCADE
);

CREATE TABLE `laboratories` (
  `ID` varchar(15) NOT NULL,
  `laboratory` varchar(255)  NOT NULL,
  `department` varchar(255) NOT NULL,
  PRIMARY KEY (`ID`)
);

CREATE TABLE `assigned_class` (
  `ID` int NOT NULL AUTO_INCREMENT,
  `BlockID` int(15) NOT NULL,
  `FacultyID` varchar(15)  NOT NULL,
  PRIMARY KEY (`ID`),
  FOREIGN KEY (`FacultyID`) REFERENCES `faculty`(`ID`) ON DELETE CASCADE, 
  FOREIGN KEY (`BlockID`) REFERENCES `blocks`(`ID`) ON DELETE CASCADE
);

CREATE TABLE `faculty_schedules` (  
  `ID` int NOT NULL AUTO_INCREMENT,
  `FacultyID` varchar(15)  NOT NULL,
  `LabID` varchar(15)  NOT NULL,
  `BlockID` int(15) NOT NULL,
  `day` varchar(10) NOT NULL,
  `time` varchar(50) NOT NULL,
  PRIMARY KEY (`ID`),
  FOREIGN KEY (`LabID`) REFERENCES `laboratories`(`ID`) ON DELETE CASCADE,
  FOREIGN KEY (`FacultyID`) REFERENCES `faculty`(`ID`) ON DELETE CASCADE,
  FOREIGN KEY (`BlockID`) REFERENCES `blocks`(`ID`) ON DELETE CASCADE
);

CREATE TABLE `student_schedules` (  
  `ID` int NOT NULL AUTO_INCREMENT,
  `StudentID` varchar(15)  NOT NULL,
  `LabID` varchar(15)  NOT NULL,
  `BlockID` int(15) NOT NULL,
  `day` varchar(10) NOT NULL,
  `time` varchar(50) NOT NULL,
  PRIMARY KEY (`ID`),
  FOREIGN KEY (`LabID`) REFERENCES `laboratories`(`ID`) ON DELETE CASCADE,
  FOREIGN KEY (`StudentID`) REFERENCES `students`(`ID`) ON DELETE CASCADE,
  FOREIGN KEY (`BlockID`) REFERENCES `blocks`(`ID`) ON DELETE CASCADE
);


CREATE TABLE `admin` (
  `ID` varchar(15) NOT NULL,
  `fullname` varchar(255)  NOT NULL,
  `email` varchar(255) NOT NULL,
  `contact` varchar(11) NOT NULL,
  `password` varchar(255) NOT NULL,
  `devicetoken` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`ID`)
);

CREATE TABLE `pending` (
  `ID` varchar(255) NOT NULL,
  `account` varchar(255) NOT NULL,
  `email` varchar(255) NOT NULL,
  `password` varchar(255) NOT NULL,
  `fullname` varchar(255)  NOT NULL,
  `contact` varchar(11) DEFAULT NULL,
  `profile` varchar(255) DEFAULT NULL,
  `devicetoken` varchar(255) DEFAULT NULL,
  `verified` varchar(10) DEFAULT "FALSE",
  `event` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
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



CREATE TABLE `class_sessions`(
   `ID` varchar(15) NOT NULL,
   `FacultyID` varchar(15) NOT NULL,
   `BlockID` int NOT NULL,
   `LabID` varchar(15) NOT NULL,
   `TimeIn` varchar(50) NOT NULL DEFAULT CURRENT_TIMESTAMP,
   `TimeOut` varchar(50) DEFAULT NULL,
   `Subject` varchar(255) DEFAULT NULL,
   `ESign` text DEFAULT NULL, 
   PRIMARY KEY(`ID`),
   FOREIGN KEY (`FacultyID`) REFERENCES `faculty` (`ID`) ON DELETE CASCADE,
    FOREIGN KEY (`LabID`) REFERENCES `laboratories` (`ID`) ON DELETE CASCADE,
   FOREIGN KEY (`BlockID`) REFERENCES `blocks`(`ID`) ON DELETE CASCADE
);

CREATE TABLE `sessions` (
  `ID` varchar(15) NOT NULL,
  `Timestamp` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `ClassID` varchar(15) NOT NULL,
  `StudentID` varchar(15) NOT NULL,
  `FacultyID` varchar(15) NOT NULL,
  `DeviceID` varchar(15) NOT NULL,
  `SystemUnit`varchar(10)  DEFAULT "F"  ,
  `Monitor`varchar(10)  DEFAULT "F",
  `Mouse`varchar(10)  DEFAULT "F",
  `Keyboard`varchar(10)  DEFAULT "F",
  `AVRUPS`varchar(10)  DEFAULT "F",
  `WIFIDONGLE`varchar(10)  DEFAULT "F",
  `Remarks`varchar(255)  DEFAULT NULL,
  PRIMARY KEY(`ID`),
  FOREIGN KEY (`StudentID`) REFERENCES `students` (`ID`) ON DELETE CASCADE,
  FOREIGN KEY (`DeviceID`) REFERENCES `devices` (`ID`) ON DELETE CASCADE,
  FOREIGN KEY (`FacultyID`) REFERENCES `faculty` (`ID`) ON DELETE CASCADE,
  FOREIGN KEY (`ClassID`) REFERENCES `class_sessions` (`ID`) ON DELETE CASCADE
);

COMMIT;
