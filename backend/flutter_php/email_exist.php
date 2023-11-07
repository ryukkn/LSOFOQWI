<?php

include "./_config.php";

include "./_header.php";

$email = $_POST['email'];
$email = trim($email);
$email = htmlspecialchars($email);


try{
    for($i = 0; $i < 2; $i++){
        switch($i){
            case 0:
                $sql = "SELECT * FROM `faculty` WHERE (`faculty`.email = '$email')";
            break;
            case 1:
                $sql = "SELECT * FROM `students` WHERE (`students`.email = '$email')";
            break;
        }
        mysqli_query($conn, $sql);
        $result = mysqli_query($conn, $sql);
        if(mysqli_num_rows($result) > 0){
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