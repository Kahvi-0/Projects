<?php
$data .= "\n\n==================================\n\n";
$data .=  "<br></br><br>Client IP Address: " . $_SERVER['REMOTE_ADDR'] . "\n</br>";
$data .= file_get_contents('php://input');
$data .= "==================================\n\n";
file_put_contents('/var/www/html/fp/fp.html', print_r($data, true), FILE_APPEND | LOCK_EX);
?>
