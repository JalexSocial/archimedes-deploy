#!/bin/bash

# Update package list and upgrade all packages
apt update -y

apt install wget nginx certbot python3-certbot-nginx -y

wget https://packages.microsoft.com/config/ubuntu/20.04/packages-microsoft-prod.deb -O packages-microsoft-prod.deb
dpkg -i packages-microsoft-prod.deb
rm packages-microsoft-prod.deb

apt-get update && \
  apt-get install -y dotnet-sdk-6.0
  
apt-get update && \
  apt-get install -y aspnetcore-runtime-6.0

echo "[Unit]" >> "/etc/systemd/system/archimedes.service"
echo "Description=Archimedes" >> "/etc/systemd/system/archimedes.service"
echo "" >> "/etc/systemd/system/archimedes.service"
echo "[Service]" >> "/etc/systemd/system/archimedes.service"
echo "WorkingDirectory=/var/www/archimedes" >> "/etc/systemd/system/archimedes.service"
echo "ExecStart=/usr/bin/dotnet /var/www/archimedes/Archimedes.dll" >> "/etc/systemd/system/archimedes.service"
echo "Restart=always" >> "/etc/systemd/system/archimedes.service"
echo "RestartSec=10" >> "/etc/systemd/system/archimedes.service"
echo "SyslogIdentifier=Archimedes" >> "/etc/systemd/system/archimedes.service"
echo "User=www-data" >> "/etc/systemd/system/archimedes.service"
echo "Environment=ASPNETCORE_ENVIRONMENT=Production" >> "/etc/systemd/system/archimedes.service"
echo "Environment=DOTNET_PRINT_TELEMETRY_MESSAGE=false" >> "/etc/systemd/system/archimedes.service"
echo "Environment=DOPPLER_ACCESS_KEY=" >> "/etc/systemd/system/archimedes.service"
echo "" >> "/etc/systemd/system/archimedes.service"
echo "[Install]" >> "/etc/systemd/system/archimedes.service"
echo "WantedBy=multi-user.target" >> "/etc/systemd/system/archimedes.service"

systemctl enable archimedes
systemctl status nginx
systemctl enable nginx

mkdir /var/www/archimedes

echo "server {" >> "/etc/nginx/sites-available/archimedes"
echo "" >> "/etc/nginx/sites-available/archimedes"
echo "        root /var/www/archimedes/;" >> "/etc/nginx/sites-available/archimedes"
echo "" >> "/etc/nginx/sites-available/archimedes"
echo "        server_name archimedes.jalex.io;" >> "/etc/nginx/sites-available/archimedes"
echo "" >> "/etc/nginx/sites-available/archimedes"
echo "        location / {" >> "/etc/nginx/sites-available/archimedes"
echo "                proxy_pass http://localhost:5000;" >> "/etc/nginx/sites-available/archimedes"
echo "                proxy_http_version 1.1;" >> "/etc/nginx/sites-available/archimedes"
echo "                proxy_set_header Upgrade $http_upgrade;" >> "/etc/nginx/sites-available/archimedes"
echo "                proxy_set_header Connection keep-alive;" >> "/etc/nginx/sites-available/archimedes"
echo "                proxy_set_header Host $host;" >> "/etc/nginx/sites-available/archimedes"
echo "                proxy_cache_bypass $http_upgrade;" >> "/etc/nginx/sites-available/archimedes"
echo "                proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;" >> "/etc/nginx/sites-available/archimedes"
echo "                proxy_set_header X-Forwarded-Proto $scheme;" >> "/etc/nginx/sites-available/archimedes"
echo "        }" >> "/etc/nginx/sites-available/archimedes"
echo "" >> "/etc/nginx/sites-available/archimedes"
echo "}" >> "/etc/nginx/sites-available/archimedes"

ln -s /etc/nginx/sites-available/archimedes /etc/nginx/sites-enabled/

chown ubuntu /var/www/archimedes