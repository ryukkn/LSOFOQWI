<?php

include "./_config.php";

include "./_header.php";

$id = $_POST['id'];
$labID = $_POST['labID'];

$sql = "UPDATE `devices` SET `devices`.LabID = '$labID' WHERE `devices`.id = '$id'";

try{
    mysqli_query($conn, $sql);
    echo json_encode(array("success" => true));
    die();
}catch(e){
    echo json_encode(array("success" => false, "message" => "Connection Failed"));
    die();
}