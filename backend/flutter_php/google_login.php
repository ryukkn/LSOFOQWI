<?php

include "./_config.php";

include "./_header.php";

$email = $_POST['email'];
$login_priv = $_POST['priviledge'];

$email =  htmlspecialchars($email);
$login_priv = htmlspecialchars($login_priv);

// check if pending 
$sql = "SELECT * FROM pending WHERE email = '$email'";
$result = mysqli_query($conn, $sql);

if(mysqli_num_rows($result) > 0){
    $conn->close();
    echo json_encode(array("success" => false, "message"=> "Account is not yet verified."));
}

if($login_priv == "0"){
    echo json_encode(array("success" => false, "message"=> "Please select account type."));
    $conn->close();
    die();
}

if($login_priv == "2"){
    $sql = "SELECT `ID`, email FROM `admin` WHERE email = '$email'";

    $result = mysqli_query($conn, $sql);
    $conn->close();
    if (mysqli_num_rows($result) > 0) {
        $row = mysqli_fetch_assoc($result);
        // session_start();
        // $_SESSION['ID'] = $row['ID'];
        echo json_encode(array("success" => true, "row" => $row));
        
    }else{
        echo json_encode(array("success" => false, "message"=> "Google account not registered."));
    }
}

if($login_priv == "1"){
    $sql = "SELECT * FROM faculty WHERE email = '$email'";

    $result = mysqli_query($conn, $sql);
    $conn->close();
    if (mysqli_num_rows($result) > 0) {
        $row = mysqli_fetch_assoc($result);
        // session_start();
        // $_SESSION['ID'] = $row['ID'];
        echo json_encode(array("success" => true, "row" => $row));
        
    }else{
        echo json_encode(array("success" => false, "message"=> "Google account not registered."));
    }
}

if($login_priv == "3"){
    $sql = "SELECT * FROM students WHERE email = '$email'";

    $result = mysqli_query($conn, $sql);
    $conn->close();
    if (mysqli_num_rows($result) > 0) {
        $row = mysqli_fetch_assoc($result);
        // session_start();
        // $_SESSION['ID'] = $row['ID'];
        echo json_encode(array("success" => true, "row" => $row));
        
    }else{
        echo json_encode(array("success" => false, "message"=> "Google account not registered."));
    }
}