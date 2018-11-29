# How to set up Grafana on Clever-Cloud

1. create a new NodeJs application
2. either fork this repo and link it to the application or:
    - create a new repo with a package.json with at least:
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
    - then create both scripts, the install one will build grafana and the start one will start the grafana-server binary
    - in the install script put:
    ```
    #!/bin/bash
    
    go get github.com/grafana/grafana
    cd $GOPATH/src/github.com/grafana/grafana
    go run build.go setup
    go run build.go build
    
    yarn install --pure-lockfile
    yarn dev
    ```
    - this will build both the back-end and the front-end of Grafana.
    - add ```GOPATH=/home/bas/<app_id>/go_home``` in your environment variables where <app_id> is the id of the app on clever-cloud
    - in the start script put:
    ```
    #!/bin/bash

    cd $GOPATH/src/github.com/grafana/grafana
    $GOPATH/bin/grafana-server
    ```
    - finally add ```GF_SERVER_HTTP_PORT=8080``` in your app environment variables to ensure Grafana starts on the correct port and make sure you have enabled a dedicated build instance
    - Grafana is now ready to start however at this point if you restart the app, all data will be lost as it's not persisted in a database

# Persisting Data on a database

For this example we will use mysql however the procedure shouldn't be too different with any other type of database

1. create your database add-on on clever-cloud and link it to the application
2. in your application environment variables you should now see the info you need to connect to your db
3. you now need to link these informations to grafana. to do this you need to create a few environment variables (replace what's in '<>' with the actual value):
    - ```GF_DATABASE_NAME=<MYSQL_ADDON_DB>```
    - ```GF_DATABASE_HOST=<MYSQL_ADDON_HOST>```
    - ```GF_DATABASE_PASSWORD=<MYSQL_ADDON_PASSWORD>```
    - ```GF_DATABASE_URL=<MYSQL_ADDON_URI>```
    - ```GF_DATABASE_USER=<MYSQL_ADDON_USER>```
    - ```GF_DATABASE_TYPE=mysql```
4. for more information on how to change grafana configuration through environment variables please check: http://docs.grafana.org/installation/configuration/
