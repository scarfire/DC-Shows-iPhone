<?php
    require_once('../../dbconnpdo.php');
    $sql = "select a.id as show_id, show_date as date_show, DATE_FORMAT(show_date, '%b %d, %Y') as date_printed, YEAR(show_date) as year, city_state_country, building, COALESCE(audio, '') as default_audio, poster from ds_shows a inner join ds_locations b on a.location_id = b.id where band is not null and a.last_updated > ? ORDER BY show_date asc";
    $stmt = $db->prepare($sql);
    $stmt->execute(array($_REQUEST["last_updated"]));
    $rows = $stmt->fetchAll(PDO::FETCH_ASSOC);
    echo json_encode($rows);
?>
