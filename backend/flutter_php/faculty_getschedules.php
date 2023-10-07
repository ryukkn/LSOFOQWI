<?php

include "./_config.php";

include "./_header.php";

$id = $_POST['id'];

$sql = "SELECT schedules.*, courses.course, levels.level,blocks.block, laboratories.laboratory, laboratories.department, BlockID
 FROM schedules, blocks, levels,courses,laboratories
 WHERE FacultyID = '$id' AND blocks.ID = schedules.BlockID AND laboratories.ID = schedules.LabID 
AND blocks.LevelID = levels.ID AND levels.CourseID = courses.ID ORDER BY day, time 
 
 ";

try{
    $result  = mysqli_query($conn, $sql);
    $rows = [];
    while($row = mysqli_fetch_assoc($result)){
        $startTime =  date("h:i a", strtotime( explode(" - ", $row['time'])[0]));
        $endTime =  date("h:i a", strtotime( explode(" - ", $row['time'])[1]));
        $row['time'] = strtoupper("$startTime - $endTime");
        array_push($rows, $row);
    }
    $conn->close();
    echo json_encode(array("success" => true, "rows" => $rows));
    die();
}catch(e){
    echo json_encode(array("success" => false, "message" => "Connection Failed"));
    die();
}