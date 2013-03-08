#!/usr/bin/env php
<?php
// Display useful information about a list of files if they are images.
//
function _valid_type($filepath=''){
	if( file_exists($filepath) AND strpos($filepath, '.')!==FALSE ){
		if(in_array(
			array_pop( explode('.', $filepath) ),
			array('jpg', 'jpeg', 'gif', 'png', 'bmp')
		)){
			return(TRUE);
		}
	}
	return(FALSE);
}
function most_large($list=array()){
	$max_length = 0;
	foreach($list as $i=>$element){
		if( $i>0 ){
			$element_length = strlen($element);
			$max_length = $element_length>$max_length ? $element_length : $max_length;
		}
	}
	return $max_length;
}
function strpad_fill($length=0){
	$fill = '';
	for($i=0; $i<$length; $i++){ $fill.=chr(32); }
	return $fill;
}
$list = $argv;
if( count($list)<=1 ){
	echo "Usage: imageinfo image_file_path.{jpg,gif,png}\n";
	exit;
}
$strpad_req = count($list)>2 ? TRUE : FALSE;
$strpad_max = most_large($list);
foreach($list as $i=>$filepath){
	if($i>0){
		if( $image_info = @getimagesize($filepath) ){
			if($strpad_req){
				echo str_pad($filepath, $strpad_max, chr(32), STR_PAD_RIGHT);
			}else{ echo $filepath; }
			echo ' = ';
			//
			$image_info['mime'] = str_pad($image_info['mime'], 10, chr(32), STR_PAD_RIGHT);
			echo "\033[0;96m{$image_info['mime']}\033[0m";
			if( isset($image_info['bits']) ){
				echo " with \033[0;93m{$image_info['bits']} bits\033[0m";
			}
			if( isset($image_info[0]) AND isset($image_info[1]) ){
				echo " and size: \033[0;92m{$image_info[0]}x{$image_info[1]}\033[0m";
			}
			echo "\n";
		}else{
			echo "\033[0;91mError.\033[0m This file isn't an image: \033[0;91m{$filepath}\033[0m\n";
		}
	}
}
// End_of_file