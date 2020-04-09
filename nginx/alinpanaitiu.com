server {
    listen 80;

    server_name *.alinpanaitiu.com;
    return 301 https://$host$request_uri;
}

server {
    listen 443 ssl http2;
    listen [::]:443 ssl http2;
    include     alinpanaitiu_ssl_params;

    server_name static.alinpanaitiu.com;

    access_log /dev/stdout;
    error_log stderr;

    root /static/alinpanaitiu;
    autoindex off;
    expires  14d;
    add_header Cache-Control public;

    location / {

    }
}

server {
    listen 443 ssl http2;
    listen [::]:443 ssl http2;
    include     alinpanaitiu_ssl_params;

    server_name grafana.alinpanaitiu.com;

    access_log /dev/stdout;
    error_log stderr;

    auth_basic "Restricted";
    auth_basic_user_file /run/secrets/htpasswd-v0;

    location / {
        set $upstream "grafana";
        proxy_pass  http://$upstream:3006;
        include     proxy_params;
        proxy_pass_request_headers      on;
    }
}
