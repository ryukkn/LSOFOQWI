<?php

include "./_config.php";

include "./_header.php";

$email = $_POST['email'];
$priviledge = $_POST['priviledge'];

$email = trim($email);
$email = htmlspecialchars($email);

switch($priviledge){
    case "1":
        $sql = "SELECT * FROM `faculty` WHERE (`faculty`.email = '$email')";
    break;
    case "2":
        $sql = "SELECT * FROM `admin` WHERE (`admin`.email = '$email')";
    break;
    case "3";
        $sql = "SELECT * FROM `students` WHERE (`students`.email = '$email')";
    break;
    default:
        echo json_encode(array("success" => false, "message" => "Select account type."));
        die();
}

try{
    mysqli_query($conn, $sql);
    $result = mysqli_query($conn, $sql);
    if(mysqli_num_rows($result) <= 0){
        echo json_encode(array("success" => true));
        die();
    }else{
        echo json_encode(array("success" => false, "message" => "Email is already registered."));
        die();
    }

}catch(e){
    echo json_encode(array("success" => false, "message" => "Unable to connect to the server."));
    die();
}