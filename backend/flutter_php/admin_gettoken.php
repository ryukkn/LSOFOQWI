<?php

include "./_config.php";

include "./_header.php";


try{
    $sql = "SELECT `devicetoken` FROM `admin`";
    $result = mysqli_query($conn, $sql);
    $token = mysqli_fetch_assoc($result)['devicetoken'];
    $conn->close();
    echo json_encode(array("success" => true, 'devicetoken' => $token));
    die();
}catch(e){
    echo json_encode(array("success" => false, "message" => "Connection Failed"));
    die();
}