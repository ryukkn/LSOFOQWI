<?php

include "./_config.php";

include "./_header.php";

$building = $_POST['building'];
$room = $_POST['room'];

$room =  htmlspecialchars($room);
$building =  htmlspecialchars($building);

$room = trim($room);
$building = trim($building);

// generate ID

$id = uniqid();

$sql = "INSERT INTO laboratories (`ID`,`Building`, `Room`) VALUES ('$id', '$building', '$room')";

try{
    mysqli_query($conn, $sql);
    $conn->close();
    echo json_encode(array("success" => true));
    die();
}catch(e){
    echo json_encode(array("success" => false, "message" => "Connection Failed"));
    die();
}