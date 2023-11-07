<?php 

include "./_config.php";

include "./_header.php";

if(isset($_POST["image"])){
    $base64_string = $_POST["image"];
    $id = sha1($_POST["id"]);
    $outputfile = "upload/".$id.".jpg" ;

    $filehandler = fopen($outputfile, 'wb' ); 
    
    fwrite($filehandler, base64_decode($base64_string));

    fclose($filehandler); 

 
    $accountType = $_POST['account'];
    $accountID = $_POST['id'];
        

    if($accountType == "Faculty"){
        $sql = "UPDATE faculty SET profile='$outputfile' WHERE ID ='$accountID'";
    }else{
        $sql = "UPDATE students SET profile='$outputfile' WHERE ID ='$accountID'";
    }

    mysqli_query($conn, $sql);
    
    echo(json_encode(array("success"=>true, "profile"=>$outputfile)));
}else{
   echo(json_encode(array("success"=>false, "message" => "Upload Failed")));
}


