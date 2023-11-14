<?php

include "./_config.php";

include "./_header.php";

$faculty_id = $_POST['id'];
$ids = $_POST['ids'];


$ids = json_decode($ids);

try{
    foreach($ids as $id){
        $sql = "DELETE FROM `assigned_class` WHERE `assigned_class`.BlockID = '$id' AND `assigned_class`.FacultyID = '$faculty_id'";
        mysqli_query($conn, $sql);
        // check if there is an ongoing session and remove it
        $sql = "DELETE FROM `class_sessions` WHERE BlockID = '$id' AND FacultyID = '$faculty_id' AND `TimeOut` IS NULL";
        mysqli_query($conn, $sql);
        // check if there is a schedule and remove it
        $sql = "DELETE FROM `schedules` WHERE BlockID = '$id' AND FacultyID = '$faculty_id'";
        mysqli_query($conn, $sql);
    }
    $conn->close();
    echo json_encode(array("success" => true));
    die();
}catch(e){
    echo json_encode(array("success" => false, "message" => "Connection Failed"));
    die();
}