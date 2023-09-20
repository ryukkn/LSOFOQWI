<?php

include "./_config.php";

include "./_header.php";

$prefix = $_POST['prefix'];
$startIndex = $_POST['startIndex'];
$noOfDevices = $_POST['noOfDevices'];
$labID  = $_POST['labID'];

$prefix =  htmlspecialchars($prefix);
$startIndex =  htmlspecialchars($startIndex);
$noOfDevices =  htmlspecialchars($noOfDevices);

$prefix = trim($prefix);
$startIndex = trim($startIndex);
$noOfDevices = trim($noOfDevices);

for($i = $startIndex; $i < $startIndex + $noOfDevices; $i +=1){
    // generate ID and QR value
    $id = uniqid();
    $qr = "d-".sha1($id);
    $name = $prefix."-".sprintf("%03d", $i);
    $sql = "INSERT INTO devices (`ID`,`Name`, `LabID`, `QR`) VALUES ('$id', '$name', '$labID', '$qr')";
    try{
        mysqli_query($conn, $sql);
    }catch(e){
        $conn->close();
        echo json_encode(array("success" => false, "message" => "Connection Failed"));
        die();
    }
}
$conn->close();
echo json_encode(array("success" => true));
die();

