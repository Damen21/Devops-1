# Devops-1
Devops 1.naloga

V `Vagrantfile` se nahaja deklaracija VM, kjer si dodelimo 4Gb rama in 2CPU jedra, hkrati pa nastavimo še provision shell na `bootstrap.sh` .

V `bootstrap.sh` pa se nahaja kar nekaj zanimivih vrstic.

najprej pa **Hiter povzetek**

- **Skript zagona:** skripta se izvaja z `bash` (prva vrstica `#!/usr/bin/env bash`) in ima `set -e`, kar pomeni, da se skripta ustavi ob prvi napaki.
- **Posodobitev paketnih indeksov:** `apt-get update` osveži lokalni seznam paketov iz repozitorijev.
- **Namestitve orodij:** namesti se `git`, `docker.io`, `wget`, `sudo` in `curl`.
- **Docker konfiguracija:** `systemctl enable/start docker` zažene in omogoči docker servis; `usermod -aG docker vagrant` doda uporabnika `vagrant` v skupino `docker`.
- **.NET SDK 8:** doda se Microsoftov repozitorij in namesti `dotnet-sdk-8.0`.
- **EF orodja:** namesti se globalno orodje `dotnet-ef` za uporabnika `vagrant` in se doda pot do orodij v `/home/vagrant/.bashrc`.
- **Kloniranje repozitorija:** skripta klonira `DevopsProj` v `/home/vagrant`, če mapo še ni.
- **SQL Server (Docker):** odstrani morebiten stari kontejner `mssql2022` in zažene nov SQL Server 2022 kontejner z vnaprej nastavljenim geslom in izpostavljenim portom 1433.
- **Migracije in build:** skripta počaka, popravi povezavo v `appsettings.json`, požene EF migracije in zgradi projekt z `dotnet build`.
- **Systemd service:** ustvari `predobro.service`, ki zažene aplikacijo (`dotnet run`) na portu `5203`, nato ga omogoči in zažene.
- **Terminalni brskalnik:** namesti `links2` in doda ukaz v `.bashrc`, da ob SSH prijavi v terminalu avtomatično odpre aplikacijo na `http://localhost:5203`.

