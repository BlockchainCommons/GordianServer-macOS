# 🛠 Bitcoin-Standup MacOS

*Bitcoin-Standup* is a open source project and a suite of tools that helps users to install a [Bitcoin-Core](https://bitcoin.org/) full-node on a fresh computer or VPS and to add important privacy tools like onion services. It will eventually also support optional Bitcoin-related tools like [Electrum Personal Server](https://github.com/chris-belcher/electrum-personal-server), [C-Lightning](https://github.com/ElementsProject/lightning), [Esplora](https://github.com/Blockstream/esplora), and [BTCPay Server](https://github.com/btcpayserver/btcpayserver) as well as emerging technologies like Bitcoin-based Decentralized Identifiers. *Bitcoin-Standup* strives to provide the community with an easy to use "one-click" set up full-node complete with a purpose built remote app for securely connecting to your node over Tor from anywhere in the world, providing you with a powerful suite of tools.

This tool will also harden and secure your OS to current best practices and will add sufficient system tools to support basic Bitcoin development. After setup, *Bitcoin-Standup* will present a QR code and/or special URI that can be used to securely link your full-node to other devices, such as a remote desktop or a mobile phone using [FullyNoded 2](https://testflight.apple.com/join/OQHyL0a8) or [Fully Noded 1](https://github.com/FontaineDenton/iOS/FullyNoded) on iOS.

This repo includes the MacOS version of Bitcoin-*Standup*, which allows you to run a full node on your Mac computer.

<img src="https://github.com/BlockchainCommons/Bitcoin-StandUp-MacOS/blob/master/Images/standup_intro.png" alt="" width="400"/>

<img src="https://github.com/BlockchainCommons/Bitcoin-StandUp-MacOS/blob/master/Images/standup_home.png" alt="" width="400"/>

<img src="https://github.com/BlockchainCommons/Bitcoin-StandUp-MacOS/blob/master/Images/qr.png" alt="" width="400"/>

<img src="https://github.com/BlockchainCommons/Bitcoin-StandUp-MacOS/blob/master/Images/standup_config.png" alt="" width="400"/>

## Additional Information

For more information on *Bitcoin-Standup*:

1. The [Main *Bitcoin-Standup* Repo](https://github.com/BlockchainCommons/Bitcoin-Standup) contains general information on the project.
2. [How *Bitcoin-Standup* MacOS Works](Docs/How-it-works.md) describes the specifics of what *Bitcoin-Standup* does.
3. [Why Run a Full Node?](Docs/Why-Full.md) details why you would want to run a full node in the first place.
4. [Security for Bitcoin-Standup](Docs/Security) offers notes on ensuring the security of your *Bitcoin-Standup* node.

## Status — Work-in-Progress

*Bitcoin-Standup* is an early **Work-In-Progress**, so that we can prototype, discover additional requirements, and get feedback from the broader Bitcoin-Core Developer Community. ***It has not yet been peer-reviewed or audited. It is not yet ready for production uses. Use at your own risk.***

## Installation Instructions

You must meet minimum OS and space requirements to install *Bitcoin-Standup* on your Mac. You may install either using *Strap* or using *Xcode*.

### Dependencies

- macOS v10.15 Catalina (may work on earlier versions, not tested yet)
- ~300 GB of free space for a full mainnet node with txindex; or ~20 GB for a full testnet3 node; or substantially less if the full node is pruned.

### Method One: Install Using Strap

Start by installing *Strap*, a script hosted on Github for bootstrapping a minimal development environment, intended for a new Mac or a fresh install of macOS. Then, run the *Bitcoin-Standup* app, which will create your Bitcoin environment using *Strap*.

***WARNING:*** *Be careful about using GitHub bash scripts on existing systems as they can compromise your computer. Use these scripts on new systems only. We also suggest you view the [script](https://github.com/MikeMcQuaid/strap/blob/master/bin/strap.sh) in advance, and only execute it if you trust the source. [@MikeMcQuaid](https://github.com/MikeMcQuaid) is the open source [Homebrew](https://brew.sh) Project's lead maintainer and also a senior member of the GitHub staff.*

#### Step One: Install Strap

1. Begin with a fresh macOS install.

2. Choose one of the following three methods to install *Strap*.

   - ***Option #1: Install from CLI.*** Install the *Strap* script directly from your Mac's CLI (command line interface)

     1. Run *Terminal*, which is usually available in "Applications > Utilities".
     2. Execute these commands via the *Terminal* app's command line interface:

     ```bash
     curl -L https://raw.githubusercontent.com/MikeMcQuaid/strap/master/bin/strap.sh > ~/Downloads/strap.sh
     bash ~/Downloads/strap.sh
     ```

   - ***Option #2: Install from GitHub.*** Clone the *Strap* repo to your Mac and then execute the script.

     1. Run *Terminal*, which is usually available in "Applications > Utilities".
     2. Execute these commands via the *Terminal* app's command line interface:

     ```bash
     git clone https://github.com/MikeMcQuaid/strap
     cd strap
     bash bin/strap.sh
     # or `bash bin/strap.sh --debug` for more debugging output
     ```

   - ***Option #3: Installing using Heroku.*** Use the [*Strap* heroku web app](https://macos-strap.herokuapp.com/). This web application will request a temporary Github secure access token for your use, allowing you use the *strap.sh* script to automatically install and download from your own personal GitHub repository `.dotfiles` and install additional apps from a `.Brewfile`. This token is solely used to add the GitHub access token to your `strap.sh` download and is not otherwise used by this web application or stored anywhere.

     1. Open https://macos-strap.herokuapp.com/ in your web browser. Click on the `strap.sh` button.
     2. Login to your GitHub account.
     3. Download `strap.sh` to your `~/Downloads/` folder
     4. Run *Terminal*, which is usually available in "Applications > Utilities".
     5. Execute this command via the *Terminal* app's command line interface:

     ```bash
     bash ~/Downloads/strap.sh
     ```

     6. After *strap.sh* has finished processing, delete the customized `strap.sh` (it has a GitHub acces token in it) by executing:

     ```bash
     rm ~/Downloads/strap.sh
     ```


#### Step Two: Install *StandUp.app*

You are now ready to install *Bitcoin-Stanup* using *Strap*:

3. Download the `StandUp_Export.zip` from this [public google drive link](https://drive.google.com/open?id=1lXyl_zO6WPJN5tzWAVV3p42WPFtyesCR).
4. Unzip `StandUp_Export.zip`.
5. Open the folder and double-click `StandUp.app`.

Peter Denton GPG fingerprint: `3B37 97FA 0AE8 4BE5 B440 6591 8564 01D7 121C 32FC` signed the above `StandUp_Export.zip` which produced the following signature:

```
-----BEGIN PGP SIGNATURE-----

iQIzBAABCAAdFiEEOzeX+groS+W0QGWRhWQB1xIcMvwFAl4Q8agACgkQhWQB1xIc
Mvy8Kg/8Dbw+Ju0LZhXtheauI43TqVkbh5XCAamDAtzRAKlKLhYjYW1XMFQ/y923
X+/+ld3ZjrlC8qQhEm+6cR21m5GgP2FsA1lKiAH92X2hpzv7taUkrAVjLdhn9KA0
BRFabRzL1720l9Q7IHbo2zMDUKnK3PC0zKDtmoSl/E7HbMomEXgldnFl3Vi6D9Ah
fMQnR36ECbTRPuBvuETS77XBnU27t9LHtFTcE9YyoikF4qvsDEtC6VkMjK+gHj0A
BQuJtC1q9/FS9JTv1goPYJjmERqFj7jadwqfct3AVSJy0W2bltzOUf3lQNAaMcZc
XsRZwnGcGVpxFo7YORlzwjGUxsz8jjBVl4IUOIi/6mW21gWAq7LZKUWvBOp5Soj0
xhTXO+04O2hd5/l4Nap5CNyxzKqkUl6f/cTVXHWrMVFQ6gn9EX1kiPDjdaWzlcHX
dGGOkscJwG+wPR5MJlyVkFQIUFzBMYMynZE/zU62H6FRtWUoobaZCB8k4+icIh2Z
kHCYygkfEZreI7c2aMs5sYsbkNJ/X22CQC+jdRC+V52aClC4OkR9QrJm+E4hTqmz
eYehwAF1LW0IrF/zM8mc45fpkHr+uCDjLZb6ctsUONPc7ARKt1vYZ+r1NM4sHq2m
SijIlxPUugawiAn90sGhaTGviTWg1A06l3hpjzhaEdyIY2UOD7g=
=V4d6
-----END PGP SIGNATURE-----

```


### Method Two: Build Mac App from source using Xcode


Instead of downloading binaries through *Strap*, you can build *Bitcoin-Standup* by hand using Apple's *Xcode*.

1. Install [*Xcode*](https://itunes.apple.com/id/app/xcode/id497799835?mt=12).
2.  [Create](https://developer.apple.com/programs/enroll/) a free Apple developer account.
3. In *XCode*, click "XCode" -> "preferences" -> "Accounts" -> add your GitHub account.
4. On the GitHub repo, click "Clone and Download" > "Open in XCode".
5. When *XCode* launches, press the "play" button in the top left.

### After Installation

Once the app has completely installed (by either method) and once it has launched Bitcoin, it will present a *Quick Connect QR code* that can be used to securely link your full node remotely over Tor to other devices, such as the iOS application [FullyNoded 2](https://github.com/BlockchainCommons/FullyNoded-2).

## Financial Support

*Bitcoin-Standup* is a project of [Blockchain Commons](https://www.blockchaincommons.com/). We are proudly a "not-for-profit" social benefit corporation committed to open source & open development. Our work is funded entirely by donations and collaborative partnerships with people like you. Every contribution will be spent on building open tools, technologies, and techniques that sustain and advance blockchain and internet security infrastructure and promote an open web.

To financially support further development of *Bitcoin-Standup* and other projects, please consider becoming a Patron of Blockchain Commons through ongoing monthly patronage as a [GitHub Sponsor](https://github.com/sponsors/BlockchainCommons). You can also support Blockchain Commons with bitcoins at our [BTCPay Server](https://btcpay.blockchaincommons.com/).

## Contributing

We encourage public contributions through issues and pull requests! Please review [CONTRIBUTING.md](./CONTRIBUTING.md) for details on our development process. All contributions to this repository require a GPG signed [Contributor License Agreement](./CLA.md).

### Questions & Support

As an open-source, open-development community, Blockchain Commons does not have the resources to provide direct support of our projects. If you have questions or problems, please use this repository's [issues](./issues) feature. Unfortunately, we can not make any promises on response time.

If your company requires support to use our projects, please feel free to contact us directly about options. We may be able to offer you a contract for support from one of our contributors, or we might be able to point you to another entity who can offer the contractual support that you need.

### Credits

The following people directly contributed to this repository. You can add your name here by getting involved. The first step is learning how to contribute from our [CONTRIBUTING.md](./CONTRIBUTING.md) documentation.

| Name              | Role                | Github                                            | Email                                                       | GPG Fingerprint                                    |
| ----------------- | ------------------- | ------------------------------------------------- | ----------------------------------------------------------- | -------------------------------------------------- |
| Christopher Allen | Principal Architect | [@ChristopherA](https://github.com/ChristopherA) | \<ChristopherA@LifeWithAlacrity.com\>                       | FDFE 14A5 4ECB 30FC 5D22  74EF F8D3 6C91 3574 05ED |
| Peter Denton      | Project Lead        | [@Fonta1n3](https://github.com/Fonta1n3)          | <[fonta1n3@protonmail.com](mailto:fonta1n3@protonmail.com)> | 3B37 97FA 0AE8 4BE5 B440 6591 8564 01D7 121C 32FC  |

## Responsible Disclosure

We want to keep all of our software safe for everyone. If you have discovered a security vulnerability, we appreciate your help in disclosing it to us in a responsible manner. We are unfortunately not able to offer bug bounties at this time.

We do ask that you offer us good faith and use best efforts not to leak information or harm any user, their data, or our developer community. Please give us a reasonable amount of time to fix the issue before you publish it. Do not defraud our users or us in the process of discovery. We promise not to bring legal action against researchers who point out a problem provided they do their best to follow the these guidelines.

### Reporting a Vulnerability

Please report suspected security vulnerabilities in private via email to ChristopherA@BlockchainCommons.com (do not use this email for support). Please do NOT create publicly viewable issues for suspected security vulnerabilities.

The following keys may be used to communicate sensitive information to developers:

| Name              | Fingerprint                                        |
| ----------------- | -------------------------------------------------- |
| Christopher Allen | FDFE 14A5 4ECB 30FC 5D22  74EF F8D3 6C91 3574 05ED |

You can import a key by running the following command with that individual’s fingerprint: `gpg --recv-keys "<fingerprint>"` Ensure that you put quotes around fingerprints that contain spaces.

## Reporting a Vulnerability

To report security issues send an email to ChristopherA@LifeWithAlacrity.com (not for support).

The following keys may be used to communicate sensitive information to developers:

| Name              | Fingerprint                                        |
| ----------------- | -------------------------------------------------- |
| Christopher Allen | FDFE 14A5 4ECB 30FC 5D22  74EF F8D3 6C91 3574 05ED |

You can import a key by running the following command with that individual’s fingerprint: `gpg --recv-keys "<fingerprint>"` Ensure that you put quotes around fingerprints that contain spaces.

