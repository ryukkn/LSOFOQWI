<?php

include "./_config.php";

include "./_header.php";

$id = $_POST['id'];

// $sql = "SELECT * FROM class_sessions WHERE (`class_sessions`.FacultyID = '$id' AND `class_sessions`.`TimeOut` IS  NULL)";

$sql =  "SELECT class_sessions.*, courses.course, levels.level, blocks.block,
laboratories.department, laboratories.laboratory, faculty.fullname 
FROM class_sessions, laboratories, faculty, courses, levels, blocks 
WHERE class_sessions.FacultyID = faculty.ID AND blocks.ID = class_sessions.BlockID AND class_sessions.FacultyID = '$id'
AND class_sessions.LabID = laboratories.ID
AND courses.ID = levels.CourseID AND levels.ID = blocks.LevelID AND `TimeOut` IS  NULL";

try{
    $result = mysqli_query($conn, $sql);
    if(mysqli_num_rows($result) > 0){
        $row = mysqli_fetch_assoc($result);
        $conn->close();
        echo json_encode(array("success" => true, "active" => true, "row" => $row));
        die();
    }
    $conn->close();
    echo json_encode(array("success" => true, "active" => false));
    die();
}catch(e){
    echo json_encode(array("success" => false, "message" => "Connection Failed"));
    die();
}