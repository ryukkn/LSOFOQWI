<?php

include "./_config.php";

include "./_header.php";

$email = $_POST['email'];
$password = $_POST['password'];
$login_priv = $_POST['priviledge'];

$email =  htmlspecialchars($email);
$password =  htmlspecialchars($password);
$login_priv = htmlspecialchars($login_priv);
$password = sha1($password);

if($login_priv == "0"){
    echo json_encode(array("success" => false, "message"=> "Please select account type."));
    $conn->close();
    die();
}

if($login_priv == "2"){
    $sql = "SELECT `ID`, email, `password` FROM `admin` WHERE email = '$email' AND password = '$password'";

    $result = mysqli_query($conn, $sql);
    $conn->close();
    if (mysqli_num_rows($result) > 0) {
        $row = mysqli_fetch_assoc($result);
        // session_start();
        // $_SESSION['ID'] = $row['ID'];
        echo json_encode(array("success" => true, "USERID" => $row['ID']));
        
    }else{
        echo json_encode(array("success" => false, "message"=> "Invalid credentials, login failed.."));
    }
}

if($login_priv == "1"){
    $sql = "SELECT * FROM faculty WHERE email = '$email' AND password = '$password'";

    $result = mysqli_query($conn, $sql);
    $conn->close();
    if (mysqli_num_rows($result) > 0) {
        $row = mysqli_fetch_assoc($result);
        // session_start();
        // $_SESSION['ID'] = $row['ID'];
        echo json_encode(array("success" => true, "row" => $row));
        
    }else{
        echo json_encode(array("success" => false, "message"=> "Invalid credentials, login failed.."));
    }
}

if($login_priv == "3"){
    $sql = "SELECT * FROM students WHERE email = '$email' AND password = '$password'";

    $result = mysqli_query($conn, $sql);
    $conn->close();
    if (mysqli_num_rows($result) > 0) {
        $row = mysqli_fetch_assoc($result);
        // session_start();
        // $_SESSION['ID'] = $row['ID'];
        echo json_encode(array("success" => true, "row" => $row));
        
    }else{
        echo json_encode(array("success" => false, "message"=> "Invalid credentials, login failed.."));
    }
}