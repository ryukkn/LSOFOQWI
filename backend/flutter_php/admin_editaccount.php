<?php

include "./_config.php";

include "./_header.php";


$id = $_POST['id'];
$type = $_POST['type'];
$email = $_POST['email'];
$fullname = $_POST['fullname'];
$password = $_POST['password'];

$changedPassword = "";

if(trim($password) != ""){
    $password = sha1($password);
    $changedPassword = ",password='$password'";
}



$email = htmlspecialchars($email);
$fullname = htmlspecialchars($fullname);

$email = trim($email);
$fullname = trim($fullname);

switch($type){
    case "student":
        $sql = "UPDATE `students` SET fullname = '$fullname', email = '$email' $changedPassword WHERE ID = '$id'";
        break;
    case "faculty":
        $sql = "UPDATE `faculty` SET fullname = '$fullname', email = '$email' $changedPassword  WHERE ID = '$id'";
        break;
    default:
        $sql = "UPDATE `admin` SET fullname = '$fullname', email = '$email' $changedPassword  WHERE ID = '$id'";
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