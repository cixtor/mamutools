#!/usr/bin/env php
<?php
/**
 * Image Information
 * http://cixtor.com/
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

function usage(){
    $this_filename = basename(__FILE__);

    echo "Image Information\n";
    echo "  http://cixtor.com/\n";
    echo "  https://github.com/cixtor/mamutools\n";
    echo "  http://php.net/manual/en/function.getimagesize.php\n";
    echo "Usage:\n";
    echo "  {$this_filename} -help\n";
    echo "  {$this_filename} image.{jpg,gif,png}\n";
    echo "  {$this_filename} image.jpg image.gif image.png\n";
    echo "  {$this_filename} /image/folder/\n";

    exit(0);
}

function _valid_type( $filepath='' ){
    if(
        file_exists($filepath)
        && strpos($filepath, '.') !== FALSE
        && preg_match('/.+\.(jpg|jpeg|gif|png|bmp)$/', $filepath)
    ){
        return TRUE;
    }

    return(FALSE);
}

function most_large( $list=array() ){
    $max_length = 0;

    foreach( (array) $list as $i => $element){
        if( $i > 0 ){
            $element_length = strlen($element);

            if( $element_length > $max_length ){
                $max_length = $element_length;
            }
        }
    }

    return $max_length;
}

function show_image_info( $filepath='', $strpad_req, $strpad_max ){
    if( $image_info = @getimagesize($filepath) ){
        if( $strpad_req ){
            echo str_pad( $filepath, $strpad_max, chr(32), STR_PAD_RIGHT );
        } else {
            echo $filepath;
        }

        $image_info['mime'] = str_pad( $image_info['mime'], 10, chr(32), STR_PAD_RIGHT );
        echo " : \033[0;96m{$image_info['mime']}\033[0m";

        if( isset($image_info['bits']) ){
            echo " with \033[0;93m{$image_info['bits']} bits\033[0m";
        }

        if(
            isset($image_info[0])
            && isset($image_info[1])
        ){
            echo " and \033[0;92m{$image_info[0]}x{$image_info[1]}\033[0m pixels";
        }

        echo "\n";
    } else {
        echo "\033[0;91mError.\033[0m This file is not an image: \033[0;91m{$filepath}\033[0m\n";
    }
}

function process_files( $files=array(), $recursive=TRUE ){
    global $argv;

    $strpad_req = count($files)>2 ? TRUE : FALSE;
    $strpad_max = most_large($files);

    foreach( $files as $i => $filepath ){
        if( $filepath != $argv[0] ){
            if( is_dir($filepath) && $recursive === TRUE ){
                $filepath = rtrim($filepath, '/');
                $files = glob( $filepath . '/*' );
                process_files($files, FALSE);
            } else {
                show_image_info( $filepath, $strpad_req, $strpad_max );
            }
        }
    }
}

if( count($argv) > 1 && $argv[1] != '-help' ){
    process_files($argv);
} else {
    usage();
}
