<?php

include "./_config.php";

include "./_header.php";


$id = $_POST['id'];
$type = $_POST['type'];

$email = "";
if(isset($_POST['email'])){
    $email = $_POST['email'];
    $email = htmlspecialchars($email);
    $email = trim($email);
    $email = ", email = '$email'";
}

$fullname = $_POST['fullname'];
$password = $_POST['password'];
$contact = $_POST['contact'];

$changedPassword = "";

if(trim($password) != ""){
    $password = sha1($password);
    $changedPassword = ",password='$password'";
}




$fullname = htmlspecialchars($fullname);
$contact = htmlspecialchars($contact);
$fullname = trim($fullname);
$contact = trim($contact);

switch($type){
    case "student":
        $sql = "UPDATE `students` SET fullname = '$fullname', contact = '$contact'  $email $changedPassword WHERE ID = '$id'";
        break;
    case "faculty":
        $sql = "UPDATE `faculty` SET fullname = '$fullname', contact = '$contact' $email $changedPassword  WHERE ID = '$id'";
        break;
    default:
        $sql = "UPDATE `admin` SET fullname = '$fullname', contact = '$contact' , email = '$email' $changedPassword  WHERE ID = '$id'";
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