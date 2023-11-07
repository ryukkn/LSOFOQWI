<?php

include "./_config.php";

include "./_header.php";


$priv = $_POST['priv'];


$sql = "SELECT * FROM `pending` WHERE account = '$priv'";

try{
    $result = mysqli_query($conn, $sql);
    while($row = mysqli_fetch_assoc($result)){
        $id = uniqid();
        $profile = NULL;
        try{
            $pendingID = $row['ID'];
            $sql = "DELETE FROM `pending` WHERE ID = '$pendingID'";
            mysqli_query($conn, $sql);
            $profile = "'upload/".sha1($pendingID).".jpg'";
        }catch(e){
            echo json_encode(array("success" => false, "message"=> "Error."));
            die();
        }

        $fullname = $row['fullname'];
        $email = $row['email'];
        $contact = $row['contact'];
        $password = $row['password'];

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
            }catch(e){
                echo json_encode(array("success" => false, "message"=> "Unable to connect to server."));
            }
        }
        
        if($priv == "2"){
            try{
                $qr = "s-".sha1($id);
                $sql = "INSERT INTO `students`(`ID`,`email`,`password`,`fullname`,`contact`,`QR`,`profile`) VALUES('$id', '$email','$password','$fullname','$contact', '$qr',$profile)";
                mysqli_query($conn, $sql);
            }catch(e){
                echo json_encode(array("success" => false, "message"=> "Unable to connect to server."));
                die();
            }
        }
    }
    echo json_encode(array("success" => true));
    die();
}catch(e){
    echo json_encode(array("success" => false, "message" => "Connection Failed"));
    die();
}