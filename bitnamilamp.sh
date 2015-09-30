#!/bin/bash
#
# Bitnami LAMP
# http://cixtor.com/
# https://github.com/cixtor/mamutools
# https://en.wikipedia.org/wiki/LAMP_(software_bundle)
# https://bitnami.com/stack/lamp
#
# LAMP is an archetypal model of web service solution stacks, named as an
# acronym of the names of its original four open-source components: the Linux
# operating system, the Apache HTTP Server, the MySQL relational database
# management system (RDBMS), and the PHP programming language. The LAMP
# components are largely interchangeable and not limited to the original
# selection. As a solution stack, LAMP is suitable for building dynamic web
# sites and web applications.
#
# Bitnami LAMP Stack provides a complete, fully-integrated and ready to run LAMP
# development environment. In addition to PHP, MySQL and Apache, it includes
# FastCGI, OpenSSL, phpMyAdmin, ModSecurity, SQLite, Varnish, ImageMagick,
# xDebug, Xcache, OpenLDAP, ModSecurity, Memcache, OAuth, PEAR, PECL, APC, GD,
# cURL and other components
#

base="/opt/devstack"

function out() {
	echo "   $1"
}

function ok() {
	echo -e " \e[0;92m\u2714\e[0m $1"
}

function err() {
	echo -e " \e[0;91m\u2718\e[0m $1"
}

function info() {
	echo -e "\n\x20\e[0;94m\u2022\e[0m $1"
}

function isInstalled() {
	if [[ -e "$base" ]]; then
		files=$(ls -1 "$base" | wc -l)
		if [[ "$files" -gt 0 ]]; then
			return 0
		fi
	fi
	return 1
}

function fixApacheConfiguration() {
	fpath="${base}/apache2/conf/httpd.conf"
	temp_fpath="/tmp/httpd.conf"
	info "Modify apache configuration"
	cp "$fpath" "$temp_fpath" 2> /dev/null

	ok "Change apache daemon information: User"
	sed -i "s/^User .*/User $USER/g" "$temp_fpath"

	ok "Change apache daemon information: Group"
	sed -i "s/^Group .*/Group $USER/g" "$temp_fpath"

	ok "Change server admin email"
	sed -i "s/^ServerAdmin .*/ServerAdmin noreply@example.com/g" "$temp_fpath"

	ok "Change server name association"
	sed -i "s/^ServerName .*/ServerName 127.0.0.1/g" "$temp_fpath"

	ok "Deactivate pagespeed module"
	sed -i "s;^Include conf/pagespeed;#Include conf/pagespeed;g" "$temp_fpath"

	ok "Turn server signature off"
	sed -i "s/ServerSignature .*/ServerSignature Off/g" "$temp_fpath"

	ok "Turn server tokens to production"
	sed -i "s/ServerTokens .*/ServerTokens Prod/g" "$temp_fpath"

	ok "Turn HTTP trace method off"
	sed -i "s/TraceEnable .*/TraceEnable Off/g" "$temp_fpath"

	vhosts="${HOME}/projects/virtualhosts.conf"
	if [[ -e "$vhosts" ]]; then
		ok "Adding custom virtual hosts"
		grep -q "virtualhosts\.conf" "$temp_fpath"
		if [[ "$?" -eq 1 ]]; then
			echo "Include \"$vhosts\"" 1>> "$temp_fpath"
		fi
	fi

	mv "$temp_fpath" "$fpath" 2> /dev/null
	ok "Finished apache configuration"
}

function fixApacheHttpPort() {
	info "Change HTTP port number"
	files=(
		"apache2/conf/bitnami/bitnami.conf"
		"apache2/conf/httpd.conf"
		"apache2/scripts/ctl.sh"
		"apps/heroku/conf/httpd-vhosts.conf"
		"apps/phpmyadmin/conf/httpd-vhosts.conf"
		"docs/demo/conf/httpd-vhosts.conf"
		"properties.ini"
		"varnish/etc/varnish/default.vcl"
	)

	for file in "${files[@]}"; do
		fpath="${base}/${file}"
		sed -i 's/8080/80/g' "$fpath"
		grep -q "8080" "$fpath"

		if [[ "$?" -eq 0 ]]; then
			err "$fpath"
		else
			ok "$fpath"
		fi
	done
}

function fixApacheHttpsPort() {
	info "Change HTTPS port number"
	files=(
		"apache2/conf/bitnami/bitnami.conf"
		"apache2/conf/extra/httpd-ssl.conf"
		"apps/heroku/conf/httpd-vhosts.conf"
		"apps/phpmyadmin/conf/httpd-vhosts.conf"
		"properties.ini"
	)

	for file in "${files[@]}"; do
		fpath="${base}/${file}"
		sed -i 's/8443/443/g' "$fpath"
		grep -q "8443" "$fpath"

		if [[ "$?" -eq 0 ]]; then
			err "$fpath"
		else
			ok "$fpath"
		fi
	done
}

function fixBootstrapScript() {
	fpath="${base}/ctlscript.sh"
	temp_fpath="/tmp/ctlscript.sh"
	info "Bootstrap script Root restriction"
	fline=$(head -n20 "$fpath" | grep -n "exit 1")

	if [[ "$?" -eq 0 ]]; then
		fline=$(echo "$fline" | cut -d: -f1)
		header=$(( $fline - 1 ))
		footer=$(( $fline + 1 ))

		head -n"$header" "$fpath" 1> $temp_fpath
		echo "    # exit 1" 1>> $temp_fpath
		tail -n"+$footer" "$fpath" 1>> $temp_fpath
		mv "$temp_fpath" "$fpath" 2> /dev/null
		chmod 755 "$fpath" 2> /dev/null

		ok "Root restriction was removed"
	else
		err "Root restriction does not exists"
	fi
}

function changeDocumentRoot() {
	info "Change document root"
	projects="${HOME}/projects"
	htdocs="${base}/apache2/htdocs"
	file "$htdocs" | grep -q 'symbolic link'

	if [[ "$?" -eq 0 ]]; then
		ok "Projects folder is already linked to htdocs"
	elif [[ -e "$projects" ]]; then
		rm -rf "$htdocs" 2> /dev/null
		ln -s "$projects" "$htdocs"
		file "$htdocs" | grep -q 'symbolic link'

		if [[ "$?" -eq 0 ]]; then
			ok "Projects folder linked to htdocs"
		else
			err "Original htdocs folder was not removed"
		fi
	else
		err "${projects} does not exists"
	fi
}

function fixPhpConfiguration() {
	fpath="${base}/php/etc/php.ini"
	temp_fpath="/tmp/php.ini"
	info "Modify PHP configuration"
	cp "$fpath" "$temp_fpath" 2> /dev/null

	ok "Turn PHP exposure and flags off"
	sed -i "s/^expose_php.*/expose_php = Off/g" "$temp_fpath"

	ok "Turn PHP error reporting to E_ALL"
	sed -i "s/^error_reporting.*/error_reporting = E_ALL/g" "$temp_fpath"

	ok "Turn PHP error displaying on"
	sed -i "s/^display_errors.*/display_errors = On/g" "$temp_fpath"

	ok "Turn PHP HTML error messages on"
	sed -i "s/^html_errors.*/html_errors = On/g" "$temp_fpath"

	mv "$temp_fpath" "$fpath" 2> /dev/null
	ok "Finished PHP configuration"
}
