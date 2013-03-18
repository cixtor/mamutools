#!/usr/bin/env php
<?php
/**
 * Image Information
 * http://www.cixtor.com/
 * https://github.com/cixtor/mamutools
 * http://php.net/manual/en/function.getimagesize.php
 *
 * The getimagesize() function will determine the size of any given image file
 * and return the dimensions along with the file type and a height/width text
 * string to be used inside a normal HTML IMG tag and the correspondant HTTP
 * content type.
 *
 * Exchangeable image file format (Exif, often incorrectly EXIF) is a standard
 * that specifies the formats for images, sound, and ancillary tags used by
 * digital cameras (including smartphones), scanners and other systems handling
 * image and sound files recorded by digital cameras. The specification uses the
 * following existing file formats with the addition of specific metadata tags:
 * JPEG Discrete cosine transform (DCT) for compressed image files, TIFF Rev.
 * 6.0 (RGB or YCbCr) for uncompressed image files, and RIFF WAV for audio files
 * (Linear PCM or ITU-T G.711 μ-Law PCM for uncompressed audio data, and IMA-ADPCM
 * for compressed audio data). It is not supported in JPEG 2000, PNG, or GIF.
 */
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
    $this_filename = basename(__FILE__);
    echo "Image Information\n";
    echo "  http://www.cixtor.com/\n";
    echo "  https://github.com/cixtor/mamutools\n";
    echo "  http://php.net/manual/en/function.getimagesize.php\n";
    echo "\n";
    echo "Usage: {$this_filename} image_file_path.{jpg,gif,png}\n";
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
/* EOF */