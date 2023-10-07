<?php

include "./_config.php";

include "./_header.php";

$id = $_POST['id'];

try{
    
    $sql = "SELECT * FROM students WHERE ID = '$id'";
    $result = mysqli_query($conn, $sql);
    $qr = mysqli_fetch_array($result)['QR'];
    $conn->close();
    echo json_encode(array("success" => true, "QR"=>$qr));
    die();
}catch(e){
    echo json_encode(array("success" => false, "message" => "Connection Failed"));
    die();
}