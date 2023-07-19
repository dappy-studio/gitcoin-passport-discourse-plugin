# **Gitcoin Passport** Discourse Plugin

## Overview

Gitcoin Passport is a sybil resistance tool that helps DAOs and online communities protect themselves from bots and sybil attackers.  This is a guide on how to setup and enable the Gitcoin Passport plugin on Discourse to protect community forums from bad actors while preserving anonymity in the process to do so. 

## How Gitcoin Passport Works

Gitcoin Passport allows anyone to create their own passport and stamps to this passport by verifying different criteria. The verification process is completely anonymous, ie, once a stamp is verified, a person can use this stamp on any supported platform (like Discourse) without revealing their identity. For example, a person could prove that they have contributed to codebases on Github on at least 120 distinct days without actually revealing who they are!

Examples of some more stamps available today are -
1. More than 1000 number of followers on Twitter
2. Ownership of a .eth (ENS) name
3. A Discord account ownership
4. Participation in DAO governance on Snapshot
5. Certain amount of gas fees spent on the Ethereum network

There are many more stamps available today and being added to Gitcoin Passport regularly. You can find these, create a passport and start adding stamps to your passport on the [Gitcoin Passport](https://passport.gitcoin.co/) website.


## Requirements

- A hosted Discourse forum where the plugin can be added.
- Sign in with Ethereum Discourse [plugin](https://github.com/spruceid/discourse-siwe-auth/tree/main)

## Installing the plugin

To install and enable the plugin on your self-hosted Discourse use the following method: Access your container’s app.yml file (present in /var/discourse/containers/)

```
cd /var/discourse
nano containers/app.yml
Add the plugin’s repository URL to your container’s app.yml file:

hooks:
  before_code:                             # <-- added
    - exec:                                # <-- added
        cmd:                               # <-- added
          - gem install rubyzip            # <-- added
  after_code:
    - exec:
      cd: $home/plugins
      cmd:
        - sudo -E -u discourse git clone https://github.com/discourse/docker_manager.git
        - sudo -E -u discourse git clone https://github.com/spruceid/discourse-siwe-auth.git   # <-- added
        - sudo -E -u discourse git clone https://github.com/spect-ai/gitcoin-passport-discourse-plugin.git   # <-- added
```
Follow the existing format of the docker_manager.git line; if it does not contain sudo -E -u discourse then insert - git clone https://github.com/spect-ai/gitcoin-passport-discourse-plugin.git.

Rebuild the container:
```
cd /var/discourse
./launcher rebuild app
```
## Enabling the plugin

1. Go to your admin settings page
2. Go to the plugins tab
3. Click the "Settings" button on "discourse-gitcoin-passport" plugin
   Note: If you do now see this plugin, it means the installation of the plugin wasn't successful. Please go back to "Install the Plugin" section.
4. Enable Gitcoin Passport by checking the "Enable Gitcoin Passport?" checkbox

## Customizations

The Gitcoin Passport Discourse plugin is highly customizable. Here are some of its capabilities.
