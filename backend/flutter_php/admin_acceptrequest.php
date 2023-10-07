<?php

include "./_config.php";

include "./_header.php";


$id = $_POST['id'];


$sql = "UPDATE `pending` SET verified='TRUE' WHERE ID = '$id'";

try{
    mysqli_query($conn, $sql);
    echo json_encode(array("success" => true));
    die();
}catch(e){
    echo json_encode(array("success" => false, "message" => "Connection Failed"));
    die();
}