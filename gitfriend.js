#!/usr/bin/env phantomjs
var account;
var category;
var pagenum = 1;
var system = require('system');

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
