
USE comlabmanagement;

INSERT INTO `students` (`ID`, `email`, `password`,`contact`,`fullname`, `QR`) 
    VALUES ('SF23sSCZDA1@ls', 'test@gmail.com', 'a94a8fe5ccb19ba61c4c0873d391e987982fbbd3', 09957140344, 'Test', 's-test');

INSERT INTO `admin` (`ID`, `email`, `password`,`contact`, `fullname`) 
    VALUES ('SFasdSCZDA1@ls', 'admin@gmail.com', 'd033e22ae348aeb5660fc2140aec35850c4da997', 09999231412, 'Admin' );

INSERT INTO `faculty` (`ID`, `email`, `password`,`contact`,`fullname`) 
    VALUES ('SF23sSCZDA1@ls', 'test@gmail.com', 'a94a8fe5ccb19ba61c4c0873d391e987982fbbd3', 09957140344, 'Faculty');
