<?php

include "./_config.php";

include "./_header.php";

$classID = $_POST['classID'];
$studentQR = $_POST['studentQR'];   
$deviceQR = $_POST['deviceQR'];

$sql = "SELECT `sessions`.*, 
    students.fullname, students.QR as student_qr, devices.Name, devices.QR as device_qr
    FROM`sessions`,devices, students
    WHERE `sessions`.ClassID = '$classID'
    AND `sessions`.StudentID = students.ID  AND students.QR = '$studentQR' AND `sessions`.DeviceID = devices.ID AND devices.QR = '$deviceQR' 
    ORDER BY `Timestamp` DESC";

try{
    $result = mysqli_query($conn, $sql);
    $row = mysqli_fetch_assoc($result);
    $conn->close();
    echo json_encode(array("success" => true, "row"=> $row));
    die();
}catch(e){
    echo json_encode(array("success" => false, "message" => "Connection Failed"));
    die();
}