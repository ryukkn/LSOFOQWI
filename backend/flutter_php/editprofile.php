<?php

include "./_config.php";

include "./_header.php";


$id = $_POST['id'];
$fullname = $_POST['fullname'];
$contact = $_POST['contact'];

$changedPassword = "";


$fullname = htmlspecialchars($fullname);
$contact = htmlspecialchars($contact);

$contact = trim($contact);
$fullname = trim($fullname);

if($isset($_POST['department'])){
    $department = $_POST['department'];
    $department = htmlspecialchars($department);
    $department = trim($department);
    $sql = "UPDATE `faculty` SET fullname = '$fullname', department = '$department' , contact = '$contact'  WHERE ID = '$id'";
}else if($isset($_POST['block'])){
    $block = $_POST['block'];
    $block = htmlspecialchars($block);
    $block = trim($block);
    $sql = "UPDATE `students` SET fullname = '$fullname', `BlockID` = '$block' , contact = '$contact'  WHERE ID = '$id'";
}
try{
    
    mysqli_query($conn, $sql);
    echo json_encode(array("success" => true));
    die();
}catch(e){
    echo json_encode(array("success" => false, "message" => "Connection Failed"));
    die();
}