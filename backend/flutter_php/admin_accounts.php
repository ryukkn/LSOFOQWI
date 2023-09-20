<?php

include "./_config.php";

include "./_header.php";

$type = $_POST['type'];

switch($type) {
    case 1:
        $sql = "SELECT * FROM `admin`";
        break;
    case 2:
        $sql = "SELECT * FROM `faculty`";
        break;
    case 3:
        $sql = "SELECT * FROM `students`";
        break;
    default:
        echo json_encode(array("success" => false, "message"=> "Invalid type"));
        die();

}

try{
    $result = mysqli_query($conn, $sql);
    $rows = [];
    while($row = mysqli_fetch_assoc($result)){
        array_push($rows, $row);
    }
    $conn->close();
    echo json_encode(array("success" => true, "rows"=> $rows));
    die();
}catch(e){
    echo json_encode(array("success" => false, "message" => "Connection Failed"));
    die();
}