
-- USE comlabmanagement;

INSERT INTO `students` (`ID`, `email`, `password`,`contact`,`fullname`, `QR`) 
    VALUES ('SF23sSCZDA1@ls', 'test@gmail.com', 'a94a8fe5ccb19ba61c4c0873d391e987982fbbd3', '09957140344', 'Test', 's-test');

INSERT INTO `admin` (`ID`, `email`, `password`,`contact`, `fullname`) 
    VALUES ('SFasdACZDA1@ls', 'superadmin@gmail.com', 'd033e22ae348aeb5660fc2140aec35850c4da997', '09999231412', 'Superadmin' );

INSERT INTO `admin` (`ID`, `email`, `password`,`contact`, `fullname`) 
    VALUES ('SFasdACZDA2@ls', 'admin1@gmail.com', 'd033e22ae348aeb5660fc2140aec35850c4da997', '09999231412', 'Admin' );

INSERT INTO `admin` (`ID`, `email`, `password`,`contact`, `fullname`) 
    VALUES ('SFasdACZDA3@ls', 'admin2@gmail.com', 'd033e22ae348aeb5660fc2140aec35850c4da997', '09999231412', 'Admin' );

INSERT INTO `faculty` (`ID`, `email`, `password`,`contact`,`fullname`) 
    VALUES ('SF23sSCZAA1@ls', 'test@gmail.com', 'a94a8fe5ccb19ba61c4c0873d391e987982fbbd3', '09957140344', 'Faculty');


INSERT INTO `courses` (`course`) VALUES ('BS Computer Science');
INSERT INTO `courses` (`course`) VALUES ('BS Information System');
INSERT INTO `courses` (`course`) VALUES ('BS Information Technology');
INSERT INTO `courses` (`course`) VALUES ('BS Information Technology Major in Animation');

INSERT INTO `levels` (`level`, `CourseID`) VALUES ('First Year', '1');
INSERT INTO `levels` (`level`, `CourseID`) VALUES ('First Year', '2');
INSERT INTO `levels` (`level`, `CourseID`) VALUES ('First Year', '3');
INSERT INTO `levels` (`level`, `CourseID`) VALUES ('First Year', '4');
INSERT INTO `levels` (`level`, `CourseID`) VALUES ('Second Year', '1');
INSERT INTO `levels` (`level`, `CourseID`) VALUES ('Second Year', '2');
INSERT INTO `levels` (`level`, `CourseID`) VALUES ('Second Year', '3');
INSERT INTO `levels` (`level`, `CourseID`) VALUES ('Second Year', '4');
INSERT INTO `levels` (`level`, `CourseID`) VALUES ('Third Year', '1');
INSERT INTO `levels` (`level`, `CourseID`) VALUES ('Third Year', '2');
INSERT INTO `levels` (`level`, `CourseID`) VALUES ('Third Year', '3');
INSERT INTO `levels` (`level`, `CourseID`) VALUES ('Third Year', '4');
INSERT INTO `levels` (`level`, `CourseID`) VALUES ('Fourth Year', '1');
INSERT INTO `levels` (`level`, `CourseID`) VALUES ('Fourth Year', '2');
INSERT INTO `levels` (`level`, `CourseID`) VALUES ('Fourth Year', '3');
INSERT INTO `levels` (`level`, `CourseID`) VALUES ('Fourth Year', '4');

INSERT INTO `blocks` (`block`, `LevelID`) VALUES ('Block A', '1');
INSERT INTO `blocks` (`block`, `LevelID`) VALUES ('Block B', '1');
INSERT INTO `blocks` (`block`, `LevelID`) VALUES ('Block C', '1');
INSERT INTO `blocks` (`block`, `LevelID`) VALUES ('Block A', '2');
INSERT INTO `blocks` (`block`, `LevelID`) VALUES ('Block B', '2');
INSERT INTO `blocks` (`block`, `LevelID`) VALUES ('Block C', '2');
INSERT INTO `blocks` (`block`, `LevelID`) VALUES ('Block A', '3');
INSERT INTO `blocks` (`block`, `LevelID`) VALUES ('Block B', '3');
INSERT INTO `blocks` (`block`, `LevelID`) VALUES ('Block C', '3');
INSERT INTO `blocks` (`block`, `LevelID`) VALUES ('Block A', '4');
INSERT INTO `blocks` (`block`, `LevelID`) VALUES ('Block B', '4');
INSERT INTO `blocks` (`block`, `LevelID`) VALUES ('Block C', '4');
INSERT INTO `blocks` (`block`, `LevelID`) VALUES ('Block A', '5');
INSERT INTO `blocks` (`block`, `LevelID`) VALUES ('Block B', '5');
INSERT INTO `blocks` (`block`, `LevelID`) VALUES ('Block C', '5');
INSERT INTO `blocks` (`block`, `LevelID`) VALUES ('Block A', '6');
INSERT INTO `blocks` (`block`, `LevelID`) VALUES ('Block B', '6');
INSERT INTO `blocks` (`block`, `LevelID`) VALUES ('Block C', '6');
INSERT INTO `blocks` (`block`, `LevelID`) VALUES ('Block A', '7');
INSERT INTO `blocks` (`block`, `LevelID`) VALUES ('Block B', '7');
INSERT INTO `blocks` (`block`, `LevelID`) VALUES ('Block C', '7');
INSERT INTO `blocks` (`block`, `LevelID`) VALUES ('Block A', '8');
INSERT INTO `blocks` (`block`, `LevelID`) VALUES ('Block B', '8');
INSERT INTO `blocks` (`block`, `LevelID`) VALUES ('Block C', '8');
INSERT INTO `blocks` (`block`, `LevelID`) VALUES ('Block A', '9');
INSERT INTO `blocks` (`block`, `LevelID`) VALUES ('Block B', '9');
INSERT INTO `blocks` (`block`, `LevelID`) VALUES ('Block C', '9');
INSERT INTO `blocks` (`block`, `LevelID`) VALUES ('Block A', '10');
INSERT INTO `blocks` (`block`, `LevelID`) VALUES ('Block B', '10');
INSERT INTO `blocks` (`block`, `LevelID`) VALUES ('Block C', '10');
INSERT INTO `blocks` (`block`, `LevelID`) VALUES ('Block A', '11');
INSERT INTO `blocks` (`block`, `LevelID`) VALUES ('Block B', '11');
INSERT INTO `blocks` (`block`, `LevelID`) VALUES ('Block C', '11');
INSERT INTO `blocks` (`block`, `LevelID`) VALUES ('Block A', '12');
INSERT INTO `blocks` (`block`, `LevelID`) VALUES ('Block B', '12');
INSERT INTO `blocks` (`block`, `LevelID`) VALUES ('Block C', '12');
INSERT INTO `blocks` (`block`, `LevelID`) VALUES ('Block A', '13');
INSERT INTO `blocks` (`block`, `LevelID`) VALUES ('Block B', '13');
INSERT INTO `blocks` (`block`, `LevelID`) VALUES ('Block C', '13');
INSERT INTO `blocks` (`block`, `LevelID`) VALUES ('Block A', '14');
INSERT INTO `blocks` (`block`, `LevelID`) VALUES ('Block B', '14');
INSERT INTO `blocks` (`block`, `LevelID`) VALUES ('Block C', '14');
INSERT INTO `blocks` (`block`, `LevelID`) VALUES ('Block A', '15');
INSERT INTO `blocks` (`block`, `LevelID`) VALUES ('Block B', '15');
INSERT INTO `blocks` (`block`, `LevelID`) VALUES ('Block C', '15');
INSERT INTO `blocks` (`block`, `LevelID`) VALUES ('Block A', '16');
INSERT INTO `blocks` (`block`, `LevelID`) VALUES ('Block B', '16');
INSERT INTO `blocks` (`block`, `LevelID`) VALUES ('Block C', '16');




INSERT INTO `assigned_class` (`BlockID`, `FacultyID`) 
    VALUES(2, 'SF23sSCZAA1@ls' );
    
INSERT INTO `assigned_class` (`BlockID`, `FacultyID`) 
    VALUES(3, 'SF23sSCZAA1@ls' );

INSERT INTO `assigned_class` (`BlockID`, `FacultyID`) 
    VALUES(10, 'SF23sSCZAA1@ls' );
    