<html>
<head>
<style>
img { vertical-align:middle; margin:4px; }  
var { color: purple; }
</style>
</head>
<body>

<% include "samples/included.tis"; %>

Items below were generated using environment object - namespace passed to the script from caller.

Test of utf-8 inclusion: <% =foo %>. 

<% for(var p in params) { %>
  <p><img src="diamond.png">Generated item <var><% =p %></var></p>
<% } %>  

<p>Here is a result of someFunc() : <var><% =someFunc() %></var></p>
It was passed by caller in environment object.

<% /* report result to the caller if needed */
   result = "Done!"; %>

</body>
</html>