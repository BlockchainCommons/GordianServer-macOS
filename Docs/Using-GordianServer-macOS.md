# Using GordianServer-macOS

*GordianServer* for macOS uses *Bitcoin-Standup* to install Bitcoin Core and Tor on your system. The following description of functions and FAQs can provide additional insight into using the system.

## GuardianNode Functions

*Adding Tor Public Keys.* Shortly after installing *GordianServer*, you will be prompted to add a Tor public key. This will allow you to connect to your *GordianServer* from an authorized client. The Tor public key can be retrieved from the client that you are using. For example, if you are using [GordianWallet](https://github.com/BlockchainCommons/GordianWallet-iOS), there is an "Export Tor V3 Authentication Public Key" option under its settings page. Your can later add addition public keys using the "Add" button to the right of the screen.

*Choosing a Bitcoin Network.* You will need to start one or more Bitcoin networks in order to make use of *GordianServer*. Choose mainnet, testnet, or regtest. (Currently, we do *not* suggest mainnet, because *GordianServer* is not a fully released product.) Click the button that says "Start" and the network will begin syncing. On *GordianServer* you can actually connect to up to all three networks if you want, just connect each separately and use the individual hidden services.

*Refreshing the Screen.* If your chosen Bitcoin network doesn't seem to be updating (or if something else seems out-of-date in *GordianServer*), click the "refresh" button at top left. It should update the screen to the current status.

*Changing Settings.* The gear icons at the top of the *GordianServer* screen give you access to Settings. Options allow you to change some `bitcoin.conf` settings, to shut down *GordianServer*, and to look at your logs.

## GordianServer FAQs

### How Do I Change the Location of My Data?

Because Bitcoin requires 30G or more of storage, you may wish to move its data to an external drive. This can be done by selecting the Settings gear (see above) and changing the Data Directory.
