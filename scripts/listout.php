<?php
$dir = dir(".");
while (false !== ($file = $dir->read())) {
   if( $file != '..' && $file != '.' ) {
     echo "<a href=\"$file\">$file</a><br />\n";
   }
}
$dir->close();
echo "<br /><br />last 5 commits:<br />";
echo "<pre>".`cd ../../rulebook-latex; git log -n 5`."</pre>";
?>
