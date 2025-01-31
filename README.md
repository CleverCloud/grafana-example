# How to set up Grafana on Clever Cloud

1. Fork this repository and get your github url.
2. Create a [Node.js application](https://www.clever-cloud.com/developers/doc/applications/javascript/nodejs/). It will download and run Grafana using the root package.json file. The install script build.sh will download grafana and its plugins and the start one run.sh will start the grafana-server binary.

```bash
ID=$(clever create --type php --github nickname/grafana-example --org YOUR_ORG --format json grafana | jq -r '.id')
```

3. Add ```GRAFANA_VERSION``` and ```GRAFANA_SHA_256``` environment variables. You can find these values on the [Grafana download page](https://grafana.com/grafana/download).

```bash
clever env --app $ID set GRAFANA_VERSION 11.5.0
clever env --app $ID set GRAFANA_SHA_256 535f60a4a06fa5f34a974d8f0d7f26b79e67e17fcf16dca2ed379147d0d2a059
```

4. In your application environment variables add needed env var for run.

```bash
clever env --app $ID set GF_SERVER_HTTP_PORT 8080
clever env --app $ID set GF_SERVER_ROOT_URL YOU_URL
```

5. Check Node.js version used in `package.json`, for instance Grafana 11.5.0 expects Node.js 22 (see Grafana's [package.json](https://github.com/grafana/grafana/blob/v11.5.0/package.json#L446)).

6. To install custom Grafana plugin, you can set them directly in `GRAFANA_PLUGINS` environnement variable split by a `,`, for example with the value: `plugin,other_one:0.0.2,https://github.com/ovh/ovh-warp10-datasource.git`. It will install the latest version of `plugin`, the version `0.0.2` of `second_one` using the grafana-cli commands. And for the `ovh-warp10-datasource` plugin, `git clone` is used instead, as it's done for any plugin starting by `http`.
7. Add `GF_PLUGIN_DIR` environnement variable with `./data/plugins` to use local cloned plugins.

```bash
clever env --app $ID set GRAFANA_PLUGINS plugin
clever env --app $ID set GF_PLUGIN_DIR ./data/plugins
```

8. You can now build and start the Clever Cloud application, be aware however that if you restart it your data will not be persisted (see next section to learn how to persist data).
9. To configure Grafana through environment variables please check [grafana configuration page](https://grafana.com/docs/grafana/latest/setup-grafana/configure-grafana/).

# Persisting Data on a database

For this example we will use mysql however the procedure shouldn't be too different with any other type of database as PostgreSQL.

1. Create your database add-on on Clever Cloud and link it to the application, you can check our [documentation](https://www.clever-cloud.com/doc/getting-started/quickstart/#create-your-first-add-on).
2. As best practice it's recommended to create and use read only user
3. In your application environment variables you should now see the information you need to connect to your database.
4. Link your add-on to your Grafana application. To do this you need to create a few environment variables (replace what's in '<>' with the actual value):
    - ```GF_DATABASE_NAME=<MYSQL_ADDON_DB>```
    - ```GF_DATABASE_HOST=<MYSQL_ADDON_HOST>```
    - ```GF_DATABASE_PASSWORD=<MYSQL_ADDON_PASSWORD>```
    - ```GF_DATABASE_USER=<MYSQL_ADDON_USER>```
    - ```GF_DATABASE_TYPE=mysql```