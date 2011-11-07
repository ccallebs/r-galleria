$(document).ready(function() {
	var cnt = 0;

	$("#add-new-file").click(function() {
		cnt++;
		var append_html = "<p><input type=\"file\" name=\"files[" + cnt + "]\" /></p>";
		$("#add-files").append(append_html);	
	});
});
