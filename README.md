# Slack App-in-Tab extension

A Chrome + Firefox extension to open the Slack app with its multi-workspace sidebar in a simple browser tab.

1. Install the extension from [the Chrome Webstore(pending)] or [addons.mozilla.org](https://addons.mozilla.org/en-US/firefox/addon/slack-app-in-tab/)
2. Visit [app.slack.com](https://app.slack.com) and log into any of your workspaces
3. That's it, all your workspaces appear in the sidebar, just like in the Slack App

Under the hood, "_Slack App-in-Tab_" is a tiny extension.
It changes your browser's User Agent String to the one used in Chrome OS, when you visit app.slack.com.
Slack always runs in _app mode_ on that platform. _Tada!_

The Chrome version reported in the User Agent String is computed from the current date.
Slack therefore never flags the browser as outdated.

The extension uses WebExtension Manifest v3 with a content script that runs in the page's main world.
It requires Chrome 111+ or Firefox 140+.

# Author

[@louisremi](https://twitter.com/louis_remi)
