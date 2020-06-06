<?php
    require_once('../../dbconnpdo.php');
	$sql = "SELECT id FROM ds_shows WHERE band = 'Dead and Co.' and show_date < ? ORDER BY show_date DESC LIMIT 1";
    $stmt = $db->prepare($sql);
    $stmt->execute(array($_REQUEST["show_date"]));
    $rows = $stmt->fetchAll(PDO::FETCH_ASSOC);
    echo json_encode($rows);
?>