<?php

include "./_config.php";

include "./_header.php";

$id = $_POST['id'];
$esign = $_POST['esign'];

$sql = "SELECT ID FROM class_sessions WHERE FacultyID='$id' AND `TimeOut` IS NULL";

try{
    $result = mysqli_query($conn, $sql);
    $classID = mysqli_fetch_assoc($result)['ID'];
    $sql = "UPDATE class_sessions SET `TimeOut`= CURRENT_TIMESTAMP , `ESign`='$esign' WHERE (ID = '$classID')";
    mysqli_query($conn, $sql);
    $conn->close();
    echo json_encode(array("success" => true));
    die();
}catch(e){
    echo json_encode(array("success" => false, "message" => "Connection Failed"));
    die();
}