<?php

include "./_config.php";

include "./_header.php";

$id = $_POST['id'];

$sql = "SELECT `sessions`.*, 
    students.fullname, students.QR as student_qr, devices.Name, devices.QR as device_qr, CURRENT_TIMESTAMP() as `currenttime`
    FROM`sessions`,devices, students
    WHERE `sessions`.StudentID =  '$id'AND `sessions`.DeviceID = devices.ID
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