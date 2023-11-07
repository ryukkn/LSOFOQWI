<?php

include "./_config.php";

include "./_header.php";

$id = $_POST['id'];
$course_id = $_POST['course_id'];
$labID = $_POST['labID'];

$session_id = uniqid();

$sql = "INSERT INTO `class_sessions`(`ID`, `FacultyID`, `BlockID`,`LabID`)
    VALUES ('$session_id', '$id', '$course_id', '$labID')";

try{
    mysqli_query($conn, $sql);
    $sql =  "SELECT class_sessions.*, courses.course, levels.level, blocks.block,
        laboratories.department, laboratories.laboratory, faculty.fullname 
        FROM class_sessions, laboratories, faculty, courses, levels, blocks 
        WHERE class_sessions.FacultyID = faculty.ID AND blocks.ID = class_sessions.BlockID AND class_sessions.FacultyID = '$id'
        AND class_sessions.LabID = laboratories.ID
        AND courses.ID = levels.CourseID AND levels.ID = blocks.LevelID AND `TimeOut` IS  NULL";
    $result = mysqli_query($conn, $sql);
    $row = mysqli_fetch_assoc($result);
    $conn->close();
    echo json_encode(array("success" => true, "row"=>$row));
    die();
}catch(e){
    echo json_encode(array("success" => false, "message" => "Connection Failed"));
    die();
}