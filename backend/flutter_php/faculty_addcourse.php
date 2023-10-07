<?php

include "./_config.php";

include "./_header.php";

$id = $_POST['id'];
$course_id = $_POST['course_id'];

$id = htmlspecialchars($id);


$sql = "INSERT INTO `assigned_class`(`FacultyID`, `BlockID`)
    VALUES ( '$id', '$course_id')";

try{
    $result = mysqli_query($conn, $sql);
    $conn->close();
    echo json_encode(array("success" => true));
    die();
}catch(e){
    echo json_encode(array("success" => false, "message" => "Connection Failed"));
    die();
}