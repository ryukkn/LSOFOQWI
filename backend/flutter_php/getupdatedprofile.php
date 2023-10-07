<?php

include "./_config.php";

include "./_header.php";

$id = $_POST['id'];
$type = $_POST['type'];
try{
    switch($type){
        case 'student':
            $sql = "SELECT * FROM students WHERE ID = '$id'";
            break;
        case 'faculty':
            $sql = "SELECT * FROM faculty WHERE ID = '$id'";
            break;
    }
    $result = mysqli_query($conn, $sql);
    $row = mysqli_fetch_array($result);
    $conn->close();
    echo json_encode(array("success" => true, "row"=>$row));
    die();
}catch(e){
    echo json_encode(array("success" => false, "message" => "Connection Failed"));
    die();
}