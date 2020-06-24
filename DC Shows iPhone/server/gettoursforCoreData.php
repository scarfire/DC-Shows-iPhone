<?php
    require_once('../../dbconnpdo.php');
    $sql = "select year, poster from ds_tours where last_updated > ? order by year";
    $stmt = $db->prepare($sql);
    $stmt->execute(array($_REQUEST["last_updated"]));
    $rows = $stmt->fetchAll(PDO::FETCH_ASSOC);
    echo json_encode($rows);
?>
