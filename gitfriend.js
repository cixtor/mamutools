#!/usr/bin/env phantomjs
var account;
var category;
var pagenum = 1;
var system = require('system');
var page = require('webpage').create();

if (system.args.length) {
    var parts;

    for (var x in system.args) {
        if (system.args.hasOwnProperty(x)) {
            parts = system.args[x].match(/\-(u|g|p)=(\S+)/)

            if (parts !== null) {
                if (parts[1] === 'u') {
                    account = parts[2];
                } else if (parts[1] === 'g') {
                    category = parts[2];
                } else if (parts[1] === 'p') {
                    var number = parseInt(parts[2]);
                    pagenum = isNaN(number) ? 1 : number;
                }
            }
        }
    }
}

if (!account) {
    console.log('GitHub Befriend.JS');
    console.log('  http://cixtor.com/');
    console.log('  https://github.com/cixtor/mamutools');
    console.log('  https://en.wikipedia.org/wiki/PhantomJS');
    console.log('  https://en.wikipedia.org/wiki/Headless_browser');
    console.log('Usage:');
    console.log('  -u username Account to use for the operation');
    console.log('  -g group    Either following or followers');
    console.log('  -p page     Optional page number');
    phantom.exit(1);
}

var fullurl = 'https://github.com/' + account + '/' + category;

if (pagenum > 1) {
    fullurl += '?page=2';
}

console.log('Target: ' + fullurl);

page.settings.userAgent = 'Mozilla/5.0 (KHTML, like Gecko) Safari/537.36';

page.onConsoleMessage = function (message) {
    console.log('CONSOLE: ' + message);
};

page.open(fullurl, function () {
    page.evaluate(function () {
        var label;
        var nonce;
        var button;
        var username;
        var counter = 0;
        var buttons = document.querySelectorAll('.follow button');
        var tokens = document.querySelectorAll('.follow input[name=authenticity_token]');

        var httpRequest = function (counter, username, nonce) {
            var xmlhttp = new XMLHttpRequest();

            xmlhttp.onreadystatechange = function () {
                if (xmlhttp.readyState === XMLHttpRequest.DONE) {
                    if (xmlhttp.status === 200) {
                        console.log('[' + counter + '] Following ' + username + ' -> OK' + xmlhttp.responseText);
                    } else {
                        console.log('[' + counter + '] {' + xmlhttp.status + '} POST /users/follow?target=' + username + '&authenticity_token=' + nonce);
                    }
                }
            };

            xmlhttp.open('POST', '/users/follow?target=' + username, false);

            xmlhttp.setRequestHeader('Content-Type', 'application/x-www-form-urlencoded; charset=UTF-8');
            xmlhttp.setRequestHeader('X-Requested-With', 'XMLHttpRequest');
            xmlhttp.setRequestHeader('Origin', 'https://github.com');

            xmlhttp.send('authenticity_token=' + encodeURIComponent(nonce));
        };

        for (var key in buttons) {
            if (buttons.hasOwnProperty(key) && typeof buttons[key] === 'object') {
                button = buttons[key];
                nonce = tokens[key] ? tokens[key].value : 'foobar';
                label = button.getAttribute('aria-label');
                counter = (parseInt(key) + 101).toString().substring(1);

                if (label === 'Follow this person') {
                    username = button.getAttribute('title').replace(/Follow\s/, '');

                    httpRequest(counter, username, nonce);
                }
            }
        }
    });

    phantom.exit();
});
