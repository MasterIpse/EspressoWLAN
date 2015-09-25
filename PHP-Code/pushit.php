<?php

require 'vendor/autoload.php';
$title = $_GET["title"];
$msg = $_GET["msg"];
echo $title;
echo $msg;
$pb = new Pushbullet\Pushbullet('API-Token');
$pb->allDevices()->pushNote($title, $msg);

?>
