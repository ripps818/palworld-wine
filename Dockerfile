FROM archlinux:multilib-devel

# Install prerequisites
RUN pacman --noconfirm -Syu
RUN pacman --noconfirm -S \
    wine \
    winetricks \
    wine-gecko \
    wine-mono \
    xorg-server-xvfb \
    samba \
    lib32-gnutls \
    gnutls \
    lib32-libxcomposite \
    libxcomposite \
    unzip \
	curl

# Custom Environment Variables
ENV PUID=99 \
	PGID=100 \
	TZ=UTC \
	MULTITHREADING=false \
	PORT= \
	PUBLIC_PORT= \
	PUBLIC_IP= \
	PLAYERS=16 \
	SERVER_NAME= \
	SERVER_DESCRIPTION= \
	SERVER_PASSWORD= \
	ADMIN_PASSWORD= \
	UPDATE_ON_BOOT=true \
	WINETRICKS_ON_BOOT=true \
	RCON_ENABLED=true \
	BACKUP_ENABLED=true \
	OLD_BACKUP_DAYS=30 \
	DELETE_OLD_BACKUPS=false \
	COMMUNITY=

# Install Supercronic
# Latest releases available at https://github.com/aptible/supercronic/releases
ENV SUPERCRONIC_URL=https://github.com/aptible/supercronic/releases/download/v0.2.29/supercronic-linux-amd64 \
    SUPERCRONIC=supercronic-linux-amd64 \
    SUPERCRONIC_SHA1SUM=cd48d45c4b10f3f0bfdd3a57d054cd05ac96812b

RUN curl -fsSLO "$SUPERCRONIC_URL" \
 && echo "${SUPERCRONIC_SHA1SUM}  ${SUPERCRONIC}" | sha1sum -c - \
 && chmod +x "$SUPERCRONIC" \
 && mv "$SUPERCRONIC" "/usr/local/bin/${SUPERCRONIC}" \
 && ln -s "/usr/local/bin/${SUPERCRONIC}" /usr/local/bin/supercronic

# Install Tini
ARG TINI_VERSION=0.19.0
ADD https://github.com/krallin/tini/releases/download/v${TINI_VERSION}/tini /tini
RUN chmod +x /tini

# Install Gosu
ADD https://github.com/tianon/gosu/releases/download/1.9/gosu-amd64 /gosu
RUN chmod +x /gosu

# Setup a Wine prefix
ENV WINEPREFIX=/app/.wine
ENV WINEARCH=win64

# Change Winetricks cache directory
ENV XDG_CACHE_HOME=/app/.cache

# Configure locale for unicode
RUN echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen
ENV LANG=en_US.UTF-8
RUN locale-gen

# Setup Environment
RUN mkdir -p /config
COPY start.sh /
COPY entrypoint.sh /
COPY cronlist /config
COPY backup.sh /config
EXPOSE 8211/udp
EXPOSE 25575
EXPOSE 27015
VOLUME /app
VOLUME /backup
ENV DISPLAY :99

# Setup User/Group
RUN groupadd --gid $PGID pal && \
    useradd --uid $PUID --gid $PGID -M pal

# Run the application
ENTRYPOINT ["/tini","/entrypoint.sh"]
