<?php

include "./_config.php";

include "./_header.php";

$labID = $_POST['LabID'];

$labID = htmlspecialchars($labID);

$sql = "SELECT * FROM devices WHERE (`devices`.LabID = '$labID') ORDER BY `Name`";

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