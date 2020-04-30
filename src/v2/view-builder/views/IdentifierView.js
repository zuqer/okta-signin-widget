import { $, View, loc, createButton } from 'okta';
import BaseView from '../internals/BaseView';
import BaseForm from '../internals/BaseForm';
import BaseFooter from '../internals/BaseFooter';
import { fetchRequest } from '../../ion/httpClient';
import Util from '../../../util/Util';

const Body = BaseForm.extend({

  title: loc('primaryauth.title'),
  save: loc('oform.next', 'login'),
  initialize () {
    BaseForm.prototype.initialize.apply(this, arguments);
    if (this.options.appState.hasRemediationForm('launch-authenticator')) {
      this.add(View.extend({
        className: 'sign-in-with-device-option',
        template: `
          <div class="okta-verify-container"></div>
          <div class="separation-line"><span>OR</span></div>
        `,
        initialize () {
          // const appState = this.options.appState;
          this.add(createButton({
            className: 'button-secondary',
            title: 'Sign in using Okta Verify',
            click () { 
              // appState.trigger('invokeAction', 'launch-authenticator');
              const rem = this.options.appState.get('rawIdxState').remediation.value
              .filter(v => v.name === 'launch-authenticator')[0];
              // fetchRequest(
              //   rem.href,
              //   rem.method,
              //   { stateHandle: rem.value[0].value }
              // )
              // .then((resp) => {
              //   const response = resp.response;
              //   const deviceChallenge = response[
              //     resp.response.remediation.value.filter(v => v.name === 'device-challenge-poll')[0].relatesTo
              //   ];
              //   Util.redirect(deviceChallenge.value.href);
              // });
              $.ajax({
                url: rem.href,
                method: rem.method,
                contentType: 'application/json',
                data: JSON.stringify({ stateHandle: rem.value[0].value }),
              })
              .then((resp) => {
                const deviceChallenge = resp[
                  resp.remediation.value.filter(v => v.name === 'device-challenge-poll')[0].relatesTo
                ];
                Util.redirect(deviceChallenge.value.href);
              });
            }
          }), '.okta-verify-container');
        }
      }), '.o-form-fieldset-container', false, true);
    }
  }
});

const Footer = BaseFooter.extend({
  links () {
    const baseUrl = this.options.settings.get('baseUrl');
    let href = baseUrl + '/help/login';
    if (this.options.settings.get('helpLinks.help') ) {
      href = this.options.settings.get('helpLinks.help');
    }
    const signupLinkObj = {
      'type': 'link',
      'label': 'Sign up',
      'name': 'enroll',
      'actionPath': 'select-enroll-profile',
    };
    const links = [
      {
        'name': 'help',
        'label': 'Need help signing in?',
        'href': href,
      },
    ];
    if (this.options.appState.hasRemediationForm('select-enroll-profile')) {
      links.push(signupLinkObj);
    }
    return links;
  }
});

export default BaseView.extend({
  Body,
  Footer,
});
