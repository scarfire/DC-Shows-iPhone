<?php
    require_once('../../dbconnpdo.php');
    $sql = "SELECT year, poster FROM ds_tours ORDER BY year DESC";
    $stmt = $db->prepare($sql);
    $stmt->execute();
    $rows = $stmt->fetchAll(PDO::FETCH_ASSOC);
    echo json_encode($rows);
?>