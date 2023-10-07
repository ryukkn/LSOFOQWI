<?php

include "./_config.php";

include "./_header.php";


$id = $_POST['id'];
$blockID = $_POST['blockID'];


$sql = "UPDATE `students` SET BlockID = '$blockID' WHERE ID = '$id'";

try{
    mysqli_query($conn, $sql);
    echo json_encode(array("success" => true));
    die();
}catch(e){
    echo json_encode(array("success" => false, "message" => "Connection Failed"));
    die();
}