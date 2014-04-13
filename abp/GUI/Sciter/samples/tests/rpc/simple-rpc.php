<?php 
  $method = $_POST["method"];
  if(!$method)
  {
    // reprot error:  
    header ("Content-type:text/plain");
    echo "No method name given!"; 
    exit;
  }

  require "php2json.php";
  
  $res = "";
  
  switch( $method ) 
  {
    case "add": 
      $res = (int)$_POST["p0"] + (int)$_POST["p1"];
      break;
    case "sub": 
      $res = (int)$_POST["p0"] - (int)$_POST["p1"];
      break;
  }
  
  // report result:  
  header ("Content-type:application/json");
  echo php2json( $res );
?>


