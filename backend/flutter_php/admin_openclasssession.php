<?php

include "./_config.php";

include "./_header.php";

$id = $_POST['id'];



$sql = "SELECT `sessions`.*, fullname, `Name`
    FROM class_sessions, `sessions` , students, devices
    WHERE class_sessions.ID = `sessions`.ClassID AND class_sessions.ID = '$id'
    AND `sessions`.StudentID = students.ID AND devices.ID = `sessions`.DeviceID
    ";

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