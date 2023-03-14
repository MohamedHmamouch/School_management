# idara

Une version étendue de blog basique construit dans le
`tutoriel`_ Flask.

.. _tutorial: https://flask.palletsprojects.com/tutorial/


## Configuration de la base de données

On suppose que Python3 et PostgreSQL sont déjà installés et
fonctionnels.

Créer l'utilisateur `idaraadmin` dans PostgreSQL (fournir le mot de
passe `idaraadminpass`) :

    % sudo su - postgres -c "createuser --pwprompt idaraadmin"

Créer la base `idara` appartenant à `idaraadmin` dans PostgresSQL:

    % sudo su - postgres -c "createdb --owner idaraadmin idara"

Créer les tables de la base (dans la base `idara`) :

    % psql "postgresql://idaraadmin:idaraadminpass@localhost:5432/idara" < idara/schema-postgresql.sql

Créer la base de test `idaratest` appartenant à `idaraadmin` dans PostgresSQL:

    % sudo su - postgres -c "createdb --owner idaraadmin idaratest"

Créer et peupler les tables de la base de test (dans la base `idaratest`) :

    % psql "postgresql://idaraadmin:idaraadminpass@localhost:5432/idaratest" < idara/schema-postgresql.sql
    % psql "postgresql://idaraadmin:idaraadminpass@localhost:5432/idaratest" < idara/populate.sql


## Création de l'environnement virtuel Python

Créer un l'environnement virtuel Python `venv-flaskpg` et l'activer
(ATTENTION à bien utiliser `virtualenv` et non pas `python -m venv`
sinon le script wsgi ne fonctionnera pas):

    % virtualenv venv-idara
    % source venv-idara/bin/activate

Installer idara en mode éditable :

    (venv-idara) % pip install -e .

Tester l'accès à la base depuis flask:

    (venv-idara) % IDARA_SETTINGS=development.py flask check-db

(si tout se passe bien, cette commande n'affiche rien)


## Pour tout redémarrer de zéro

Désactiver l'environnement virtuel:

    (venv-idara) % deactivate

Supprimer l'environnement virtuel:

    % rm -r venv-idara

Effacer les bases de données:

    % sudo su - postgres -c "dropdb idara"
    % sudo su - postgres -c "dropdb idaratest"

Supprimer l'utilisateur 'idaraadmin':

    % sudo su - postgres -c "dropuser idaraadmin"



## Développement

### Développement en direct (via le mini-serveur Web intégré)

Pour lancer le serveur de test et tester l'application:

    (venv-idara) % IDARA_SETTINGS=development.py flask --debug run

Puis se connecter à l'URL indiqué.

Attention: ces conditions de tests ne garantissent pas un fonctionnement
sous Apache puisque l'URL de l'application est toujours à la racine du
mini-serveur.


### Développement (et installation) sous Apache.

On suppose que Apache est déjà installé et qu'il existe un site web
(sans doute dans un VIRTUAL_HOST) actif.

Installer et activer le module Apache 'mod_wsgi' (sous Debian/Ubuntu):

    % sudo apt install libapache2-mod-wsgi-py3

En supposant que l'application est dans `/home/username/idara`
(l'utilisateur propriétaire s'appelle donc `username`) et que l'URL
d'accès à l'application doit être `/idara` dans le site
web... ajouter les lignes suivantes dans la configuration du VirtualHost
d'un site existant (par exemple dans
`/etc/apache2/sites-available/001-mon-site.conf`) en remplaçant les
valeurs génériques (`username`, `idara` et `/home/username/`) par les
valeurs spécifiques:

    #------------------------------------------------------------
    # application Python idara
    #------------------------------------------------------------
    WSGIDaemonProcess idara user=username group=username threads=5
    WSGIScriptAlias /idara "/home/username/idara/wsgi/idara.wsgi"

    <Directory "/home/username/idara/wsgi/">
        <Files "idara.wsgi">
            WSGIProcessGroup idara
            WSGIApplicationGroup %{GLOBAL}
            Require all granted
        </Files>
    </Directory>

Redémarrer Apache pour prendre en compte cette nouvelle configuration:

    % sudo service apache2 restart

Pour que Apache recharge l'application (pour prendre en compte les
modifications de code):

    % touch /home/username/idara/wsgi/idara.wsgi

Les éventuels messages d'erreur de l'application sont dans le fichier
log d'erreur du site web:

    % tail -f /var/log/apache2/mon-site-error.log

On peut combiner les deux :

    % touch /home/username/idara/wsgi/idara.wsgi && tail -f /var/log/apache2/mon-site-error.log

### Pour effectuer les tests

Le code des tests est dans le sous-répertoire `tests` (et la
configuration utilisée est `TestingConfig` dans le fichier
`instance/configuration.py`).

Si ce n'est déjà fait, il faut installer les dépendances spécifiques
pout les tests:

    (venv-idara) % pip install -e '.[test]'
	
Pour effectuer tous les tests:

    (venv-idara) % IDARA_SETTINGS=test.py pytest
	
Pour effectuer tous les tests avec le résultat de chaque test:

    (venv-idara) % IDARA_SETTINGS=test.py pytest -v
	
Pour effectuer tous les tests avec le résultat de chaque test et les
affichages:

    (venv-idara) % IDARA_SETTINGS=test.py pytest -v -rA

Pour effectuer un test particulier (par exemple, ici,
`tests/test_idara.py::test_05_remove_new_user`) avec son résultat et
les affichages associés:

    (venv-idara) % IDARA_SETTINGS=test.py  pytest -v -rA tests/test_idara.py::test_05_remove_new_user

Pour mesurer le taux de couverture des tests, il faut tout d'abord créer
le fichier de mesures:

    (venv-idara) % IDARA_SETTINGS=test.py coverage run -m pytest

Puis demander à voir le rapport (en mode texte):

    (venv-idara) % IDARA_SETTINGS=test.py coverage report

(Le taux de couverture actuel est assez faible.)

Pour voir la couverture fichier par fichier (et même ligne par ligne):

    (venv-idara) % IDARA_SETTINGS=test.py coverage html

puis ouvrir le fichier `htmlcov/index.html` dans un navigateur.
	

## Configuration de l'application

L'application utilise deux variables d'environnement: `FLASK_APP` et
`IDARA_SETTINGS`.

La 1re variable d'environnement (`FLASK_APP`) est définie dans le
fichier `.flaskenv`. Sa valeur est utilisée par flask pour nommer
l'application (ici, le nom de l'application est `idara`).

La 2e variable d'environnement (`IDARA_SETTINGS`) est définie à
chaque lancement via la ligne de commande. Elle permet de définir le nom
du fichier de configuration à aller chercher dans le répertoire
`instance/`. Dans ce répertoire, à ce jour, il n'y a que les fichiers
`development.py` et `test.py`. Mais on pourrait en créer d'autres
(`production.py` par exemple). Seuls les objets dont le nom est en
majuscules sont récupérés depuis le fichier de configuration et sont
ensuite utilisables par l'application (via `app.config`).

Pour l'utilisation via Apache, c'est dans le fichier `wsgi/idara.wsgi`
que sont définies les deux variables d'environnement (`FLASK_APP` et
`IDARA_SETTINGS`).





