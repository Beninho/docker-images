{{ $DOCUMENT_ROOT := default .Env.DOCUMENT_ROOT "/var/www/symfony/web" }}
{{ $APACHE_LOG_DIR := default .Env.APACHE_LOG_DIR "/var/log/apache2" }}
{{ $APACHE_LOG_PREFIX := default .Env.APACHE_LOG_PREFIX "symfony" }}
{{ $PHP_CONTAINER_NAME := default .Env.PHP_CONTAINER_NAME "php" }}

LoadModule deflate_module modules/mod_deflate.so
LoadModule rewrite_module modules/mod_rewrite.so
LoadModule expires_module modules/mod_expires.so
LoadModule proxy_module modules/mod_proxy.so
LoadModule proxy_fcgi_module modules/mod_proxy_fcgi.so

<VirtualHost *:80>
    UseCanonicalName Off

    RewriteEngine on
    RewriteCond {{ $DOCUMENT_ROOT }}/%{REQUEST_FILENAME} -f
    RewriteRule ^/(.*\.php(/.*)?)$ fcgi://{{ $PHP_CONTAINER_NAME }}:9000{{ $DOCUMENT_ROOT }}/$1 [L,P]

    DocumentRoot {{ $DOCUMENT_ROOT }}
    <Directory {{ $DOCUMENT_ROOT }}>
        DirectoryIndex index.html index.php

        Options FollowSymlinks
        AllowOverride All
        Require all granted
    </Directory>

    ErrorLog {{ $APACHE_LOG_DIR }}/{{ $APACHE_LOG_PREFIX }}_error.log
    LogFormat "%h %l %u %t \"%r\" %>s %b \"%{Referer}i\" \"%{User-agent}i\"" combined
    CustomLog {{ $APACHE_LOG_DIR }}/{{ $APACHE_LOG_PREFIX }}_access.log combined
</VirtualHost>
