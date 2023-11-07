<?php

include "./_config.php";

include "./_header.php";

$token = $_POST['token'];


try{
    $sql = "UPDATE `admin` SET `devicetoken`= '$token'";
    $result = mysqli_query($conn, $sql);
    $conn->close();
    echo json_encode(array("success" => true));
    die();
}catch(e){
    echo json_encode(array("success" => false, "message" => "Connection Failed"));
    die();
}