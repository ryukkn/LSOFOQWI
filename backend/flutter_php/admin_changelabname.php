<?php

include "./_config.php";

include "./_header.php";


$id = $_POST['id'];
$department = $_POST['department'];
$laboratory = $_POST['laboratory'];


$department = htmlspecialchars($department);
$laboratory = htmlspecialchars($laboratory);

$department = trim($department);
$laboratory = trim($laboratory);

$sql = "UPDATE `laboratories` SET `laboratories`.laboratory = '$laboratory', `laboratories`.department = '$department' WHERE `laboratories`.ID = '$id'";

try{
    mysqli_query($conn, $sql);
    echo json_encode(array("success" => true));
    die();
}catch(e){
    echo json_encode(array("success" => false, "message" => "Connection Failed"));
    die();
}