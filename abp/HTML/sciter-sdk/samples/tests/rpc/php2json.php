<?php 

function is_assoc_array($value) 
{ 
  if(!is_array( $value ) ) return false;
  reset($value); 
  return !is_numeric(key($value)); // highly probable that this is associative array
}   

function php2json($value) 
{
		if (is_bool($value)) 		  return ($value) ? "true" : "false";
		elseif (is_int($value))   return "" . $value;
		elseif (is_float($value)) return "" . $value;
		elseif (is_assoc_array($value)) 
    {
			$s = "{"; 
			foreach ($value as $k=>$v) 
				$s .= '"' .$k . '":' . php2json($v) . ',';
			if (count($value)) $s = substr($s, 0, -1);
			return $s . "}";
		} 
		elseif (is_array($value)) 
    {
			$count = count($value) - 1; 
      $s = "[";
			for($i = 0; $i < $count; ++$i) 
        $s .= php2json( $value[$i] ) . ",";
      $s .= php2json( $value[$count] ) . "]";
      return $s;
		} 
		elseif (is_object($value)) 
    {
			$s = "{"; $value = get_object_vars($value);
			foreach ($value as $k=>$v) 
				$s .= '"' .$k . '":' . php2json($v) . ',';
			if (count($value)) $s = substr($s, 0, -1);
			return $s . "}";
		} 
    
		else {
			$esc_val = addcslashes($value, "\r\n\t\"\\"); 
			$s = '"' . $esc_val .'"';
			return $s;
		}
	}

?>