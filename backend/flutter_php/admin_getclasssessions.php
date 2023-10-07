<?php

include "./_config.php";

include "./_header.php";

$filterbyMonth = "";
$filterbyYear = "";

if(isset($_POST['month'])){
    $month = $_POST['month'];
    if($month != ""){
        $filterbyMonth = "AND MONTH(`TimeIn`) = $month";
    }
}

if(isset($_POST['year'])){
    $year = $_POST['year'];
    if($year != ""){
        $filterbyYear = "AND YEAR(`TimeIn`) = $year";
    }
}

$sql = "SELECT class_sessions.*, courses.course, levels.level, blocks.block,
    laboratories.department, laboratories.laboratory, faculty.fullname , CURRENT_TIMESTAMP() as `currenttime`
    FROM class_sessions, laboratories, faculty, courses, levels, blocks 
    WHERE class_sessions.FacultyID = faculty.ID AND blocks.ID = class_sessions.BlockID  
    AND class_sessions.LabID = laboratories.ID
    AND courses.ID = levels.CourseID AND levels.ID = blocks.LevelID AND `TimeOut` IS NOT NULL $filterbyMonth $filterbyYear ORDER BY `TimeIn` DESC";

try{
    $result = mysqli_query($conn, $sql);
    $rows = [];
    while($row = mysqli_fetch_assoc($result)){
        $datetime1 = strtotime($row['currenttime']);
        $datetime2 = strtotime($row['TimeIn']);
        if(($datetime1-$datetime2) * 86400 < 30 && $filterbyMonth != "" && $filterbyYear !=""){
            break;
        }
        array_push($rows, $row);
    }
    $conn->close();
    echo json_encode(array("success" => true, "rows"=> $rows));
    die();
}catch(e){
    echo json_encode(array("success" => false, "message" => "Connection Failed"));
    die();
}