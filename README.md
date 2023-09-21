# **Gitcoin Passport** Discourse Plugin

## Overview

Gitcoin Passport is a sybil resistance tool that helps DAOs and online communities protect themselves from bots and sybil attackers.  This is a guide on how to setup and enable the Gitcoin Passport plugin on Discourse to protect community forums from bad actors while preserving anonymity in the process to do so. 

## How Gitcoin Passport Works

Gitcoin Passport allows anyone to create their own passport and add stamps to this passport by verifying different criteria. The verification process is completely anonymous, ie, once a stamp is verified, a person can use this stamp on any supported platform (like Discourse) without revealing their identity. For example, a person could prove that they have contributed to codebases on Github on at least 120 distinct days without actually revealing who they are!

Examples of some stamps available today are -
1. More than 1000 number of followers on Twitter
2. Ownership of a .eth (ENS) name
3. A Discord account ownership
4. Participation in DAO governance on Snapshot
5. Certain amount of gas fees spent on the Ethereum network

There are many more stamps available today and being added to Gitcoin Passport regularly. You can find these, create a passport and start adding stamps to your passport on the [Gitcoin Passport](https://passport.gitcoin.co/) website.

![Pasport](https://cdn.discordapp.com/attachments/831959066486112267/1133764606066696265/passport_dashboard.png)


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
  before_code:                            
    - exec:                                
        cmd:                              
          - gem install rubyzip           
  after_code:
    - exec:
      cd: $home/plugins
      cmd:
        - sudo -E -u discourse git clone https://github.com/discourse/docker_manager.git
        - sudo -E -u discourse git clone https://github.com/spruceid/discourse-siwe-auth.git
        - sudo -E -u discourse git clone https://github.com/dappy-studio/gitcoin-passport-discourse-plugin.git   # <-- added
```
Follow the existing format of the docker_manager.git line; if it does not contain sudo -E -u discourse then insert - git clone https://github.com/dappy-studio/gitcoin-passport-discourse-plugin.git.

Rebuild the container:
```
cd /var/discourse
./launcher rebuild app
```
## Enabling the plugin

To enable the plugin, you'd need to have admin access on your Discourse forum. Here are the steps to enable it.
1. Go to your admin settings page
2. Go to the plugins tab
3. Click the "Settings" button on "discourse-gitcoin-passport" plugin

   Note: If you do not see this plugin, it means the installation of the plugin wasn't successful. Please go back to "Install the Plugin" section.
5. Enable Gitcoin Passport by checking the "Enable Gitcoin Passport?" checkbox

## Setup Gitcoin Passport API key and scorer ID

To setup the plugin, you'd need to have admin access on your Discourse forum. Here are the steps to set it up.
1. Go to the [Gitcoin Passport scorer app](https://scorer.gitcoin.co/) and sign in with your wallet
2. Go to the "API keys" tab => Click "+ API key" => Give your key a name => Click "Create"
3. Copy the API key and paste on the field named "gitcoin passport api key" in your "discourse-gitcoin-passport" plugin setting on Discourse
4. Go back to the Gitcoin Passport scorer app.
5. Go to the "Scorer" tab => Click "+ Scorer" => Select an use case => Give it a name and description => Click "Continue" =>
   Select the scoring mechanism you'd want to use => Click "Create Scorer"
6. Once you have a new scorer, you can copy the Scorer ID and paste it on the field named "gitcoin passport scorer id" in your "discourse-gitcoin-passport" plugin setting on Discourse

![Setup](https://cdn.discordapp.com/attachments/831959066486112267/1133764605789863946/plugin_setting.png)

If you've been able to follow along till here, congrats! You've now successfully setup the basic requirements to have a functional Gitcoin Passport plugin. 
Now we get to the exciting parts!

## Customizations

The Gitcoin Passport Discourse plugin is highly customizable which allow you to gate access on various actions taken by an user on your forum.

![customizations](https://cdn.discordapp.com/attachments/831959066486112267/1133764605542420521/customizations.png)

### gitcoin passport forum level score to create account

The minimum score to create an account can be set to prevent sybil attackers right at the door! When you set this score, a person would need to sign in with their wallet and also collect enough stamps from Gitcoin Passport to have enough score to create an account.
And dont worry! We've made it such that people know exactly the score they currently have, the required score and the url they can go to collect the stamps right where they create a new account.

Wait, so, does this mean the existing users lose access until they collect some stamps???

Well, you can decide!

### gitcoin passport last date to connect wallet for existing users

Using this setting, you can set a last date by which existing users would need to connect their wallets and get the minimum score required. After this date, any user (existing or new) that dont have the required minimum score will not have the permission to post or create a new topic.

### gitcoin passport forum level score to post (and other ways you can gate posting on Discourse)

When you set the minimum score required to post, everyone in the forum must have this score to be able to reply (ie, create a post) on all topics. Unless ...

You override this score with a more specific score on the category level or user level. Wait, what? I'm confused.

Okay, so ...

When you're trying to gate access to replying on Discourse topics using Gitcoin Passport scores, you can do it on 3 levels.

1. User level - Each user could have a specific score required to reply. If an user doesn't meet this score they cannot reply on any topic. If this score is set, the category level score or the forum level score for this specific user doesn't matter.

![user](https://cdn.discordapp.com/attachments/831959066486112267/1133764604879700079/user_score.png)

2. Category level - Each category could have a specific score required to reply on topics only in that category. If an user doesn't meet the required score, they wont be able to reply only on this category. They would still be able to reply on other categories. If this score is set, the forum level score doesnt matter for this specific category.

![category](https://cdn.discordapp.com/attachments/831959066486112267/1133764605215252581/category_score.png)

3. Forum level - This is the minimum score required by all users replying to topics in all categories. Unless there's a score set on the category or user level, this would be the score that is used.

### gitcoin passport forum level score to create new topic (and other ways you can gate posting on Discourse)

This works exactly the same way as the "gitcoin passport forum level score to post" setting. Only difference is this applies to creating a new topic. 

IMPORTANT: Please make sure that this score is higher than the score required to post. If it is lower, the score will default to the score required to post (since technically a new topic is also a new post).


## Okay, we have covered the most important parts of this plugin. Now let's go over some of the cool extras!

The plugin makes it possible to distribute discourse badges automatically when someone crosses a score threshold. This can be used to incentivize individuals to get a higher passport score, thus increasing the overall "humanity" of the community. 

Why, you ask?

Well, this lets all the community members be more certain that they're interacting with other unique humans thus making your community more of a safe haven over time.

Some quick but important setup before we proceed.

1. Got to the "Badges" tab in the Admin settings
2. Create a new badge
   a. Click "+ New"
   b. Give your badge a name, add a graphic, set the badge type as "Bronze" and give it a description
   c. Important - Click the edit icon under "Badge Groupings" and create a new group called "Unique Humanity". Double-check that the spelling and typing is the same, ie, **Unique Humanity**. Save it.
   d. Save the badge.
   e. Remember to enable it using the toggle on top.
3. Do the same thing as 2 to create the Silver and Gold badges.

Now, we are ready to setup the scores required to get these badges. 


### gitcoin passport required to get unique humanity bronze badge

The minimum score required by everyone to get the Bronze Unique Humanity Badge

### gitcoin passport required to get unique humanity silver badge

The minimum score required by everyone to get the Silver Unique Humanity Badge

### gitcoin passport required to get unique humanity gold badge

The minimum score required by everyone to get the Gold Unique Humanity Badge

These badges are received by users on the forum automatically when they connect (or reconnect) their wallet. Users can also go to "Profile" => "Summary" and click "Refresh" to update their passport score and automatically receive the badges they're eligible for.

Okay. Now, one final recommended setting applicable to sites that expect high traffic.

![badge](https://cdn.discordapp.com/attachments/831959066486112267/1133764604657422407/badges.png)

### ethereum node url

If you're already running your own ethereum node or have a hosted node (with providers such as Infura or Ankr), you can copy and paste your node url here. Please be aware that the default node set here is a public node on free tier, so it is highly recommended to use your own nodes.


## Woah, that was a lot!

No worries, we have also recorded a [Youtube tutorial](https://youtu.be/_9RFjcls8vw) to help out (especially if you're a visual learner)

If you still need help, please feel free to ask for support in any of the following mediums.

1. Raise an issue on this repo
2. Our [Discord](https://discord.gg/KW5suDzsdp), where you may get the fastest response as of today
3. Our email at support@dappy.lol
