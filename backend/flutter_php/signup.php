<?php

include "./_config.php";

include "./_header.php";

$fullname = $_POST['fuilname'];
$email = $_POST['email'];
$contact = $_POST['contact'];
$password = $_POST['password'];
$priv = $_POST['priviledge'];

$fullname =  htmlspecialchars($fullname);
$email =  htmlspecialchars($email);
$contact =  htmlspecialchars($contact);
$password = sha1($password);

$fullname = trim($fullname);
$email = trim($email);
$contact = trim($contact);

if($priv == "1"){
    try{
        $id = uniqid();
        $sql = "INSERT INTO `faculty`(`ID`,`email`,`password`,`fullname`,`contact`) VALUES('$id', '$email','$password','$fullname','$contact')";
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
        $id = uniqid();
        $qr = "s-".sha1($id);
        $sql = "INSERT INTO `students`(`ID`,`email`,`password`,`fullname`,`contact`,`QR`) VALUES('$id', '$email','$password','$fullname','$contact', '$qr')";
        mysqli_query($conn, $sql);
        echo json_encode(array("success" => true));
        $conn->close();
        die();
    }catch(e){
        echo json_encode(array("success" => false, "message"=> "Unable to connect to server."));
        die();
    }
}

