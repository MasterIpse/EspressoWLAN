<?php
$title = $_GET["title"];
$msg = $_GET["msg"];
shell_exec("curl -u PUSHBULLET-TOKEN: https://api.pushbullet.com/v2/pushes -d channel_tag="CHANNEL-NAME" -d type=note -d title=\"".$title."\" -d body$
?>

