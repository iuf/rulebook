<script language="javascript">
function update() {
  var xhr = new XMLHttpRequest(), self = this;
  xhr.open('GET', '../rulebook-latex-scripts/hook.php', true);
  xhr.onload = function (e) {
	  if (xhr.readyState === 4) {
		  location.reload();
	  }
  };
  xhr.send();
}
</script>

<?php

$show = '/(^latex-build-log$)|(.+\.pdf)/';
echo "<table border=1>";
echo "<tr><th>filename</th><th>modified</th><th>size</th></tr>";
$dir = dir("../../rulebook-latex/out");
while (false !== ($file = $dir->read())) {
   if( preg_match($show,$file) ) {
     echo "<tr><td><a href=\"../rulebook-latex-out/$file\">$file</a></td>".
     "<td>".date("F d Y H:i:s.", filemtime($dir->path."/".$file))."</td>".
     "<td align=\"right\">".intval(filesize($dir->path."/".$file)/1024)."k</td></tr>\n";
   }
}
$dir->close();
echo "</table>";

?>

<br />
<input type="button" value="update" onClick="update();this.value = 'working...';this.disabled=true;" />

<?php
echo "<pre>\n\nlast 5 commits:\n\n";
echo `cd ../../rulebook-latex; git log -n 5`."</pre>";
?>
