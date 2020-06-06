<?php
    require_once('../../dbconnpdo.php');
    $search = "%" . trim($_REQUEST["search"]) . "%";
    $sql = "SELECT a.id, city_state_country, DATE_FORMAT(show_date, '%b %d, %Y') as showdate, poster FROM ds_shows a INNER JOIN ds_locations b ON a.location_id = b.id WHERE band = 'Dead and Co.' and a.id in (SELECT show_id FROM ds_set_lists where song_id IN (SELECT id from ds_songs where title LIKE ?)) ORDER BY show_date";
    $stmt = $db->prepare($sql);
    $stmt->execute(array($search));
    $rows = $stmt->fetchAll(PDO::FETCH_ASSOC);
    echo json_encode($rows);
?>