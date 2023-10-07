<?php

include "./_config.php";

include "./_header.php";

$id = $_POST['id'];
$type = $_POST['type'];

switch($type){
    case 'faculty':
        $sql = "SELECT * FROM faculty WHERE (ID = '$id')";
        break;
    case 'student':
        $sql = "SELECT * FROM students WHERE (ID = '$id')";
        break;
    case 'admin':
        $sql = "SELECT * FROM `admin` WHERE (ID = '$id')";
}



try{
    $result = mysqli_query($conn, $sql);
    if(mysqli_num_rows($result) <= 0){
        echo json_encode(array("success" => false, "message" => "not found"));
        $conn->close();
        die();
    }
    $row = mysqli_fetch_assoc($result);
    $conn->close();
    echo json_encode(array("success" => true, "row"=> $row));
    die();
}catch(e){
    echo json_encode(array("success" => false, "message" => "Connection Failed"));
    die();
}