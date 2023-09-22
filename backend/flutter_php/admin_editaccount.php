<?php

include "./_config.php";

include "./_header.php";


$id = $_POST['id'];
$type = $_POST['type'];
$email = $_POST['email'];
$fullname = $_POST['fullname'];


$email = htmlspecialchars($email);
$fullname = htmlspecialchars($fullname);

$email = trim($email);
$fullname = trim($fullname);

switch($type){
    case "student":
        $sql = "UPDATE `students` SET fullname = '$fullname', email = '$email' WHERE ID = '$id'";
        break;
    case "faculty":
        $sql = "UPDATE `faculty` SET fullname = '$fullname', email = '$email' WHERE ID = '$id'";
        break;
    default:
        break;
}

try{
    mysqli_query($conn, $sql);
    echo json_encode(array("success" => true));
    die();
}catch(e){
    echo json_encode(array("success" => false, "message" => "Connection Failed"));
    die();
}