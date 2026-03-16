# Grafana Example Application on Clever Cloud
[![Clever Cloud - PaaS](https://img.shields.io/badge/Clever%20Cloud-PaaS-orange)](https://clever-cloud.com)

This example shows how to deploy [Grafana](https://grafana.com/) on Clever Cloud using the [Linux native runtime](https://www.clever.cloud/developers/doc/applications/linux/) and [Mise](https://mise.jdx.dev/) task runner.

## About the Application

Grafana is an open-source analytics and monitoring platform. This example deploys Grafana OSS on Clever Cloud using the Linux native runtime, which runs the official Grafana binary directly — no Docker or Node.js wrapper needed.

The `mise.toml` file defines two tasks:

- **build**: Downloads and extracts the Grafana binary, then installs any configured plugins
- **run**: Starts the Grafana server

## Prerequisites

- A [Clever Cloud account](https://console.clever-cloud.com/)
- [Clever Tools CLI](https://www.clever-cloud.com/developers/doc/clever-tools/getting_started/) installed

## Deploying on Clever Cloud

You have two options to deploy your application on Clever Cloud: using the Web Console or using the Clever Tools CLI.

### Option 1: Deploy using the Web Console

#### 1. Create an account on Clever Cloud

If you don't already have an account, go to the [Clever Cloud console](https://console.clever-cloud.com/) and follow the registration instructions.

#### 2. Set up your application on Clever Cloud

1. Log in to the [Clever Cloud console](https://console.clever-cloud.com/)
2. Click on "Create" and select "An application"
3. Choose **Linux** as the runtime environment
4. Configure your application settings (name, region, etc.). We recommend at least a **Medium** instance size for Grafana

#### 3. Configure Environment Variables

In your application's settings, add the following environment variables:

| Variable | Required | Description |
|---|---|---|
| `GRAFANA_VERSION` | Yes | Grafana version (e.g., `12.4.1`). Find versions on the [Grafana download page](https://grafana.com/grafana/download) |
| `GRAFANA_SHA_256` | No | SHA-256 checksum for integrity verification |
| `GF_SERVER_HTTP_PORT` | Yes | Must be set to `8080` |
| `GF_SERVER_ROOT_URL` | Yes | Your application's public URL (e.g., `https://your-app.cleverapps.io`) |
| `GRAFANA_PLUGINS` | No | Comma-separated list of plugins (see [Plugins](#plugins)) |

#### 4. Deploy Your Application

You can deploy your application using Git:

```bash
# Add Clever Cloud as a remote repository
git remote add clever git+ssh://git@push-par-clevercloud-customers.services.clever-cloud.com/app_<your-app-id>.git

# Push your code to deploy
git push clever master
```

### Option 2: Deploy using Clever Tools CLI

#### 1. Install Clever Tools

Install the Clever Tools CLI following the [official documentation](https://www.clever-cloud.com/developers/doc/clever-tools/getting_started/):

```bash
# Using npm
npm install -g clever-tools

# Or using Homebrew (macOS)
brew install clever-tools
```

#### 2. Log in to your Clever Cloud account

```bash
clever login
```

#### 3. Create a new application

```bash
# Initialize the current directory as a Clever Cloud Linux application
# We recommend at least a Medium instance for Grafana
clever create --type linux --flavor M <YOUR_APP_NAME>
```

#### 4. Configure environment variables

```bash
# Required: set Grafana version (check https://grafana.com/grafana/download)
clever env set GRAFANA_VERSION "12.4.1"

# Required: Grafana must listen on port 8080
clever env set GF_SERVER_HTTP_PORT "8080"

# Required: set the public URL so Grafana serves assets correctly
clever env set GF_SERVER_ROOT_URL "https://$(clever domain | tr -d ' ')"

# Optional: set SHA-256 checksum for integrity verification (check again https://grafana.com/grafana/download for the checksum for the Standalone Linux Binaries package)
clever env set GRAFANA_SHA_256 "<sha256-from-download-page>"

# Optional: install plugins (comma-separated)
clever env set GRAFANA_PLUGINS "grafana-clock-panel,grafana-piechart-panel:1.6.4"
```

#### 5. Deploy your application

```bash
clever deploy
```

#### 6. Open your application in a browser

```bash
clever open
```

## Plugins

You can install Grafana plugins by setting the `GRAFANA_PLUGINS` environment variable with a comma-separated list. Three formats are supported:

| Format | Example | Description |
|---|---|---|
| Plugin name | `grafana-clock-panel` | Installs the latest version |
| Plugin name with version | `grafana-piechart-panel:1.6.4` | Installs a specific version |
| Git URL | `https://github.com/org/plugin.git` | Clones a plugin from a Git repository |

Example with multiple plugins:

```bash
clever env set GRAFANA_PLUGINS "grafana-clock-panel,grafana-piechart-panel:1.6.4,https://github.com/ovh/ovh-warp10-datasource.git"
```

## Persisting Data with a Database

By default, Grafana uses an embedded SQLite database stored on the local filesystem. Since Clever Cloud uses **immutable deployments**, this data is lost every time the application restarts or redeploys. To persist your dashboards, users, and settings, you need to connect an external database.

### 1. Create a PostgreSQL add-on

```bash
clever addon create postgresql-addon <YOUR_ADDON_NAME> --plan xxs_sml --link <YOUR_APP_NAME>
```

This creates a PostgreSQL database and automatically injects connection environment variables (`POSTGRESQL_ADDON_*`) into your application. You can check them with `clever env`.

### 2. Configure Grafana to use PostgreSQL

Use `clever env` to retrieve the database credentials injected by the add-on, and set the corresponding Grafana variables:

```bash
clever env set GF_DATABASE_TYPE "postgres"
clever env set GF_DATABASE_HOST "$(clever env | grep POSTGRESQL_ADDON_HOST | cut -d= -f2 | tr -d '"'):$(clever env | grep POSTGRESQL_ADDON_PORT | cut -d= -f2 | tr -d '"')"
clever env set GF_DATABASE_NAME "$(clever env | grep POSTGRESQL_ADDON_DB | cut -d= -f2 | tr -d '"')"
clever env set GF_DATABASE_USER "$(clever env | grep POSTGRESQL_ADDON_USER | cut -d= -f2 | tr -d '"')"
clever env set GF_DATABASE_PASSWORD "$(clever env | grep POSTGRESQL_ADDON_PASSWORD | cut -d= -f2 | tr -d '"')"
```

### 3. Redeploy

```bash
clever deploy
```

Grafana will automatically create the required tables on first startup. From now on, your dashboards, data sources, users, and settings will persist across restarts and redeployments.

## Grafana Configuration

Beyond the variables listed above, Grafana supports extensive configuration through environment variables using the `GF_<SECTION>_<KEY>` pattern. For example:

```bash
# Set the admin password
clever env set GF_SECURITY_ADMIN_PASSWORD "my-secret-password"

# Enable anonymous access
clever env set GF_AUTH_ANONYMOUS_ENABLED "true"

# Configure SMTP for email alerts
clever env set GF_SMTP_ENABLED "true"
clever env set GF_SMTP_HOST "smtp.example.com:587"
```

Any setting from the Grafana configuration file can be overridden this way. See the [Grafana configuration documentation](https://grafana.com/docs/grafana/latest/administration/configuration/) for all available options.

## Monitoring Your Application

Once deployed, you can monitor your application through:

- **Web Console**: The Clever Cloud console provides logs, metrics, and other tools to help you manage your application.
- **CLI**: Use `clever logs` to view application logs and `clever status` to check the status of your application.

## Additional Resources

- [Grafana Documentation](https://grafana.com/docs/grafana/latest/)
- [Clever Cloud Linux Runtime Documentation](https://www.clever.cloud/developers/doc/applications/linux/)
- [Clever Cloud Documentation](https://www.clever-cloud.com/doc/)
