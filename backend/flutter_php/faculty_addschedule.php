<?php

include "./_config.php";

include "./_header.php";

$id = $_POST['id'];
$blockID = $_POST['blockID'];
$labID = $_POST['labID'];
$day = $_POST['day'];
$time = $_POST['time'];

$startTime =  date("H:i", strtotime( explode(" - ", $time)[0]));
$endTime = date("H:i", strtotime( explode(" - ", $time)[1]));



$sql = "INSERT INTO schedules (`FacultyID`, `BlockID`,`LabID`,`day`,`time`) VALUES ('$id', '$blockID', '$labID',
    '$day','$startTime - $endTime'
)";

try{
    mysqli_query($conn, $sql);
    $conn->close();
    echo json_encode(array("success" => true));
    die();
}catch(e){
    echo json_encode(array("success" => false, "message" => "Connection Failed"));
    die();
}