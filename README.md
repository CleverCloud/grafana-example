# How to set up Grafana on Clever Cloud

1. create a new NodeJs application linked to a fork of this repo
2. in your application environment variables add ```GF_SERVER_HTTP_PORT=8080```, ```GOPATH=/home/bas/<app_id>/go_home``` where <app_id> is the id of your application on clever cloud (found in the top right corner of the console) and ```GRAFANA_VERSION=v6.6.0``` (or any other tag in the official Grafana repo)
3. you can now build and start the application, be aware however that if you restart it your data will not be persisted (see next section to learn how to persist data)

# Persisting Data on a database

For this example we will use mysql however the procedure shouldn't be too different with any other type of database

1. create your database add-on on clever cloud and link it to the application
2. in your application environment variables you should now see the info you need to connect to your db
3. you now need to link these informations to grafana. to do this you need to create a few environment variables (replace what's in '<>' with the actual value):
    - ```GF_DATABASE_NAME=<MYSQL_ADDON_DB>```
    - ```GF_DATABASE_HOST=<MYSQL_ADDON_HOST>```
    - ```GF_DATABASE_PASSWORD=<MYSQL_ADDON_PASSWORD>```
    - ```GF_DATABASE_URL=<MYSQL_ADDON_URI>```
    - ```GF_DATABASE_USER=<MYSQL_ADDON_USER>```
    - ```GF_DATABASE_TYPE=mysql```
4. for more information on how to change grafana configuration through environment variables please check: http://docs.grafana.org/installation/configuration/

# How it works

1. create a new repo with a package.json with at least:
    ```
    {
      "name" : "<name-of-your-app>",
      "version" : "<version>",
      "scripts" : {
          "install" : "./build.sh",
          "start" : "./run.sh"
      },
      "engines": {
          "node" : "^10"
      }
    }
    ```
2. then create both scripts, the install one will build grafana and the start one will start the grafana-server binary
3. in the install script put:
    ```
    #!/bin/bash
    
    go get github.com/grafana/grafana
    cd $GOPATH/src/github.com/grafana/grafana
    go run build.go setup
    go run build.go build
    
    yarn install --pure-lockfile
    yarn dev
    ```
4. this will build both the back-end and the front-end of Grafana.
5. add ```GOPATH=/home/bas/<app_id>/go_home``` in your environment variables where <app_id> is the id of the app on clever-cloud
6. in the start script put:
    ```
    #!/bin/bash

    cd $GOPATH/src/github.com/grafana/grafana
    $GOPATH/bin/grafana-server
    ```
7. finally add ```GF_SERVER_HTTP_PORT=8080``` in your app environment variables to ensure Grafana starts on the correct port and **make sure you have enabled a dedicated build instance**
8. Grafana is now ready to start however at this point if you restart the app, all data will be lost as it's not persisted in a database


# Adding new plugins to Grafana

For this example we will be adding warp10 as a plugin to Grafana
1. in your build script, add the following lines:
    ```
    mkdir -p data/plugins
    cd data/plugins

    git clone https://github.com/ovh/ovh-warp10-datasource.git
    ```
    this will ensure the plugins directory is created and the plugins are correctly downloaded inside
3. restart your application, you should now see warp10 available as a plugin
