#!/bin/sh

set -eux

# shellcheck disable=SC1091
. /usr/local/etc/paperless/paperless.env

# Start Redis
sysrc -f /etc/rc.conf redis_enable="YES"
service redis start

# Download release of Paperless-ngx
mkdir -p "$PAPERLESS_INSTALL_DIR"
curl -sL "https://github.com/paperless-ngx/paperless-ngx/releases/download/${PAPERLESS_VERSION}/paperless-ngx-${PAPERLESS_VERSION}.tar.xz" | \
    tar -zxf - -C "$PAPERLESS_INSTALL_DIR" --strip-components=1

# Create paperless headless user
pw user add -n paperless -c "Paperless headless user" -d "$PAPERLESS_INSTALL_DIR" -m -s /bin/sh
chown -R paperless:paperless "$PAPERLESS_INSTALL_DIR"

# Configure Paperless-ngx installation
if [ ! -f "$PAPERLESS_CONFIGURATION_PATH" ]; then
    cp "$PAPERLESS_INSTALL_DIR/paperless.conf" "$PAPERLESS_CONFIGURATION_PATH"
    # Enable consumer polling
    sed -i "" -e "s/#PAPERLESS_CONSUMER_POLLING/PAPERLESS_CONSUMER_POLLING/" "$PAPERLESS_CONFIGURATION_PATH"
    # Enable data dir
    sed -i "" -e "s/#PAPERLESS_DATA_DIR/PAPERLESS_DATA_DIR/" "$PAPERLESS_CONFIGURATION_PATH"
    # Configure NLTK dir
    sed -i "" -e "/PAPERLESS_DATA_DIR/ a\\$(printf "\nPAPERLESS_NLTK_DIR=../data/nltk")" "$PAPERLESS_CONFIGURATION_PATH"
    # Enable media root dir
    sed -i "" -e "s/#PAPERLESS_MEDIA_ROOT/PAPERLESS_MEDIA_ROOT/" "$PAPERLESS_CONFIGURATION_PATH"
    # Enable consumption dir
    sed -i "" -e "s/#PAPERLESS_CONSUMPTION_DIR/PAPERLESS_CONSUMPTION_DIR/" "$PAPERLESS_CONFIGURATION_PATH"
    # Enable Redis connection
    sed -i "" -e "s/#PAPERLESS_REDIS/PAPERLESS_REDIS/" "$PAPERLESS_CONFIGURATION_PATH"
    # Configure SQLite database engine
    sed -i "" -e "/PAPERLESS_REDIS/ a\\$(printf "\nPAPERLESS_DBENGINE=sqlite")" "$PAPERLESS_CONFIGURATION_PATH"
    # Fix path to FreeBSD binaries
    sed -i "" -e "s|^#PAPERLESS_CONVERT_BINARY=.+$|PAPERLESS_CONVERT_BINARY=/usr/local/bin/convert|" "$PAPERLESS_CONFIGURATION_PATH"
    sed -i "" -e "s|^#PAPERLESS_GS_BINARY=.+$|PAPERLESS_GS_BINARY=/usr/local/bin/gs|" "$PAPERLESS_CONFIGURATION_PATH"
fi

# Allow R/W access to PDF files for ImageMagick
sed -i "" -e '/PDF/s/rights="none"/rights="read|write"/' /usr/local/etc/ImageMagick-7/policy.xml

# Execute installation script as user paperless
su paperless -c /tmp/paperless_install

# Build unpaper from source if not installed
if ! unpaper --version > /dev/null 2>&1; then
    portsnap auto > /dev/null
    cd /usr/ports/security/libtasn1
    export ALLOW_UNSUPPORTED_SYSTEM=1
    make deinstall
    make install
    cd -
    rm -rf /usr/ports /var/db/portsnap
fi

# Start Paperless-ngx on boot
sysrc -f /etc/rc.conf paperlessconsumer_enable="YES"
sysrc -f /etc/rc.conf paperlesswebserver_enable="YES"
sysrc -f /etc/rc.conf paperlessscheduler_enable="YES"
sysrc -f /etc/rc.conf paperlesstaskqueue_enable="YES"
service paperlesswebserver start
service paperlessconsumer start
service paperlessscheduler start
service paperlesstaskqueue start

# Write plugin information
echo "The default username and password for this install is admin for both" >> /root/PLUGIN_INFO
