# install-lemp-stack
L'objectif de ce TP est d'installer une pile LEMP (Linux, Nginx, MariaDB, PHP). Cette configuration permet de déployer des pages web dynamiques ainsi que des applications web développées en PHP.

Les étapes ci-dessous décrivent de manière détaillée l'installation d'une pile LEMP sur un serveur Ubuntu.

1. ### Création d'un nom de domaine

Il est nécessaire de créer un compte sur la plateforme ClouDNS afin de bénéficier d'un service d'hébergement DNS. Cela peut être réalisé en commençant par la création d'une zone DNS gratuite, suivie de l'ajout d'un enregistrement de type A, comme illustré dans les figures 1 et 2.


<p align="center">
<img src="./figures/figure1.png" width=100%>
</p>
<p align="center">
Figure 1: création d’un enregistrement de type A
</p>

La figure 2 illustre l'enregistrement ClouDNS créé, intitulé **serveurnginx.afa.ip-ddns.com**, lequel pointe vers l'adresse IP publique de notre machine virtuelle.

<p align="center">
<img src="./figures/figure2.png" width=100%>
</p>
<p align="center">
Figure 2: illustration des alias de type A et de type NS
</p>

2. ### Installation de Nginx:
L'installation du serveur Nginx s'effectue en exécutant les commandes suivantes :
```
sudo apt update
sudo apt install nginx
```
Pour vérifier son état :
```
sudo systemctl status nginx
```
Voici le résultat de la commande :

<p align="center">
<img src="./figures/figure3.png" width=100%>
</p>
<p align="center">
Figure-3: la sortie de la commande qui affiche l’état du serveur Nginx
</p>

Il est également possible de s'assurer que le serveur affiche correctement la page d’accueil en saisissant l’URL suivante dans la barre d’adresse du navigateur :

<p align="center">
<img src="./figures/figure4.png" width=100%>
</p>
<p align="center">
Figure 4: affichage de la page d’acceuil du serveur Nginx
</p>

_Remarque_ :

Vérifier que l'UFW (Uncomplicated Firewall) est désactivé. 
UFW un outil de configuration pare-feu conçu pour la gestion des règles de filtrage de paquet sur les distributions Debian et Ubuntu.

Voici quelques  commandes UFW:

```
# Check status
sudo ufw status
```
Pour activer et désactiver UFW :
```
# Enable/Disable
sudo ufw enable
sudo ufw disable
```


Nous créons un fichier **_/etc/nginx/conf.d/wordpress.conf_** tout en le configurant 
```
server {                                                             
    listen 80;
    root /var/www/html/wordpress;
    index  index.php index.html index.htm;
    server_name <YOUR_DNS>;
    client_max_body_size 500M;
    location / {
        try_files $uri $uri/ /index.php?$args;
    }
    location = /favicon.ico {
        log_not_found off;
        access_log off;
    }
    location ~* \.(js|css|png|jpg|jpeg|gif|ico)$ {
        expires max;
        log_not_found off;
    }
    location = /robots.txt {
        allow all;
        log_not_found off;
        access_log off;
    }
    location ~ \.php$ {
         include snippets/fastcgi-php.conf;
         fastcgi_pass unix:/var/run/php/php7.4-fpm.sock;
         fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
         include fastcgi_params;
    }
}
```

3. ### Installation de la base de données MariaDB
Pour installer la base de données MariaDB, nous exécutons la commande suivante :

```
sudo apt-get install mariadb-server mariadb-client
```

Cette commande permet d’installer le serveur MariaDB ainsi que l’outil en ligne de commande nécessaire pour se connecter à la base de données et interagir avec elle.

Pour vérifier que le service MariaDB est opérationnel, nous exécutons la commande suivante :

```
sudo systemctl status mariadb
```

Voici le résultat de cette commande :
<p align="center">
<img src="./figures/figure5.png" width=100%>
</p>
<p align="center">
Figure 5: la sortie de la commande qui affiche l’état du service MariaDB
</p>

Il est possible de sécuriser l’installation de la base de données soit de manière interactive, en exécutant le script de sécurisation, soit en exécutant manuellement des instructions SQL pour chaque étape, comme illustré dans le script Bash ci-joint.

Si l'on choisit d’exécuter le script de sécurisation, nous exécutons la commande : 

```
sudo mysql_secure_installation
```

Dans ce cas, l’utilisateur est invité à définir un mot de passe pour l’utilisateur root, à conserver ou supprimer les utilisateurs anonymes, à désactiver ou non l’accès root à distance, ainsi qu’à supprimer la base de données de test.

Pour se connecter à la base de données, nous exécutons la commande : 
```
sudo mariadb -u root -p
```
<p align="center">
<img src="./figures/figure6.png" width=100%>
</p>
<p align="center">
Figure 6: la sortie qui montre la connection à la BD mariadb
</p>


Nous créons la base de données nommée **_afadb_**, ainsi que d'un utilisateur **_afauser_** avec un mot de passe **_afapwd_**, selon les étapes suivantes :

```
create database afabd;
create user ‘afauser’@’localhost’ IDENTIFIED BY 'afapwd’; 
```

Ensuite, nous accordons tous les privilèges, à l’exception de la suppression :

```
grant SELECT, INSERT, UPDATE, CREATE, INDEX, ALTER, CREATE on afadb.* to 'afauser'@'localhost';
```

Une fois la configuration de la base de données terminée, il convient d’exécuter la commande **_exit_** afin de se déconnecter et de revenir à l’invite utilisateur.


4. ### Installation de PHP

Pour installer PHP, nous exécutons la commande suivante :

```
sudo apt install php php-fpm php-curl php-mysql php-gd php-mbstring php-xml php-imagick php-zip php-xmlrpc -y
```
Tester la version installer de PHO avec la commande 

```
php -v
```
Nous devons modifier le fichier de configuration **_/etc/php/7.4/fpm/php.ini_** en modifiant les lignes suivantes :
<p align="center">
<img src="./figures/figure7.png" width=100%>
</p>
<p align="center">
Figure 7: afficher la version de PHP installée
</p>


5. ### Installation de WordPress

Executer les commandes suivantes :

```
cd /var/www/html
```
Télécharger l'application avec la commande :

```
sudo wget https://wordpress.org/latest.tar.gz
```

Décompresser le fichier téléchargé : 

```
sudo tar -zxvf latest.tar.gz
```
Changer le nom du fichier de configuration :

```
sudo mv /var/www/html/wordpress/wp-config-sample.php /var/www/html/wordpress/wp-config.php
```
Modifier les paramètres de la BD en éditant le fichier suivant avec les droits sudo :
```
sudo vim /var/www/html/wordpress/wp-config.php
```

```
define( 'DB_NAME', 'afadb' );
define( 'DB_USER', 'afauser' );
define( 'DB_PASSWORD', 'afapwd' );
define( 'DB_HOST', 'localhost' );
```

6. ### Lancement de la pile LEMP
Pour finir l’installation de Wordpress, nous tapant l’url **_serveurnginx.afa.ip-ddns.com/_** dans la barre d’adresse du navigation


<p align="center">
<img src="./figures/figure8.png" width=100%>
</p>
<p align="center">
Figure 8: La première page de configuration de WordPress
</p>


<p align="center">
<img src="./figures/figure9.png" width=100%>
</p>
<p align="center">
Figure 9: Page à remplir pour finit la configuration
</p>



<p align="center">
<img src="./figures/figure10.png" width=100%>
</p>
<p align="center">
Figure 10: Page de la fin de configuration
</p>

<p align="center">
<img src="./figures/figure11.png" width=100%>
</p>
<p align="center">
Figure 11: page d'acceuil de WordPress
</p>

7. ### Sécurisation du site

Pour activer le protocol https sur notre site, nous devons installer sur notre systeme le client **_Certbot_** de **_Let's Encrypt_**:

```
sudo apt-get install python3-certbot-nginx -y
```
En suite, nous éxecutons la commande : 
```
sudo certbot --nginx -d serveurnginx.afa.ip-ddns.com
```

Malheuresement, un message d'erreur s'est affiché 

<p align="center">
<img src="./figures/figure12.png" width=100%>
</p>
<p align="center">
Figure 12: lMessage de dépassement du nombre de certificats généré par jour 
</p>


<p align="center">
<img src="./figures/figure13.png" width=100%>
</p>
<p align="center">
Figure 13: la sortie qui montre la connection à la BD mariadb
</p>


<p align="center">
<img src="./figures/figure14.png" width=100%>
</p>
<p align="center">
Figure 14: la sortie qui montre la connection à la BD mariadb
</p>


<p align="center">
<img src="./figures/figure15.png" width=100%>
</p>
<p align="center">
Figure 15: la sortie qui montre la connection à la BD mariadb
</p>


