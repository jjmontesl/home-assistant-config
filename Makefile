# Home Assistant Config
# Makefile for config and home assistant deployment 

# This file must be run as root

BASE_DIR:=$(shell pwd)

HASS_GIT=$(BASE_DIR)/../home-assistant
HASS_BRANCH=dev-jhome

INSTALL_HOST=pi@pi
INSTALL_DIR=/srv/home-assistant

BUILD_DIR=$(BASE_DIR)/build

TMPID:=$(shell bash -c "echo $$$$")

VIRTUALENV_ACTIVATE=env/bin/activate

PRIVATE_FILES=secrets.yaml known_devices.yaml

# Default target
.PHONY: default
default:
	$(info Please specify a make target. )

# Clean build
.PHONY: clean
clean:
	$(info Cleaning build. )
	rm -rf $(BUILD_DIR)

# Install webcam cron job and create snapshot directories
.PHONY: install-user
install-user:
	
	adduser homeassistant || true
	adduser homeassistant video || true

# Installs home assistant as service
.PHONY: install-service
install-service:
	
	cp ext/systemd/home-assistant\@homeassistant.service /etc/systemd/system
	systemctl --system daemon-reload

# Install webcam cron job and create snapshot directories
.PHONY: install-webcam
install-webcam:

	# Install cron job 
	cp ext/webcam/webcam /etc/cron.d/
	
	# Make script runnable
	chmod +x ext/webcam/webcam.py
	
	# Create directory for webcam snapshots
	mkdir -p /mnt/tmpfs
	mkdir -p $(INSTALL_DIR)/webcam
	chown homeassistant /mnt/tmpfs
	chown homeassistant -R $(INSTALL_DIR)/webcam

.PHONY: install-homeassistant
install-homeassistant: install-virtualenv

	sudo apt-get --yes --force-yes install nmap fortunes libttspico-utils fswebcam

	cd $(INSTALL_DIR) && . $(VIRTUALENV_ACTIVATE) && cd home-assistant && sudo python3 setup.py clean
	cd $(INSTALL_DIR) && . $(VIRTUALENV_ACTIVATE) && cd home-assistant && sudo python3 setup.py install
	chown -R homeassistant. $(INSTALL_DIR)

.PHONY: install-virtualenv
install-virtualenv:
	
	#apt-get update --yes --force-yes
	#sudo apt-get --yes --force-yes install python3 python3-venv python3-pip  
	
	mkdir -p $(INSTALL_DIR)
	[ ! -d $(INSTALL_DIR)/env ] && cd $(INSTALL_DIR) && sudo python3 -m venv env || true
	#cd $(INSTALL_DIR) && . $(VIRTUALENV_ACTIVATE) && cd home-assistant && sudo pip3 install -r requirements.txt --upgrade
	sudo chown -R homeassistant $(INSTALL_DIR)/env

.PHONY: install
install: install-homeassistant install-user install-service install-webcam

# Default target
.PHONY: test
test:
	
	. $(VIRTUALENV_ACTIVATE) && hass -c config --script check_config

.PHONY: build-config
build-config: test
		
	mkdir -p $(BUILD_DIR)/hass-config
	rsync -av \
		  --exclude='*.db' --exclude='*.log' \
		  --exclude='*.sample'  \
		  --exclude='secrets.yaml' --exclude='known_devices.yaml' \
		  --exclude='.google.token' --exclude='.uuid' \
		  --exclude='config/tts/' --exclude='config/deps' \
		  config ext Makefile README.md \
		  $(BUILD_DIR)/hass-config/
		  
.PHONY: build-hass
build-hass:
		
	#mkdir -p $(BUILD_DIR)/hass-hass
	rm -rf $(BUILD_DIR)/hass-hass
	git clone -b $(HASS_BRANCH) $(HASS_GIT) $(BUILD_DIR)/hass-hass || true
	rm -rf $(BUILD_DIR)/hass-hass/.git
	
.PHONY: build
dist: build-config build-hass

.PHONY: dist-config
dist-config: build-config

	cd $(BUILD_DIR) && tar cvzf hass-config.tar.gz hass-config

.PHONY: dist-hass
dist-hass: build-hass

	cd $(BUILD_DIR) && tar cvzf hass-hass.tar.gz hass-hass

.PHONY: dist
dist: dist-config dist-hass

# Copy to target host and install (runs make install on target host)
.PHONY: deploy-hass
deploy-hass: dist-hass deploy-config   
	
	$(info Deploying HA package to $(INSTALL_HOST).)
	
	scp $(BUILD_DIR)/hass-hass.tar.gz $(INSTALL_HOST):/tmp
	ssh $(INSTALL_HOST) "\
		mkdir -p /tmp/hass-$(TMPID) && \
		cd /tmp/hass-$(TMPID) && \
		tar xf ../hass-hass.tar.gz"
	
	ssh $(INSTALL_HOST) '\
		sudo mkdir -p $(INSTALL_DIR)/home-assistant/ && \
		sudo cp -r /tmp/hass-$(TMPID)/hass-hass/* $(INSTALL_DIR)/home-assistant/ && \
		sudo chown -R homeassistant. $(INSTALL_DIR)/home-assistant/ && \
		cd $(INSTALL_DIR) && \
		sudo make install'

.PHONY: deploy-config
deploy-config: dist-config 

	$(info Deploying HA config to $(INSTALL_HOST).)

	scp $(BUILD_DIR)/hass-config.tar.gz $(INSTALL_HOST):/tmp
	ssh $(INSTALL_HOST) "\
		mkdir -p /tmp/hass-$(TMPID) && \
		cd /tmp/hass-$(TMPID) && \
		tar xf ../hass-config.tar.gz"
	
	ssh $(INSTALL_HOST) '\
		sudo mkdir -p $(INSTALL_DIR) && \
		sudo cp -r /tmp/hass-$(TMPID)/hass-config/* $(INSTALL_DIR)/ && \
		sudo chown -R homeassistant. $(INSTALL_DIR)'

.PHONY: deploy-secret
deploy-secret:

	$(info Deploying HA var config to $(INSTALL_HOST).)
	
	cd $(BASE_DIR)/config && scp $(PRIVATE_FILES) $(INSTALL_HOST):/tmp/
	ssh $(INSTALL_HOST) "\
		cd /tmp && sudo cp $(PRIVATE_FILES) $(INSTALL_DIR)/config && \
		cd $(INSTALL_DIR)/config && sudo chown homeassistant. $(PRIVATE_FILES) && \
		cd /tmp && rm $(PRIVATE_FILES)" 

.PHONY: deploy
deploy: deploy-config deploy-hass 

