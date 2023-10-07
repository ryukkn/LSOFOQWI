<?php

include "./_config.php";

include "./_header.php";


$id = $_POST['id'];

$sql = "SELECT blocks.ID as ID, courses.course, levels.level, blocks.block ,
    courses.ID as courseID, levels.ID as levelID
    FROM assigned_class, courses, levels, blocks 
    WHERE assigned_class.FacultyID = '$id' AND blocks.ID = assigned_class.BlockID  AND courses.ID = levels.CourseID AND levels.ID = blocks.LevelID";

try{
    $result = mysqli_query($conn, $sql);
    $rows = [];
    while($row = mysqli_fetch_assoc($result)){
        array_push($rows, $row);
    }
    $conn->close();
    echo json_encode(array("success" => true, "rows"=> $rows));
    die();
}catch(e){
    echo json_encode(array("success" => false, "message" => "Connection Failed"));
    die();
}