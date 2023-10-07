<?php

include "./_config.php";

include "./_header.php";

$classID = $_POST['classID'];

$sql = "SELECT `sessions`.*, 
    students.fullname, students.QR as student_qr, devices.Name, devices.QR as device_qr
    FROM`sessions`,devices, students
    WHERE `sessions`.ClassID = '$classID'
    AND `sessions`.StudentID = students.ID AND `sessions`.DeviceID = devices.ID
    ORDER BY `Timestamp` DESC";

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