<?php

include "./_config.php";

include "./_header.php";

$email = $_POST['email'];
$email = trim($email);
$email = htmlspecialchars($email);
$password =  $_POST['password'];


try{
    for($i = 0; $i < 2; $i++){
        $table = "faculty";
        switch($i){
            case 0:
                $table = "faculty";
            break;
            case 1:
                $table = "students";
            break;
        }
        $sql = "SELECT * FROM `$table` WHERE (`$table`.email = '$email')";
        mysqli_query($conn, $sql);
        $result = mysqli_query($conn, $sql);
        if(mysqli_num_rows($result) > 0){
            $row = mysqli_fetch_array($result);
            $ID = $row['ID'];
            $password = sha1($password);
            $sql2 = "UPDATE `$table` SET `password` = '$password' WHERE ID = '$ID'";

            mysqli_query($conn, $sql2);
            echo json_encode(array("success" => true));
            die();
        }
    }
    echo json_encode(array("success" => false, "message" => "Does not exist"));
    die();

}catch(e){
    echo json_encode(array("success" => false, "message" => "Unable to connect to the server."));
    die();
}