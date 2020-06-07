<?php
    require_once('../../dbconnpdo.php');
    $sql = "SELECT a.id, title, set_number FROM ds_set_lists a INNER JOIN ds_songs b
    ON a.song_id = b.id INNER JOIN ds_shows c on a.show_id = c.id WHERE a.show_id = ? ORDER BY id";
    $stmt = $db->prepare($sql);
    $stmt->execute(array($_REQUEST["show_id"]));
    $rows = $stmt->fetchAll(PDO::FETCH_ASSOC);
    echo json_encode($rows);
?>
