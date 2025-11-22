#!/usr/bin/env bash
set -e

echo ">>> Updating system"
apt-get update -y

echo ">>> Installing Docker + Git + Utils"
apt-get install -y git docker.io wget sudo curl

systemctl enable docker
systemctl start docker
usermod -aG docker vagrant

echo ">>> Installing .NET SDK 8"
wget https://packages.microsoft.com/config/ubuntu/22.04/packages-microsoft-prod.deb -O packages-microsoft-prod.deb
dpkg -i packages-microsoft-prod.deb
apt-get update
apt-get install -y dotnet-sdk-8.0

echo ">>> Installing EF tools"
sudo -u vagrant dotnet tool install --global dotnet-ef --version 8.0.10

echo 'export PATH="$PATH:/home/vagrant/.dotnet/tools"' >> /home/vagrant/.bashrc

echo ">>> Cloning DevopsProj repo"
cd /home/vagrant
if [ ! -d DevopsProj ]; then
  sudo -u vagrant git clone https://github.com/Damen21/DevopsProj.git
fi

echo ">>> Starting SQL Server 2022"
docker rm -f mssql2022 || true

docker run -e "ACCEPT_EULA=Y" \
  -e "SA_PASSWORD=YourStrong!Passw0rd" \
  -p 1433:1433 \
  --name mssql2022 \
  -d mcr.microsoft.com/mssql/server:2022-latest

echo ">>> Waiting for SQL Server to start..."
sleep 25

echo ">>> Patching appsettings.json with correct password"
sed -i 's/Password=.*/Password=YourStrong!Passw0rd;TrustServerCertificate=true"/' \
  /home/vagrant/DevopsProj/Predobro/appsettings.json

echo ">>> Running EF migrations"
cd /home/vagrant/DevopsProj/Predobro
sudo -u vagrant /home/vagrant/.dotnet/tools/dotnet-ef database update

echo ">>> Building project"
sudo -u vagrant dotnet build -c Release
echo ">>> Creating predobro.service"
cat <<EOF > /etc/systemd/system/predobro.service
[Unit]
Description=Predobro .NET App
After=network.target docker.service

[Service]
WorkingDirectory=/home/vagrant/DevopsProj/Predobro
ExecStart=/usr/bin/dotnet run --urls "http://0.0.0.0:5203"
Restart=always
RestartSec=5
User=vagrant
Environment=ASPNETCORE_ENVIRONMENT=Development

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable predobro
systemctl start predobro

echo ">>> Installing terminal browser links2"
apt-get install -y links2

echo ">>> Auto-start links2 on SSH login"
echo '
if [ -z "$SSH_TTY" ]; then
  return
fi
echo "Opening Predobro website inside terminal..."
sleep 1
links2 http://localhost:5203
' >> /home/vagrant/.bashrc

echo ">>> DONE!"