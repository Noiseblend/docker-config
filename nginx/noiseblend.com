server {
    listen 80;
    listen 443 ssl http2;
    listen [::]:443 ssl http2;
    include ssl_params;

    server_name noiseblend.com;
    return 301 https://www.noiseblend.com$request_uri;
}

server {
    listen 80;
    listen [::]:80;

    access_log off;
    error_log stderr;

    server_name *.noiseblend.com;
    return 302 https://$server_name$request_uri;
}

server {
    listen 443 ssl http2;
    listen [::]:443 ssl http2;
    include     ssl_params;

    server_name static.noiseblend.com;

    access_log /dev/stdout;
    error_log stderr;

    root /static;
    location / {

    }
}


server {
    listen 443 ssl http2;
    listen [::]:443 ssl http2;
    include     ssl_params;

    server_name www.noiseblend.com;

    access_log /dev/stdout;
    error_log stderr;

    location ~* \.js\.map$ {
        internal;
    }

    location ~ /(favicon\.ico|robots\.txt|sitemap\.xml)$ {
        root /static/;
        autoindex off;
        expires  14d;
        add_header Cache-Control public;
    }

    location / {
        set $upstream "frontend";
        proxy_pass  http://$upstream:3000;
        include     proxy_params;
        proxy_pass_request_headers      on;
    }
}


server {
    listen 443 ssl http2;
    listen [::]:443 ssl http2;
    include     ssl_params;

    server_name staging.noiseblend.com;

    access_log /dev/stdout;
    error_log stderr;

    location ~* \.js\.map$ {
        internal;
    }

    location ~ /(favicon\.ico|robots\.txt|sitemap\.xml)$ {
        root /static/;
        autoindex off;
        expires  14d;
        add_header Cache-Control public;
    }

    location / {
        set $upstream "frontend-staging";
        proxy_pass  http://$upstream:3000;
        include     proxy_params;
        proxy_pass_request_headers      on;
    }
}


server {
    listen 443 ssl http2;
    listen [::]:443 ssl http2;
    include     ssl_params;

    server_name api.noiseblend.com;

    access_log /dev/stdout;
    error_log stderr;

    location / {
        if ($request_method = 'OPTIONS') {
           add_header 'Access-Control-Allow-Origin' 'https://www.noiseblend.com';
           add_header 'Access-Control-Allow-Methods' 'GET, POST, OPTIONS';
           add_header 'Access-Control-Allow-Headers' 'DNT,User-Agent,X-Requested-With,If-Modified-Since,Cache-Control,Content-Type,Range,Authorization,If-None-Match,Set-Cookie';
           add_header 'Access-Control-Max-Age' 1728000;
           add_header 'Content-Type' 'text/plain; charset=utf-8';
           add_header 'Content-Length' 0;
           return 204;
        }
        if ($request_method = 'POST') {
           add_header 'Access-Control-Allow-Origin' 'https://www.noiseblend.com';
           add_header 'Access-Control-Allow-Methods' 'GET, POST, OPTIONS';
           add_header 'Access-Control-Allow-Headers' 'DNT,User-Agent,X-Requested-With,If-Modified-Since,Cache-Control,Content-Type,Range,Authorization,If-None-Match,Set-Cookie';
           add_header 'Access-Control-Expose-Headers' 'Content-Length,Content-Range';
        }
        if ($request_method = 'GET') {
           add_header 'Access-Control-Allow-Origin' 'https://www.noiseblend.com';
           add_header 'Access-Control-Allow-Methods' 'GET, POST, OPTIONS';
           add_header 'Access-Control-Allow-Headers' 'DNT,User-Agent,X-Requested-With,If-Modified-Since,Cache-Control,Content-Type,Range,Authorization,If-None-Match,Set-Cookie';
           add_header 'Access-Control-Expose-Headers' 'Content-Length,Content-Range';
        }

        set $upstream "api";
        proxy_pass  http://$upstream:9000;
        include     proxy_params;
        proxy_pass_request_headers      on;
    }
}


server {
    listen 443 ssl http2;
    listen [::]:443 ssl http2;
    include     ssl_params;

    server_name staging-api.noiseblend.com;

    access_log /dev/stdout;
    error_log stderr;

    location / {
        if ($request_method = 'OPTIONS') {
           add_header 'Access-Control-Allow-Origin' 'https://staging.noiseblend.com';
           add_header 'Access-Control-Allow-Methods' 'GET, POST, OPTIONS';
           add_header 'Access-Control-Allow-Headers' 'DNT,User-Agent,X-Requested-With,If-Modified-Since,Cache-Control,Content-Type,Range,Authorization,If-None-Match,Set-Cookie';
           add_header 'Access-Control-Max-Age' 1728000;
           add_header 'Content-Type' 'text/plain; charset=utf-8';
           add_header 'Content-Length' 0;
           return 204;
        }
        if ($request_method = 'POST') {
           add_header 'Access-Control-Allow-Origin' 'https://staging.noiseblend.com';
           add_header 'Access-Control-Allow-Methods' 'GET, POST, OPTIONS';
           add_header 'Access-Control-Allow-Headers' 'DNT,User-Agent,X-Requested-With,If-Modified-Since,Cache-Control,Content-Type,Range,Authorization,If-None-Match,Set-Cookie';
           add_header 'Access-Control-Expose-Headers' 'Content-Length,Content-Range';
        }
        if ($request_method = 'GET') {
           add_header 'Access-Control-Allow-Origin' 'https://staging.noiseblend.com';
           add_header 'Access-Control-Allow-Methods' 'GET, POST, OPTIONS';
           add_header 'Access-Control-Allow-Headers' 'DNT,User-Agent,X-Requested-With,If-Modified-Since,Cache-Control,Content-Type,Range,Authorization,If-None-Match,Set-Cookie';
           add_header 'Access-Control-Expose-Headers' 'Content-Length,Content-Range';
        }

        set $upstream "api-staging";
        proxy_pass  http://$upstream:9000;
        include     proxy_params;
        proxy_pass_request_headers      on;
    }
}


server {
    listen 443 ssl http2;
    listen [::]:443 ssl http2;
    include     ssl_params;

    server_name swarmpit.noiseblend.com;

    access_log /dev/stdout;
    error_log stderr;

    location / {
        set $upstream "swarmpit";
        proxy_pass  http://$upstream:8080;
        include     proxy_params;
        proxy_pass_request_headers      on;
    }
}
