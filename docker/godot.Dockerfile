# Headless Godot for checks, tests and every export (Android, web, Windows, macOS, Linux).
# barichello/godot-ci already contains Godot, the export templates and the Android SDK. It is a
# bare Ubuntu image and lacks fontconfig, which Godot loads at startup.
ARG GODOT_VERSION=4.7.2
FROM barichello/godot-ci:${GODOT_VERSION}

RUN apt-get update \
	&& apt-get install -y --no-install-recommends libfontconfig1 zip \
	&& rm -rf /var/lib/apt/lists/*

COPY docker/entrypoint.sh /usr/local/bin/entrypoint.sh
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
CMD ["godot", "--version"]
