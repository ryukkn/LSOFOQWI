<?php

include "./_config.php";

include "./_header.php";

$id = $_POST['id'];

try{
    
    $sql = "SELECT * FROM students WHERE BlockID = '$id' OR BlockID is NULL";
    $result = mysqli_query($conn, $sql);

    while($row = mysqli_fetch_assoc($result)){
        $student_id = $row['ID'];
        $qr = "s-".sha1(uniqid("", true));
        $sql2 = "UPDATE students SET QR='$qr' WHERE  ID = '$student_id'";
        mysqli_query($conn, $sql2);
    }
    $conn->close();
    echo json_encode(array("success" => true));
    die();
}catch(e){
    echo json_encode(array("success" => false, "message" => "Connection Failed"));
    die();
}