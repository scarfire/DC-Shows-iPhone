<?php
    require_once('../../dbconnpdo.php');
	$sql = "SELECT id FROM ds_shows WHERE band = 'Dead and Co.' ORDER BY RAND() LIMIT 1";
    $stmt = $db->prepare($sql);
    $stmt->execute();
    $rows = $stmt->fetchAll(PDO::FETCH_ASSOC);
    echo json_encode($rows);
?>