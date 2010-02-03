var synch = "<script type=\"text/javascript\">\n\
var gaJsHost = ((\"https:\" == document.location.protocol) ? \"https://ssl.\" : \"http://www.\");\n\
document.write(unescape(\"%3Cscript src='\" + gaJsHost + \"google-analytics.com/ga.js' type='text/javascript'%3E%3C/script%3E\"));\n\
</script>\n\
<script type=\"text/javascrip\">\n\
try {\n\
var pageTracker = _gat._getTracker(\"__UserAccount__\");\n\
pageTracker._trackPageview();\n\
} catch(err) {}</script>"

var asynch = "<script type=\"text/javascript\">\n\
\n\
var _gaq = _gaq || [];\n\
_gaq.push(['_setAccount', '__UserAccount__']);\n\
_gaq.push(['_trackPageview']\n\
\n\
(function() {\n\
var ga = document.createElement('script'); ga.type = 'text/javascript'; ga.async = true;\n\
ga.src = ('https:' == document.location.protocol ? 'https://ssl' : 'http://www') + '.google-analytics.com/ga.js';\n\
(document.getElementsByTagName('head')[0] || document.getElementsByTagName('body')[0]).appendChild(ga);})();\n\
\n\
</script>"

function trackingCodeSynchronous() {
    var o = document.getElementById("system_tracking_code");
    o.value = synch;
}

function trackingCodeAsynchronous() {
    var p = document.getElementById("system_tracking_code");
    p.value = asynch;
}