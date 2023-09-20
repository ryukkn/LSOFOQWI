<?php

include "./_config.php";

include "./_header.php";

$id = $_POST['id'];

$sql = "SELECT * FROM laboratories WHERE (`laboratories`.id = '$id')";

try{
    $result = mysqli_query($conn, $sql);
    $row = mysqli_fetch_assoc($result);
    $conn->close();
    echo json_encode(array("success" => true, "row"=> $row));
    die();
}catch(e){
    echo json_encode(array("success" => false, "message" => "Connection Failed"));
    die();
}