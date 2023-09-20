<?php

include "./_config.php";

include "./_header.php";

$sql = "SELECT * FROM laboratories ORDER BY `Building`, `Room` ";

try{
    $result = mysqli_query($conn, $sql);
    $rows = [];
    while($row = mysqli_fetch_assoc($result)){
        $labID = $row['ID'];
        $sql = "SELECT COUNT(`id`) as `units` FROM devices WHERE (devices.LabID = '$labID') ";
        $result2 = mysqli_query($conn, $sql);
        $row2 = mysqli_fetch_assoc($result2);
        $row['units'] = (int) $row2['units'];
        // array_push($row, array("units" => $row2['units']));
        array_push($rows, $row);
    }
    $conn->close();
    echo json_encode(array("success" => true, "rows"=> $rows));
    die();
}catch(e){
    echo json_encode(array("success" => false, "message" => "Connection Failed"));
    die();
}