<?php

include "./_config.php";

include "./_header.php";

$id = $_POST['id'];

$sql = "SELECT `sessions`.*,
    students.fullname, students.QR as student_qr, devices.Name, devices.QR as device_qr, CURRENT_TIMESTAMP() as `currenttime`
    FROM`sessions`,devices, students, class_sessions
    WHERE `sessions`.StudentID =  students.ID AND `sessions`.DeviceID = '$id' AND `sessions`.DeviceID = devices.ID AND `sessions`.ClassID = class_sessions.ID 
    AND `TimeOut` IS NOT NULL
    ORDER BY `Timestamp` DESC";

try{
    $result = mysqli_query($conn, $sql);
    $rows = [];
    while($row = mysqli_fetch_assoc($result)){
        $datetime1 = strtotime($row['currenttime']);
        $datetime2 = strtotime($row['Timestamp']);
        if(($datetime1-$datetime2) * 86400 < 30 && $filterbyMonth != "" && $filterbyYear !=""){
            break;
        }
        array_push($rows, $row);
    }
    $conn->close();
    echo json_encode(array("success" => true, "rows"=> $rows));
    die();
}catch(e){
    echo json_encode(array("success" => false, "message" => "Connection Failed"));
    die();
}