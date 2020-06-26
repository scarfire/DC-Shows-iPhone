<?php
    require_once('../../dbconnpdo.php');
    $sql = "SELECT show_id, a.id, title, set_number FROM ds_set_lists a INNER JOIN ds_songs b
    ON a.song_id = b.id INNER JOIN ds_shows c on a.show_id = c.id WHERE a.last_updated > ? ORDER BY show_id, id";
    $stmt = $db->prepare($sql);
    $stmt->execute(array($_REQUEST["last_updated"]));
    $rows = $stmt->fetchAll(PDO::FETCH_ASSOC);
    echo json_encode($rows);
?>
