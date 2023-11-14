<?php

include "./_config.php";

include "./_header.php";

$id = $_POST['id'];

$sql = "SELECT * FROM pending WHERE (`pending`.ID = '$id')";
$sql2 = "UPDATE pending SET `event` = CURRENT_TIMESTAMP() WHERE (`pending`.ID = '$id')";

try{
    try{
        mysqli_query($conn, $sql2);
        $result = mysqli_query($conn, $sql);
    }catch(e){
        echo json_encode(array("verified" => false, "message" => "Connection Failed"));
        die();
    }
    if(mysqli_num_rows($result) <= 0){
        echo json_encode(array("verified" => false, "message" => "Sign up denied by admin."));
        die();
    }
    $row = mysqli_fetch_assoc($result);
    if($row['verified'] == "TRUE"){
        $sql = "DELETE FROM pending WHERE ID = '$id'";
        mysqli_query($conn, $sql);
        echo json_encode(array("verified" => true));
    }else{
        echo json_encode(array("verified" => false, "message" => ""));
    }
    $conn->close();
    die();
}catch(e){
    echo json_encode(array("verified" => false, "message" => "Connection Failed"));
    die();
}

die();