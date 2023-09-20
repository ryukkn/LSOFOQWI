<?php

include "./_config.php";

include "./_header.php";

$sql = "SELECT * FROM pending ORDER BY `event`";

try{
    $result = mysqli_query($conn, $sql);
    $rows = [];
    while($row = mysqli_fetch_assoc($result)){
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