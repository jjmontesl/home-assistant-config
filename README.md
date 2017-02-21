

Introduction
============

This is my configuration of Home Assistant. It may serve as a *cookbook* from which recipes can be taken.

It is a package based configuration. The configuration is grouped into packages that can
be easily reused. In any case, you'll need to adapt the configuration to suit your needs and the
name of your sensors and objects.

Scripts and configuration applied to other devices is also included, like the configuration
of my laptop to work with Home Assistant.

A *Makefile* is included. I use it to deploy the configuration to my Raspberry Pi,
and also to deploy Home Assistant itself too.

Note that I do not own any sensors or switches, so some are simulated. The main features of this
configuration are automation, integration with media players, and device tracking. See below.

*This is still a work in progress. Some features are missing, but for now it is the configuration I use.*


**Features**
------------

* Alarm Clock
* Calendars (Google Calendar)
* Device monitoring (Android mobile, Ubuntu laptop, Raspberry Pi)
* Media player management (TV, Linux player)
* Text to Speech audio in separate players (music keeps playing in background)
* Notifications engine: messages sent via speech or Telegram as per configuration
* Automation Profiles and Config Controls: easy management of automation settings
* Distance to home tracking and common travel distances
* Traffic cameras (URLs not provided)
* Internet external IP monitoring, with notification
* Presence automations: welcome home music, welcome home report, welcome work report
* Personal / work email pending count
* "Home report" feature: provides a TTS overview of the data
* Random / funny quote (shown in UI and reports)
* Weather information
* Hourly time report
* Voice commands via API.AI (from browser)
* Fine-tuned history and logbook keeping


Usage
=====

You can take recipes from this repository or you can use it as a basis to
start your own Home Assistant configuration.

If you wish to use this configuration as a base for yours, just fork the project
at GitHub. Clone your new repository.

In either case, you then need to review each of the packages and adapt it
to meet your needs. Remove everything you don't need and adapt names ot match
your sensors and objects.


Preparing the config and testing
--------------------------------

*Section to be written*

Run `make test` to test the configuration.


Deploying to the Raspberry Pi (or final host)
---------------------------------------------

In my case I deploy Home Assistant to a Raspberry Pi.

To deploy the software, I use the command below. This installs a virtual environment
and home assistant. It also installs home assistant as a service, creating a user for it.
Do this at your own risk. In order to use it, review the Makefile and update the
addresses for your deployment.

    make deploy-hass

You can then manage Home Assistant service using:

    service home-assistant@homeassistant stop
    service home-assistant@homeassistant start

In order to deploy configuration:

    make deploy-config
    make deploy-secrets

You need to restart Home Assistant after deploying a new configuration.

You can see the log files using:

    tail -f /var/log/syslog

...or:

    tail -f /srv/home-assistant/config/home-assistant.log


Configuration for Ubuntu Desktops (Clementine, MPD, Kodi)
---------------------------------------------------------

**Clementine Player**

In order to have Clementine Music Player available, user session needs to be set up for automatic log on.

Add a copy of the Clementine desktop link (/usr/share/applications/) to ~/.config/autostart  so it starts automatically.

**MPD**

In order to have a separate stream for Text-to-Speech notifications, MPD has to be installed and configured.


FAQ
===

Feel free to ask any question using GitHub [Issues](http://github.com/jjmontesl/home-assistant-config/issues).

