<?php

include "./_config.php";

include "./_header.php";

$id = uniqid();
$profile = NULL;

if(isset($_POST['pendingID'])){
    try{
        $pendingID = $_POST['pendingID'];
        $sql = "DELETE FROM `pending` WHERE ID = '$pendingID'";
        mysqli_query($conn, $sql);
        $profile = "'upload/".sha1($pendingID).".jpg'";
    }catch(e){
        echo json_encode(array("success" => false, "message"=> "Error."));
        die();
    }
}

$fullname = $_POST['fuilname'];
$email = $_POST['email'];
$contact = $_POST['contact'];
$password = $_POST['password'];
$priv = $_POST['priviledge'];

$fullname =  htmlspecialchars($fullname);
$email =  htmlspecialchars($email);
$contact =  htmlspecialchars($contact);

$fullname = trim($fullname);
$email = trim($email);
$contact = trim($contact);

if($priv == "1"){
    try{
        $sql = "INSERT INTO `faculty`(`ID`,`email`,`password`,`fullname`,`contact`, `profile`) VALUES('$id', '$email','$password','$fullname','$contact', $profile )";
        mysqli_query($conn, $sql);
        $conn->close();
        echo json_encode(array("success" => true));
        die();
    }catch(e){
        echo json_encode(array("success" => false, "message"=> "Unable to connect to server."));
    }
}

if($priv == "2"){
    try{
        $qr = "s-".sha1($id);
        $sql = "INSERT INTO `students`(`ID`,`email`,`password`,`fullname`,`contact`,`QR`,`profile`) VALUES('$id', '$email','$password','$fullname','$contact', '$qr',$profile)";
        mysqli_query($conn, $sql);
        echo json_encode(array("success" => true));
        $conn->close();
        die();
    }catch(e){
        echo json_encode(array("success" => false, "message"=> "Unable to connect to server."));
        die();
    }
}

