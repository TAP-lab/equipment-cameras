<?php
$uploadDir = './';
$keys = ['1234'];

error_log("$_POST[key]");
if (isset($_POST['key']) && in_array($_POST['key'], $keys)) {
    error_log("Key OK");
    error_log("$_POST[dir]");
    if (isset($_POST['dir'])) {
        error_log("Dir OK");
        $targetDir = $uploadDir . $_POST['dir'] . '/';
        if (!file_exists($targetDir)) {
            mkdir($targetDir, 0777, true);
        }
        $targetFile = $targetDir . 'image.jpg';
        if (isset($_FILES['image'])) {
            if (file_exists($targetFile)) {
                unlink($targetFile);
            }
            move_uploaded_file($_FILES['image']['tmp_name'], $targetFile);
        } 
    }
}
