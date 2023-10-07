<?php

include "./_config.php";

include "./_header.php";

$id = $_POST['id'];

$sql = "SELECT * FROM class_sessions WHERE (`class_sessions`.FacultyID = '$id' AND `class_sessions`.`TimeIn` IS  NULL)";

try{
    $result = mysqli_query($conn, $sql);
    if(mysqli_num_rows($result) > 0){
        $conn->close();
        echo json_encode(array("success" => true, "done" => true));
        die();
    }
    $conn->close();
    echo json_encode(array("success" => true, "done" => false));
    die();
}catch(e){
    echo json_encode(array("success" => false, "message" => "Connection Failed"));
    die();
}