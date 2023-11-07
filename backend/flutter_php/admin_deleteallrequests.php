<?php

include "./_config.php";

include "./_header.php";


$priv = $_POST['priv'];


$sql = "SELECT * FROM `pending` WHERE account = '$priv'";

try{
    $result = mysqli_query($conn, $sql);
    while($row = mysqli_fetch_assoc($result)){
        $id = $row['ID'];
        $sql2 = "DELETE FROM `pending` WHERE ID = '$id'";
        mysqli_query($conn, $sql2);
        $profile = $row['profile'];
        if(file_exists($profile)){
            unlink($profile);
        }
    }
    echo json_encode(array("success" => true));
    die();
}catch(e){
    echo json_encode(array("success" => false, "message" => "Connection Failed"));
    die();
}