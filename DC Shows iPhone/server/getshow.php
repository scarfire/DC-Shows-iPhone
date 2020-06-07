<?php
    require_once('../../dbconnpdo.php');
    $sql = "SELECT a.id, city_state_country, building, show_date, DATE_FORMAT(show_date, '%b %d, %Y') as showdate, audio, poster FROM ds_shows a INNER JOIN ds_locations b ON a.location_id = b.id WHERE a.id = ?";
    $stmt = $db->prepare($sql);
    $stmt->execute(array($_REQUEST["show_id"]));
    $rows = $stmt->fetchAll(PDO::FETCH_ASSOC);
    echo json_encode($rows);
?>
