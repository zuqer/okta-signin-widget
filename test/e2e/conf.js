/*!
 * Copyright (c) 2015-2016, Okta, Inc. and/or its affiliates. All rights reserved.
 * The Okta software accompanied by this notice is provided pursuant to the Apache License, Version 2.0 (the "License.")
 *
 * You may obtain a copy of the License at http://www.apache.org/licenses/LICENSE-2.0.
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
 * WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *
 * See the License for the specific language governing permissions and limitations under the License.
 */

/* eslint no-console: 0 */
require('./env').config();

var config = {
  framework: 'jasmine2',
  specs: ['specs/*.js'],
  restartBrowserBetweenTests: false
};

// Travis sauceLabs tests
if (process.env.TRAVIS) {
  if (process.env.SAUCE_PLATFORM_NAME) {
    // Mobile emulators on sauce labs
    config.sauceUser = process.env.SAUCE_USERNAME;
    config.sauceKey = process.env.SAUCE_ACCESS_KEY;
    // Default port for Appium
    if (process.env.SAUCE_PLATFORM_NAME !== 'desktop') {
      config.port = 4723;
    }
  } else {
    // Desktop browser
    config.capabilities = {
      'browserName': 'chrome',
      'chromeOptions': {
        'args': ['--headless','--disable-gpu','--window-size=1600x1200','--no-sandbox']
      }
    };
  }

  if (process.env.SAUCE_PLATFORM_NAME === 'iOS') {
    var appiumiOS = require('./appium/ios-conf.js');
    config.multiCapabilities = appiumiOS.iosCapabilities;
  }

  else if (process.env.SAUCE_PLATFORM_NAME === 'android') {
    var appiumAndroid = require('./appium/android-conf.js');
    config.multiCapabilities = appiumAndroid.androidCapabilities;
  }

  if (process.env.SAUCE_PLATFORM_NAME === 'desktop') {
    config.capabilities =
    {
      'browserName': 'internet explorer',
      'browserVersion': 'latest',
      'platformName': 'Windows 10',
      'tunnel-identifier': process.env.TRAVIS_JOB_NUMBER,
      'build': process.env.TRAVIS_BUILD_NUMBER
    };
  }
}
// Local tests, required:
// WIDGET_TEST_SERVER
// WIDGET_BASIC_USER
// WIDGET_BASIC_PASSWORD
else {
  const webdriverManagerConfig = require('webdriver-manager/selenium/update-config.json');

  config.directConnect = true;
  config.chromeDriver = webdriverManagerConfig.chrome.last;
  config.capabilities = {
    browserName: 'chrome',
  };
}

module.exports.config = config;
