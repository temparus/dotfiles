#!/bin/bash

############################################
##      dotnet installation script        ##
## -------------------------------------- ##
## Author: Sandro Lutz <code@temparus.ch> ##
############################################

# dotnet core required libssl1.0! Does not work with libssl1.1.
emerge -v --oneshot =dev-libs/openssl-1.0.2q-r200

if ! grep -q "dev-lang/mono ~amd64" "/etc/portage/package.accept_keywords"; then
    echo "dev-lang/mono ~amd64" >> /etc/portage/package.accept_keywords
fi
emerge -v --autounmask-continue dev-lang/mono

curl -s https://dot.net/v1/dotnet-install.sh | bash -s --install-dir /opt/dotnet

mkdir -p /opt/dotnet/sdk/NuGetFallbackFolder
chmod 777 /opt/dotnet/sdk/NuGetFallbackFolder

# Add symlink to dotnet executable
ln -s /opt/dotnet/dotnet /usr/local/bin/dotnet
