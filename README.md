# iocage-plugin-paperless-ngx

Artifact file(s) for Paperless NGX iocage plugin

After install, the admin username and password are both `admin`.  Please change at first login for security reasons.  The web portal for paperless-ngx will be the jail ip address and port 8000.  More information on paperless-ngx can be found at https://paperless-ngx.readthedocs.io/en/latest/index.html.

## Unofficial plugin installation

```sh
sudo iocage fetch \
    --git_repository https://github.com/zebrapurring/iocage-plugin-index \
    --plugin-name paperless-ngx \
    --name my_paperless_jail
```

## Manual release upgrading

You can upgrade your Paperless-ngx installation manually, if you don't want to perform a full plugin upgrade (make sure to snapshot your jail before upgrading with `iocage snapshot`):

```sh
. /usr/local/etc/paperless/paperless.env

# Archive old release
service paperlesswebserver stop
service paperlessconsumer stop
service paperlessscheduler stop
service paperlesstaskqueue stop
mv "$PAPERLESS_INSTALL_DIR" "${PAPERLESS_INSTALL_DIR}.${PAPERLESS_VERSION}"
mkdir "$PAPERLESS_INSTALL_DIR"

# Update version number in env file
sed -i "" -E "s/^PAPERLESS_VERSION=\".+\"$/PAPERLESS_VERSION=\"v2.16.2\"/" /usr/local/etc/paperless/paperless.env
. /usr/local/etc/paperless/paperless.env

# Download new release
curl -sL "https://github.com/paperless-ngx/paperless-ngx/releases/download/${PAPERLESS_VERSION}/paperless-ngx-${PAPERLESS_VERSION}.tar.xz" | \
    tar -zxf - -C "$PAPERLESS_INSTALL_DIR" --strip-components=1
chown -R paperless:paperless /usr/local/share/paperless

# Install new release and migrate existing data
su paperless -c /tmp/paperless_install

# Start services
service paperlesswebserver start
service paperlessconsumer start
service paperlessscheduler start
service paperlesstaskqueue start
```
