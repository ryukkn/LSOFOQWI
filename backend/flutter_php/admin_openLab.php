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
        $deviceID = $row['ID'];
        $sql = "SELECT * FROM `sessions`, `students`,`devices`, `class_sessions`
        WHERE DeviceID='$deviceID' AND `devices`.ID = DeviceID AND `students`.ID = StudentID 
        AND `class_sessions`.ID = `sessions`.ClassID AND `class_sessions`.`TimeOut` IS NOT NULL
        ORDER BY `Timestamp` DESC";
        $session = mysqli_fetch_assoc(mysqli_query($conn, $sql));
        $row['session'] = $session;
        array_push($rows, $row);
    }
    $conn->close();
    echo json_encode(array("success" => true, "rows"=> $rows));
die();
}catch(e){
    echo json_encode(array("success" => false, "message" => "Connection Failed"));
    die();
}