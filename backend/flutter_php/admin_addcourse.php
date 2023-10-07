<?php

include "./_config.php";

include "./_header.php";

$course = $_POST['course'];
$firstYear = $_POST['firstYear'];
$secondYear = $_POST['secondYear'];
$thirdYear = $_POST['thirdYear'];
$fourthYear = $_POST['fourthYear'];
$fifthYear = $_POST['fifthYear'];

$course = htmlspecialchars($course);
$course = trim($course);

// generate ID
try{
    $sql = "INSERT INTO courses (`course`) VALUES ('$course')";
    mysqli_query($conn, $sql);
    $sql = "SELECT ID FROM courses ORDER BY ID DESC";
    $courseID = mysqli_fetch_assoc(mysqli_query($conn, $sql))['ID'];
    if($firstYear > 0 && $firstYear != ""){
        $sql = "INSERT INTO levels (`level`, `CourseID`) VALUES ('First Year','$courseID')";
        mysqli_query($conn, $sql);
        $sql = "SELECT ID FROM levels ORDER BY ID DESC";
        $levelID = mysqli_fetch_assoc(mysqli_query($conn, $sql))['ID'];
        for($i =0; $i < $firstYear; $i++){
            $block = "Block ".chr(65+$i);
            $sql = "INSERT INTO blocks (`block`,`LevelID`) VALUES ('$block','$levelID')";
            mysqli_query($conn, $sql);
        }
    }
    if($secondYear > 0 && $secondYear != ""){
        $sql = "INSERT INTO levels (`level`, `CourseID`) VALUES ('Second Year','$courseID')";
        mysqli_query($conn, $sql);
        $sql = "SELECT ID FROM levels ORDER BY ID DESC";
        $levelID = mysqli_fetch_assoc(mysqli_query($conn, $sql))['ID'];
        for($i =0; $i < $secondYear; $i++){
            $block = "Block ".chr(65+$i);
            $sql = "INSERT INTO blocks (`block`,`LevelID`) VALUES ('$block','$levelID')";
            mysqli_query($conn, $sql);
        }
    }
    if($thirdYear > 0  && $thirdYear != ""){
        $sql = "INSERT INTO levels (`level`, `CourseID`) VALUES ('Third Year','$courseID')";
        mysqli_query($conn, $sql);
        $sql = "SELECT ID FROM levels ORDER BY ID DESC";
        $levelID = mysqli_fetch_assoc(mysqli_query($conn, $sql))['ID'];
        for($i =0; $i < $thirdYear; $i++){
            $block = "Block ".chr(65+$i);
            $sql = "INSERT INTO blocks (`block`,`LevelID`) VALUES ('$block','$levelID')";
            mysqli_query($conn, $sql);
        }
    }
    if($fourthYear > 0 && $fourthYear != ""){
        $sql = "INSERT INTO levels (`level`, `CourseID`) VALUES ('Fourth Year','$courseID')";
        mysqli_query($conn, $sql);
        $sql = "SELECT ID FROM levels ORDER BY ID DESC";
        $levelID = mysqli_fetch_assoc(mysqli_query($conn, $sql))['ID'];
        for($i =0; $i < $fourthYear; $i++){
            $block = "Block ".chr(65+$i);
            $sql = "INSERT INTO blocks (`block`,`LevelID`) VALUES ('$block','$levelID')";
            mysqli_query($conn, $sql);
        }
    }
    if($fifthYear > 0 && $fifthYear != ""){
        $sql = "INSERT INTO levels (`level`, `CourseID`) VALUES ('Fifth Year','$courseID')";
        mysqli_query($conn, $sql);
        $sql = "SELECT ID FROM levels ORDER BY ID DESC";
        $levelID = mysqli_fetch_assoc(mysqli_query($conn, $sql))['ID'];
        for($i =0; $i < $fifthYear; $i++){
            $block = "Block ".chr(65+$i);
            $sql = "INSERT INTO blocks (`block`,`LevelID`) VALUES ('$block','$levelID')";
            mysqli_query($conn, $sql);
        }
    }
    $conn->close();
    echo json_encode(array("success" => true));
    die();
}catch(e){
    echo json_encode(array("success" => false, "message" => "Connection Failed"));
    die();
}