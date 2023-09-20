<?php

include "./_config.php";

include "./_header.php";

$QR = $_POST['QR'];

$QR = htmlspecialchars($QR);

$sql = "SELECT * FROM students WHERE (`students`.QR = '$QR')";

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