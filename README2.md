[![Build Status](https://travis-ci.org/okta/okta-signin-widget.svg?branch=master)](https://travis-ci.org/okta/okta-signin-widget)

# Okta Sign-In Widget

Some intro text, and links to the getting started guide and sdks.

## Table of Contents

- Getting Started (LATER)
- Example (LATER, or point to sdk examples)
- Install
  - Using the Okta CDN
  - Using hte @okta/okta-signin-widget npm module
- Usage
  - API
  - Config options
  - Customization
    - Styles
    - labels, css
- Developing the sign-in-widget

## Install

You can include the Sign-In Widget in your project either directly from the Okta CDN, or by packaging it with your app code via our npm package, [@okta/okta-signin-widget](https://www.npmjs.com/package/@okta/okta-signin-widget).

### Using the Okta CDN

Pointing directly to the CDN is a good choice if you want an easy way to get started with the widget, and don't already have an existing build process that leverages npm to host JS vendor files.

To use the CDN, include links to the JS and CSS files in your HTML:

```html
<!-- Latest CDN production Javascript and CSS: 1.6.0 -->
<script
  src="https://ok1static.oktacdn.com/assets/js/sdk/okta-signin-widget/1.6.0/js/okta-sign-in.min.js"
  type="text/javascript"></script>
<link
  href="https://ok1static.oktacdn.com/assets/js/sdk/okta-signin-widget/1.6.0/css/okta-sign-in.min.css"
  type="text/css"
  rel="stylesheet"/>

<!-- Theme file: Customize or replace this file with your own CSS -->
<link
  href="https://ok1static.oktacdn.com/assets/js/sdk/okta-signin-widget/1.4.0/css/okta-theme.css"
  type="text/css"
  rel="stylesheet"/>
```

### Using the @okta/okta-signin-widget npm module

Using our npm package is a good choice if:
- You have a build system in place where you manage dependencies with npm
- You do not want to load scripts directly from third party sites

To install [@okta/okta-signin-widget](https://www.npmjs.com/package/@okta/okta-signin-widget):

```bash
# Run this command in your project root folder. Before running this command,
# you will need to have added a package.json to this folder.
[project-root-folder]$ npm install @okta/okta-signin-widget --save
```

The widget source files and assets will be installed to `node_modules/@okta/okta-signin-widget/dist`, and will have this directory structure:

```bash
node_modules/@okta/okta-signin/dist/
  css/
    # Main CSS file for widget styles. Try not to override the classes in this
    # file when creating a custom theme - the classes/elements are subject to
    # change between releases
    okta-sign-in.min.css

    # Example theme file that you can use to create your own custom theme
    okta-theme.css

  # Base font and image files that are used in rendering the widget
  font/
  img/

  js/
    # Main JS file that exports the OktaSignIn object
    okta-sign-in.min.js

  # Localized strings that are used to display all text and labels in the
  # widget. Three output formats are included - json, jsonp, and properties
  labels/

  # Sass files that are used to generate the widget css. If you are already
  # using Sass in your project, you can include these helper files to make
  # generating your custom theme easier
  sass/
```

After running `npm install`:

1. Setup a build process to copy the assets to a folder that will be distributed to your publicly hosted site. The folders you'll need to copy are *css/*, *font/*, *img/*, *js/* and *labels/*.

2. Instead of copying *js/* and including it in your page as a global, you can require the Sign-In Widget in your build if you are using [Webpack](https://webpack.github.io/), [Browserify](http://browserify.org/) or another module bundling system that understands the node_modules format.

    To do this in your code:

    ```javascript
    # Load the Sign-In Widget module
    var OktaSignIn = require('@okta/okta-signin-widget');

    # Use OktaSignIn
    var signIn = new OktaSignIn(/* configOptions */);
    ```

## API

### new OktaSignIn(config)

Creates a new instance of the Sign-In Widget with the given config options. The widget has many config options to customize and change its behavior, which you can read about [here][ENTER_LINK_HERE]. The only required option to get started is `baseUrl`, the base url for your Okta domain.

#### Example

```javascript
var signIn = new OktaSignIn({
  baseUrl: 'https://{{myorg}}.okta.com',
  logo: '/path/to/logo.png'
});
```

### renderEl(options, success, error)

Renders the widget to the DOM, and passes control back to your app through the success and error callback functions when the user has entered a success or fail state.

- `options` {Object}
  - `el` {String} - A css selector for the container element to attach the widget to
- `success` {Function(Object res)} - Called when the user has successfully entered a final auth state. The function is invoked with a `res` object that will contain a `status` property, and additional metadata that depends on the type of response.
- `error` {Function(Error err)} - Called when the widget has been bootstrapped with invalid config options, or has entered a state it cannot recover from (i.e. the user is using an unsupported browser).

#### Example

```javascript
signIn.renderEl(
  // Assumes there is an element on the page with the id of 'osw-container'
  {el: '#osw-container'},

  function success(res) {
    // The user has successfully completed the auth flow
    if (res.status === 'SUCCESS') {
      // Depending on the type of login, the res object will either contain a
      // sessionToken, idToken, or accessToken.
    }

    // The user has started the password recovery flow, and is on the
    // confirmation screen letting them know an email is on the way.
    else if (res.status === 'FORGOT_PASSWORD_EMAIL_SENT') {
      // Any followup logic you'd like to perform after the user is on this
      // screen. Optional.
    }

    // The user has started the unlock account flow, and is on the confirmation
    // screen letting them know an email is on the way.
    else if (res.status === 'UNLOCK_ACCOUNT_EMAIL_SENT') {
      // Any followup logic you'd like to perform while the user is on this
      // screen. Optional.
    }
  },

  function error(err) {
    // This will be called with:
    // 1) Known errors: CONFIG_ERROR, UNSUPPORTED_BROWSER_ERROR, OAUTH_ERROR
    // 2) Uncaught exceptions
  }
);
```

### session.get(callback)

Gets the active session information, or returns `{status:inactive}` on error or no active session.

- callback {Function(Object res)} - Invoked once the session request has completed.

```javascript
signIn.session.get(function (res) {
  // Session exists, show logged in state.
  if (res.status === 'ACTIVE') {
    // showApp()
  }
  // No session, or error retrieving the session. Render the Sign-In Widget.
  else if (res.status === 'INACTIVE') {
    // No session, or error retrieving session information.
    signIn.renderEl(
      {el: '#osw-container'},
      function success(res) {
        // showApp() if res.status === 'SUCCESS'
      },
      function error(err) {
        // handleError(err)
      }
    );
  }
});
```

### session.refresh(callback)

Refresh the current session by extending its lifetime. This can be used as a keep-alive operation.

- callback {Function (Object res)} - Called with the current session response after the refresh request has completed.

#### Example

```javascript
signIn.session.refresh(function (res) {
  if (res.status === 'ACTIVE') {
    // The session now has an extended lifetime
  }
  else if (res.status === 'INACTIVE') {
    // There is no current session, render the Sign-In Widget
  }
});
```

### session.close(callback)

Signs the user out of their current Okta session. The callback will be invoked once the session has been closed.

- callback {Function (String err)} - Called once the session has been closed. If there is an error, it will be passed to the callback function.

#### Example

```javascript
signIn.session.close(function (err) {
  if (err) {
    // The user has not been logged out, perform some error handling here.
    return;
  }
  // The user is now logged out. Render the widget again:
  // loadSignInWidget();
});
```

### token.hasTokensInUrl()

Synchronous method to check for access or id tokens in the url. Returns `true` if there are tokens, and `false` if the redirect flow has not taken place yet.

**Note:** This is used when configuring the Sign-In Widget with Social Auth and the OAuth redirect flow.

##### Example

See the example in `token.parseTokensFromUrl`.

#### token.parseTokensFromUrl(success, error)

Parses the access or id tokens from the url after a successful .

- `success` {Function (Object res)} Called after the tokens have been parsed and validated
- `error` {Function (Error err)} Called if an error occurs while trying to parse or validate the tokens

**Note:** This is used when configuring the Sign-In Widget with Social Auth and the OAuth redirect flow.

#### Example

```javascript
var signIn = new OktaSignIn({
  baseUrl: 'https://{{myorg}}.okta.com',
  clientId: '{{myClientId}}',
  redirectUri: '{{redirectUrl configured in OIDC app}}',
  authParams: {
    responseType: 'id_token',
    // display: page will initiate the OAuth page redirect flow
    display: 'page'
  },
  idps: [
    {
      type: 'FACEBOOK',
      id: '{{facebook appId}}'
    }
  ]
});

// The user has just landed on our login form, and has not yet authenticated
// with a Social Auth IDP.
if (!signIn.hasTokensInUrl()) {
  signIn.renderEl(
    {el: '#osw-container'},
    function (res) {
      // storeTokensAndShowApp() if res.status === 'SUCCESS'
    },
    function (err) {
      // handleError(err);
    }
  );
}

// The user has redirected back after authenticating with the Social Auth IDP,
// and has their access or id token in the url
else {
  signIn.parseTokesnFromUrl(
    function success(res) {
      // storeTokensAndShowApp();
    },
    function error(err) {
      // handleError(err);
    }
  );
}
```

### idToken.refresh()

-- ADD STUFF HERE

### tokenManager.stuff()...

-- ADD STUFF HERE


## Config

The only required option is `baseUrl`. All others are optional.

-- ADD A BASIC EXAMPLE HERE WITH SOME OF THE STUFF BELOW --

### Basic config options

- `baseUrl` (String) - The base URL for your Okta organization

    Example: *"https://acme.okta.com"* or *"https://acme.oktapreview.com"*

- `logo` (String) - Local path or URL to a logo image that is displayed at the top of the Sign-In Widget

    Example: *"/img/logo.png"* or *"https://acme.com/img/logo.png"*

- `helpSupportNumber` (String) - Support phone number that is displayed in the Password Reset and Unlock Account flows. If no number is provided, no support screen is shown to the user.

    Example: *"(123) 456-7890"*

### Language and text options

- `language` (String) - Set the language of the widget. If no language is specified, the widget will choose a language based on the user's browser preferences if it is supported, or defaults to `en`.

  Supported languages:

  - `cs` - Czech
  - `da` - Danish
  - `de` - German
  - `en` - English
  - `es` - Spanish
  - `fi` - Finnish
  - `fr` - French
  - `hu` - Hungarian
  - `it` - Italian
  - `ja` - Japanese
  - `ko` - Korean
  - `nl-NL` - Dutch
  - `pt-BR` - Portuguese (Brazil)
  - `ro` - Romanian
  - `ru` - Russian
  - `sv` - Swedish
  - `th` - Thai
  - `uk` - Ukrainian
  - `zh-CN` - Chinese (PRC)
  - `zh-TW` - Chinese (Taiwan)

  Example: `{language: 'ja'}`

- `i18n` (Object) - Override the text in the widget. The full list of properties can be found in the [login.properties](ADDLINKHERE) and [country.properties](ADDLINKHERE) files.

    ```javascript
    // The i18n config object maps language codes to a hash of property keys ->
    // property values.
    i18n: {
      // Overriding English properties
      'en': {
        'primaryauth.title': 'Sign in to Acme',
        'primaryauth.username.placeholder': 'Your Acme Username'
      },
      // Overriding Japanese properties
      'ja': {
        'primaryauth.title': 'ACMEにサインイン',
        'primaryauth.username.placeholder': 'ACMEのユーザー名'
      }
    }

    // If you want to override any properties in the country.properties file,
    // you will need to prefix the name with "country.":
    i18n: {
      'en': {
        // login.properties keys do not have a special prefix
        'primaryAuth.title': 'Sign in to Acme',

        // country.properties keys are prefixed with 'country.'
        'country.AF': 'Afghanistan, edited',
        'country.AL': 'Albania, edited'
      }
    }
    ```

- `assets`

  - `baseUrl` (String) - Override the base url the widget pulls its language files from. The widget is only packaged with english text by default, and loads other languages on demand from the Okta CDN. If you want to serve the language files from your own hosting solution, update this setting.

    ```javascript
    // Loading the assets from a path on the current domain
    assets: {
      baseUrl: '/path/to/dist/labels/jsonp'
    },

    // Full urls work as well
    assets: {
      baseUrl: 'https://acme.com/assets/dist/labels/jsonp'
    }
    ```

    **Note:** The jsonp files can be accessed from the `dist/labels/jsonp` folder that is published in the [npm module](https://www.npmjs.com/package/@okta/okta-signin-widget).

  - `rewrite` (Function) - You can use this function to rewrite the asset path and filename. Use this function if you will host the asset files on your own host, and plan to change the path or filename of hte assets. This is useful, for example, if you want to cachebust the files.

    ```javascript
    assets: {
      // Note: baseUrl is still needed to set the base path
      baseUrl: '/path/to/jsonp',

      rewrite: function (assetPath) {
        // assetPath is relative to baseUrl
        // Example to load login for 'ja': /labels/jsonp/login_ja.jsonp
        return someCacheBustFunction(assetPath);
      }
    }
    ```

### Hooks around username and password

- `username` (String) - Prefills the username input with the provided username

    Example: *"john@acme.com"*

- `transformUsername` (Function) - Transforms the username before sending the auth request to Okta. This is useful when you have an internal mapping between what the user enters and their Okta username.

    ```javascript
    // Passed two arguments - username and operation:
    // 1) username: The name entered by the user
    // 2) operation: The type of operation the user is trying to perform:
    //      - PRIMARY_AUTH
    //      - FORGOT_PASSWORD
    //      - UNLOCK_ACCOUNT
    transformUsername: function (username, operation) {
      // This example will append the '@acme.com' domain if the user has
      // forgotten to type it
      return username.indexOf('@acme.com') > -1
        ? username
        : username + '@acme.com';
    }
    ```

- `processCreds` (Function) - Synchronous hook to handle the credentials before they are sent to Okta in the Primary Auth, Password Expiration, and Password Reset flows.

    ```javascript
    // Passed a creds object {username, password}
    processCreds: function (creds) {
      // This example demonstrates a partial integration with ChromeOS
      google.principal.add({
        token: creds.username,
        user: creds.username,
        passwordBytes: creds.password,
        keyType: 'KEY_TYPE_PASSWORD_PLAIN'
      });
    }
    ```

### Customizing help links

You can override the link urls on the Primary Auth page by setting the following config options. If you'd like to change the text, use the `i18n` config option.

```javascript
// An example that overrides all help links, and sets two custom links
helpLinks: {
  help: 'https://acme.com/help',
  forgotPassword: 'https://acme.com/forgot-password',
  unlock: 'https://acme.com/unlock-account',
  custom: [
    {
      text: 'What is Okta?',
      href: 'https://acme.com/what-is-okta'
    },
    {
      text: 'Acme Portal',
      href: 'https://acme.com'
    }
  ]
}
```

- `helpLinks`
  - `help` (String) - Custom link href for the "Help" link
  - `forgotPassword` (String) - Custom link href for the "Forgot Password" link
  - `unlock` (String) - Custom link href for the "Unlock Account" link. **Note:** `features.selfServiceUnlock` must be set to `true`, and the self service unlock feature must be enabled in your admin settings.
  - `custom` (Array) - Array of custom link objects that will be added to the "Need help signing in?" section.

### Feature flags

Enable or disable widget functionality with the following options. **Note:** Some of these features require additional configuration in your Okta admin settings.

```javascript
// An example that enables the autoPush and multiOptionalFactorEnroll features
features: {
  autoPush: true,
  multiOptionalFactorEnroll: true
}
```

- `features`
  - `router` (Boolean) - Set to `true` if you want the widget to update the navigation bar when it transitions between pages. This is useful if you want the user to maintain their current state when refreshing the page, but requires that your server can handle the widget url paths. Defaults to `false`.
  - `rememberMe` (Boolean) - Display a checkbox to enable "Remember me" functionality at login. Defaults to `true`.
  - `autoPush` (Boolean) - Display a checkbox to enable "Send push automatically" functionality in the MFA challenge flow. Defaults to `false`.
  - `smsRecovery` (Boolean) - Allow users with a configured mobile phone number to recover their password using an SMS message. Defaults to `false`.
  - `callRecovery` (Boolean) - Allow users with a configured mobile phone number to recover their password using a voice call. Defaults to `false`.
  - `windowsVerify` (Boolean) - Display instructions for enrolling a windows device with Okta Verify. Defaults to `false`.
  - `selfServiceUnlock` (Boolean) - Display the "Unlock Account" link to allow users to unlock their accounts. Defaults to `false`.
  - `multiOptionalFactorEnroll` (Boolean) - Allow users to enroll in multiple optional factors before finishing the auth flow. Default behavior is to force enrollment of all required factors and skip optional factors. Defaults to `false`.


### Social auth, oidc

- `authScheme`
- `authParams`
  - `display`
  - `responseMode`
  - `responseType`
  - `scopes`
- `clientId`
- `redirectUri`
- `idps`
- `idpDisplay`
- `oAuthTimeout`

### Bootstrapping from a recovery token

- `recoveryToken`


## Developing the Sign-In Widget