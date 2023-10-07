<?php

include "./_config.php";

include "./_header.php";

$id = $_POST['id'];
$accountType = $_POST['accountType'];
$email = $_POST['email'];
$fullname = $_POST['fullname'];
$contact = $_POST['contact'];
$password = $_POST['password'];
$password = sha1($password);
$profilePic = "NULL";

if(isset($_POST['image'])){
    $image = $_POST['image'];
    if($image != "NULL"){
        $base64_string = $_POST["image"];
        $profile = sha1($_POST["id"]);
        $outputfile = "upload/".$profile.".jpg" ;

        $profilePic = "'upload/".$profile.".jpg'";

        $filehandler = fopen($outputfile, 'wb' ); 
        
        fwrite($filehandler, base64_decode($base64_string));

        fclose($filehandler); 
    }
}

$email = htmlspecialchars($email);
$fullname = htmlspecialchars($fullname);
$contact = htmlspecialchars($contact);

$email = trim($email);
$fullname = trim($fullname);
$contact = trim($contact);

// validation 
if($accountType == "0"){
    echo json_encode(array("success" => false, "message"=> "Please select account type."));
    $conn->close();
    die();
}

if($accountType == "1"){
    $sql = "SELECT * FROM faculty WHERE email = '$email'";
    $result = mysqli_query($conn, $sql);
    if (mysqli_num_rows($result) > 0) {
        $conn->close();
        echo json_encode(array("success" => false, "message" => "Email already exists."));
        die();
    }
}

if($accountType == "2"){
    $sql = "SELECT * FROM students WHERE email = '$email'";
    $result = mysqli_query($conn, $sql);
    if (mysqli_num_rows($result) > 0) {
        $conn->close();
        echo json_encode(array("success" => false, "message" => "Email already exists."));
        die();
    }
}

// generate ID


$sql = "INSERT INTO pending (`ID`,`email`, `password`, `fullname`, `contact`, `account`, `profile`) 
    VALUES ('$id', '$email', '$password', '$fullname', '$contact', '$accountType', $profilePic)";

try{
    mysqli_query($conn, $sql);
    $conn->close();
    echo json_encode(array("success" => true));
    die();
}catch(e){
    echo json_encode(array("success" => false, "message" => "Connection Failed"));
    die();
}