#!/usr/bin/env php
<?php
/**
 * Gravatar Information Gatherer
 * http://www.cixtor.com/
 * https://github.com/cixtor/mamutools
 *
 * An avatar is an image that represents a person online, basically a little
 * picture that appears next to your name when you interact with websites. A
 * Gravatar is a Globally Recognized Avatar. You upload it and create your
 * profile just once, and then when you participate in any Gravatar-enabled site,
 * your Gravatar image will automatically follow you there.
 *
 * Gravatar is a free service for site owners, developers, and users. It is
 * automatically included in every WordPress account and is run and supported
 * by Automattic.
 */
function get_url($url=''){
    $curl = curl_init();
    curl_setopt($curl, CURLOPT_URL, $url);
    curl_setopt($curl, CURLOPT_RETURNTRANSFER, TRUE);
    curl_setopt($curl, CURLOPT_USERAGENT, 'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.1 (KHTML, like Gecko) Chrome/21.0.1180.81 Safari/537.1');
    $output = curl_exec($curl);
    $headers = curl_getinfo($curl);
    curl_close($curl);
    return array( 'headers'=>$headers, 'content'=>$output );
}
function is_email($address=''){
    $address = htmlspecialchars(trim($address));
    return (bool) preg_match('/^([a-z0-9\+_\-]+)(\.[a-z0-9\+_\-]+)*@([a-z0-9\-]+\.)+[a-z]{2,6}$/ix', $address);
}
function print_array($array=array(), $tabs=0){
    if( is_array($array) ){
        foreach($array as $key=>$value){
            for($i=0;$i<$tabs;$i++){echo "  ";}
            echo "{$key}: ";
            if( is_array($value) ){
                echo "\n";
                print_array($value, $tabs+1);
            }else{
                echo "{$value}\n";
            }
        }
    }else{
        echo "{$array}\n";
    }
}
echo "Gravatar Information Gatherer\n";
echo "  http://www.cixtor.com/\n";
echo "  https://github.com/cixtor/mamutools\n";
echo "\n";
if( isset($argv[1]) ){
    $email = $argv[1];
    echo "Identifier: \033[0;93m{$email}\033[0m\n";
    if( is_email($email) ){
        echo "Identifier is email? \033[0;92mTrue\033[0m\n";
        $gravatar_url = 'https://secure.gravatar.com/'.md5($email).'.php';
    }else{
        echo "Identifier is username? \033[0;92mTrue\033[0m\n";
        $gravatar_url = 'http://en.gravatar.com/'.urlencode($email).'.php';
    }
    $gravatar = get_url($gravatar_url);
    //
    if( $gravatar['headers']['http_code']>0 ){
        $gravatar_data = unserialize($gravatar['content']);
        if( $gravatar['headers']['http_code']==200 ){
            print_array($gravatar_data);
        }else{
            echo "\033[0;91m[x] Error.\033[0m {$gravatar_data}\n";
        }
    }else{
        echo "\033[0;91m[x] Error.\033[0m The remote content couldn't be reached.\n";
    }
}else{
    echo "Usage: ".basename(__FILE__)." username@domain.com\n";
}
/* EOF */