<?php

include "./_config.php";

include "./_header.php";

$facultyID = $_POST['facultyID'];
$studentID = $_POST['studentID'];
$deviceID = $_POST['deviceID'];
$systemUnit = $_POST['systemUnit'];
$monitor = $_POST['monitor'];
$mouse = $_POST['mouse'];
$keyboard = $_POST['keyboard'];
$avrups = $_POST['avrups'];
$wifidongle = $_POST['wifidongle'];
$remarks = $_POST['remarks'];


try{
    // check for active session
    $sql = "SELECT ID FROM class_sessions WHERE FacultyID = '$facultyID' AND `TimeOut` IS NULL";
    $result = mysqli_query($conn, $sql);
    if(mysqli_num_rows($result) <= 0){
        echo json_encode(array("success" => false, "message" => "No active sessions found."));
        $conn->close();
        die();
    }
    $classID = mysqli_fetch_assoc($result)['ID'];
    $sessionid = uniqid();
    // check if student-device-class session already exist
    $sql = "SELECT ID FROM `sessions` WHERE StudentID = '$studentID' AND DeviceID = '$deviceID' AND ClassID = '$classID'";
    $result = mysqli_query($conn, $sql);
    if(mysqli_num_rows($result) <= 0){
        // then create new session
        $sql = "INSERT INTO `sessions` (`ID`, `FacultyID`, `StudentID`, `DeviceID`,`ClassID`,
            `SystemUnit`, `Monitor`, `Mouse`,`Keyboard`,`AVRUPS`, `WIFIDONGLE`, `Remarks`) VALUES (
                '$sessionid', '$facultyID','$studentID','$deviceID','$classID','$systemUnit','$monitor',
                '$mouse','$keyboard', '$avrups','$wifidongle','$remarks'
            )
         ";
        mysqli_query($conn, $sql);
        echo json_encode(array("success" => true));
        $conn->close();
        die();
    }else{
        // update
        $sessionid = mysqli_fetch_assoc($result)['ID'];
        $sql = "UPDATE `sessions` SET `Timestamp`= CURRENT_TIMESTAMP, `SystemUnit` = '$systemUnit', `Monitor` = '$monitor',
            `Mouse` = '$mouse', `Keyboard`='$keyboard' , `AVRUPS` = '$avrups', `WIFIDONGLE` = '$wifidongle', `Remarks`='$remarks'
            WHERE ID = '$sessionid'
         ";
        mysqli_query($conn, $sql);
        echo json_encode(array("success" => true));
        $conn->close();
        die();
    }




    $conn->close();
    echo json_encode(array("success" => true));
    die();
}catch(e){
    echo json_encode(array("success" => false, "message" => "Connection Failed"));
    die();
}