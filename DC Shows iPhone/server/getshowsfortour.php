<?php
    require_once('../../dbconnpdo.php');
    $sql = "SELECT a.id, city_state_country, DATE_FORMAT(show_date, '%b %d') as showdate, attended, poster FROM ds_shows a INNER JOIN ds_locations b ON a.location_id = b.id WHERE YEAR(show_date) = ? ORDER BY show_date";
    $stmt = $db->prepare($sql);
    $stmt->execute(array($_REQUEST["year"]));
    $rows = $stmt->fetchAll(PDO::FETCH_ASSOC);
    echo json_encode($rows);
?>