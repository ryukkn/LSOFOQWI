<?php

include "./_config.php";

include "./_header.php";


$id = $_POST['id'];
$building = $_POST['building'];
$room = $_POST['room'];


$building = htmlspecialchars($building);
$room = htmlspecialchars($room);

$building = trim($building);
$room = trim($room);

$sql = "UPDATE `laboratories` SET `laboratories`.Room = '$room', `laboratories`.Building = '$building' WHERE `laboratories`.ID = '$id'";

try{
    mysqli_query($conn, $sql);
    echo json_encode(array("success" => true));
    die();
}catch(e){
    echo json_encode(array("success" => false, "message" => "Connection Failed"));
    die();
}