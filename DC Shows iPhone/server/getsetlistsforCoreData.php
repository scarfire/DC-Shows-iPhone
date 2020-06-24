<?php
    require_once('../../dbconnpdo.php');
    $sql = "SELECT show_id, title, set_number, song_sequence FROM ds_set_lists a INNER JOIN ds_songs b
    ON a.song_id = b.id INNER JOIN ds_shows c on a.show_id = c.id WHERE a.last_updated > ? ORDER BY show_id, song_sequence";
    $stmt = $db->prepare($sql);
    $stmt->execute(array($_REQUEST["last_updated"]));
    $rows = $stmt->fetchAll(PDO::FETCH_ASSOC);
    echo json_encode($rows);
?>
