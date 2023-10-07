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
    $result = mysqli_query($conn, $sql);
    $conn->close();
    echo json_encode(array("success" => true));
    die();
}catch(e){
    echo json_encode(array("success" => false, "message" => "Connection Failed"));
    die();
}