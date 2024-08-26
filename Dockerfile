FROM yajithd/openvscode-server:1.92.1

ARG TARGETOS
ARG TARGETARCH

EXPOSE 3000
EXPOSE 9443
EXPOSE 9000
EXPOSE 8000

# Set TERM as noninteractive to suppress debconf errors
# RUN echo 'debconf debconf/frontend select Noninteractive' | debconf-set-selections
# ARG DEBIAN_FRONTEND=noninteractive

# Set default go version
ARG GO_VERSION=go1.22.6.${TARGETOS}-${TARGETARCH}

# Install packages
RUN sudo apt-get update && DEBIAN_FRONTEND=noninteractive sudo apt-get install -yq \
    dialog \
    apt-utils \
    curl \
    build-essential \
    git \
    jq \
    wget \
    apt-transport-https \
    ca-certificates \
    gnupg-agent \
    libarchive-tools \
    openssh-client \
    iputils-ping \
    nano \
    software-properties-common \
&& sudo rm -rf /var/lib/apt/lists/*

# Install Docker CLI
RUN curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add - \
   && sudo add-apt-repository \
   "deb [arch=${TARGETARCH}] https://download.docker.com/linux/ubuntu \
   $(lsb_release -cs) \
   stable" \
   && sudo apt-get update \
   && sudo apt-get install -y docker-ce-cli

# Install NodeJS
RUN curl -fsSL https://deb.nodesource.com/setup_18.x | sudo bash - \
    && sudo apt-get install -y nodejs

# Install Yarn
RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | sudo apt-key add - \
	&& echo "deb https://dl.yarnpkg.com/debian/ stable main" | sudo tee /etc/apt/sources.list.d/yarn.list \
	&& sudo apt-get update && apt-get -y install yarn

# Install Golang
RUN cd /tmp \
	&& wget -q https://dl.google.com/go/${GO_VERSION}.tar.gz \
	&& tar -xf ${GO_VERSION}.tar.gz \
	&& sudo mv go /usr/local

# Install golangci-lint
RUN curl -sSfL https://raw.githubusercontent.com/golangci/golangci-lint/master/install.sh | sudo sh -s -- -b /home/yajith/go/bin v1.60.3

# Configuring Golang
ENV PATH="$PATH:/usr/local/go/bin:/home/yajith/go/bin"

# Install VSCode extensions

## Note: The most convenient way to install these would be during image build time 
## via the vscode CLI: https://code.visualstudio.com/docs/editor/extension-marketplace#_command-line-extension-management
## However, it is currently not possible to automate the installation of the extensions this way, 
## see: https://github.com/gitpod-io/openvscode-server/issues/94

## Golang extension ID: golang.Go
RUN EXT_PUBLISHER=golang EXT_PACKAGE=Go && \
    mkdir -pv "/home/workspace/.openvscode-server/extensions/${EXT_PUBLISHER}.${EXT_PACKAGE}" && \
    curl -sSL "https://${EXT_PUBLISHER}.gallery.vsassets.io/_apis/public/gallery/publisher/${EXT_PUBLISHER}/extension/${EXT_PACKAGE}/latest/assetbyname/Microsoft.VisualStudio.Services.VSIXPackage" | bsdtar xvf - --strip-components=1 -C "/home/workspace/.openvscode-server/extensions/${EXT_PUBLISHER}.${EXT_PACKAGE}"

## Docker extension ID: ms-azuretools.vscode-docker	
RUN EXT_PUBLISHER=ms-azuretools EXT_PACKAGE=vscode-docker && \
    mkdir -pv "/home/workspace/.openvscode-server/extensions/${EXT_PUBLISHER}.${EXT_PACKAGE}" && \
    curl -sSL "https://${EXT_PUBLISHER}.gallery.vsassets.io/_apis/public/gallery/publisher/${EXT_PUBLISHER}/extension/${EXT_PACKAGE}/latest/assetbyname/Microsoft.VisualStudio.Services.VSIXPackage" | bsdtar xvf - --strip-components=1 -C "/home/workspace/.openvscode-server/extensions/${EXT_PUBLISHER}.${EXT_PACKAGE}"
