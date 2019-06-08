server {
        listen 80;
        listen [::]:80;

        root /var/www/example.com/html;
        index index.php index.html index.htm index.nginx-debian.html;

        server_name {{ ansible_default_ipv4.address }};

        location / {
                try_files $uri $uri/ =404;
        }

    location ~ \.php$ {
        include snippets/fastcgi-php.conf;
        fastcgi_pass unix:/run/php/php7.2-fpm.sock;
    }

    location ~ /\.ht {
        deny all;
    }

}
