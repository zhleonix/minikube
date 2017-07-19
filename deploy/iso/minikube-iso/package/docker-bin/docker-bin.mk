################################################################################
#
# docker-bin
#
################################################################################

DOCKER_BIN_VERSION = 1.12.6
DOCKER_BIN_SITE = https://get.docker.com/builds/Linux/x86_64
DOCKER_BIN_SOURCE = docker-$(DOCKER_BIN_VERSION).tgz

define DOCKER_BIN_USERS
	- -1 docker -1 - - - - -
endef

define DOCKER_BIN_INSTALL_TARGET_CMDS
	$(INSTALL) -D -m 0755 \
		$(@D)/docker \
		$(TARGET_DIR)/bin/docker

	$(INSTALL) -D -m 0755 \
		$(@D)/docker-containerd-shim \
		$(TARGET_DIR)/bin/docker-containerd-shim

	$(INSTALL) -D -m 0755 \
		$(@D)/docker-containerd \
		$(TARGET_DIR)/bin/docker-containerd

	$(INSTALL) -D -m 0755 \
		$(@D)/docker-runc \
		$(TARGET_DIR)/bin/docker-runc

	$(INSTALL) -D -m 0755 \
		$(@D)/docker-containerd-ctr \
		$(TARGET_DIR)/bin/docker-containerd-ctr

	$(INSTALL) -D -m 0755 \
		$(@D)/dockerd \
		$(TARGET_DIR)/bin/dockerd

	$(INSTALL) -D -m 0755 \
		$(@D)/docker-proxy \
		$(TARGET_DIR)/bin/docker-proxy
endef

define DOCKER_BIN_INSTALL_INIT_SYSTEMD
	$(INSTALL) -D -m 644 \
		$(BR2_EXTERNAL_MINIKUBE_PATH)/package/docker-bin/docker.service \
		$(TARGET_DIR)/usr/lib/systemd/system/docker.service

	$(INSTALL) -D -m 644 \
		$(BR2_EXTERNAL_MINIKUBE_PATH)/package/docker-bin/docker.socket \
		$(TARGET_DIR)/usr/lib/systemd/system/docker.socket

	ln -fs /usr/lib/systemd/system/docker.service \
		$(TARGET_DIR)/etc/systemd/system/multi-user.target.wants/docker.service
endef

$(eval $(generic-package))
