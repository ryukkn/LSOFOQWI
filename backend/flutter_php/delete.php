<?php

include "./_config.php";

include "./_header.php";


$id = $_POST['id'];
$from = $_POST['from'];

$from = htmlspecialchars($from);
$id = htmlspecialchars($id);

$id = trim($id);
$from = trim($from);

$sql = "DELETE FROM `$from` WHERE `$from`.ID = '$id'";

try{
    mysqli_query($conn, $sql);
    if($from == 'students' || $from == 'faculty' || $from == 'pending'){
        if(file_exists('upload/'.sha1($id).".jpg")){
             unlink('upload/'.sha1($id).".jpg");
        }
       
    }
    echo json_encode(array("success" => true));
    die();
}catch(e){
    echo json_encode(array("success" => false, "message" => "Connection Failed"));
    die();
}