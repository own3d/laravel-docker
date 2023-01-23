# Laravel Docker

![](own3d-laravel-docker.png)

This Docker Image is currently used for our latest projects based on PHP. For security issues please contact
support@own3d.tv.

## Images

Here is our official list of images currently under development. Not all images are suitable for production, here are
the ones that are maintained:

| Tag                  | Supported | Description          | Active Support Until |
|----------------------|-----------|----------------------|----------------------|
| `8.1-fpm-minimal`    | 👷        | Testing              | 8 Dec 2024           |
| `8.1-octane-minimal` | 👷        | Testing              | 8 Dec 2024           |
| `8.1-fpm-minimal`    | ✅         | Ready for Production | 25 Nov 2023          |
| `8.1-octane-minimal` | ✅         | Ready for Production | 25 Nov 2023          |
| `8.0-octane-minimal` | ❌         | Security fixes only  | 26 Nov 2022          |
| `8.0-octane`         | ❌         | Security fixes only  | 26 Nov 2022          |
| `8.0-octane-develop` | ❌         | Security fixes only  | 26 Nov 2022          |
| `8.0-fpm`            | ❌         | Security fixes only  | 26 Nov 2022          |
| `8.0-fpm-develop`    | ❌         | Security fixes only  | 26 Nov 2022          |
| `7.4-fpm`            | ❌         | End of life          | 28 Nov 2021          |
| `7.4-fpm-develop`    | ❌         | End of life          | 28 Nov 2021          |

> All images that are not listed here will be deleted.

## Concepts

### Default Working Directory

For web projects the default working directory is `/var/www/html`. This applies to all `own3d/laravel-docker` images.

## Usage of Octane Minimal

Our new octane-minimal image is our latest image that is ready for production.
Which comes with a decrease of 37.89% in image size (with a total of 572MB instead of 921MB).
It is based on the latest version of PHP 8.1 and has the following php extensions:

```
bcmath curl date gd imagick exif fileinfo hash PDO sockets 
json mbstring pdo_mysql pdo_sqlite sqlite3 zip pcntl redis
swoole posix mongodb
```

The following dockerfile show the usage of the `own3d/laravel-docker:8.1-octane-minimal` image. Per default, it uses the
command `php artisan octane:start --host 0.0.0.0` to start the application and expose the application on port 8000.

```dockerfile
FROM own3d/laravel-docker:8.1-octane-minimal

# copy all your project files to the /var/www/html folder
COPY . /var/www/html
```

## Usage of PHP-FPM

The following dockerfile show the usage of the `own3d/laravel-docker:8.1-fpm-minimal` image. Per default, it uses
supervisor to start the application and expose the application on port 8000.

```dockerfile
FROM own3d/laravel-docker:8.1-fpm-minimal

# copy all your project files to the /var/www/html folder
COPY . /var/www/html

# update permissions for all project files
RUN chown -R www-data:www-data /var/www/html
RUN chmod -R ug+rwx storage bootstrap/cache
```
