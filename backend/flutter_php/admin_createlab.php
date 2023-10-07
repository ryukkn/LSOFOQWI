<?php

include "./_config.php";

include "./_header.php";

$department = $_POST['department'];
$laboratory = $_POST['laboratory'];

$department =  htmlspecialchars($department);
$laboratory =  htmlspecialchars($laboratory);

$laboratory = trim($laboratory);
$department = trim($department);

// generate ID

$id = uniqid();

$sql = "INSERT INTO laboratories (`ID`,`department`, `laboratory`) VALUES ('$id', '$department', '$laboratory')";

try{
    mysqli_query($conn, $sql);
    $conn->close();
    echo json_encode(array("success" => true));
    die();
}catch(e){
    echo json_encode(array("success" => false, "message" => "Connection Failed"));
    die();
}