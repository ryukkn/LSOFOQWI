<?php

include "./_config.php";

include "./_header.php";


$priv = $_POST['priv'];


$sql = "DELETE FROM `pending` WHERE account = '$priv'";

try{
    mysqli_query($conn, $sql);
    echo json_encode(array("success" => true));
    die();
}catch(e){
    echo json_encode(array("success" => false, "message" => "Connection Failed"));
    die();
}