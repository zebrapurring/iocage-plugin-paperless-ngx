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
