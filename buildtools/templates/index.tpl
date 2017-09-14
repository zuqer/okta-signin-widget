<!DOCTYPE html>
<html>

<head>
  <title>Okta Sign-in Widget</title>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0" />
  <link href="css/okta-sign-in.css" type="text/css" rel="stylesheet"/>
  <link href="css/okta-theme.css" type="text/css" rel="stylesheet"/>
  <script
  src="https://code.jquery.com/jquery-3.2.1.min.js"
  integrity="sha256-hwg4gsxgFZhOsEEamdOYGBf13FyQuiTwlAQgxVSNgt4="
  crossorigin="anonymous"></script>
  <script src="particles.js"></script>
  <style type="text/css">
    #particles {
      background-color: black!important;
      position: absolute;
      left: 0;
      top: 0;
      bottom: 0;
      right: 0;
      z-index: 100;
    }
    #migration-message{
      color: white;
      position: absolute;
      top: 0;
      padding: 100px 30px!important;
      text-align: center;
      left: 0;
      right: 0;
      font-size: 32px!important;
    }
    #okta-sign-in {
      overflow: hidden;
    }
  </style>
</head>

<body>
  <div id="okta-login-container"></div>
  <div id="particles-js"></div>
  <script src="js/okta-sign-in.js"></script>
  <script type="text/javascript">

    function showMigrationMessage() {
      $('<div id="particles"></div>').insertAfter($('.okta-sign-in-header'));
      $('#particles').hide();
      $('#particles').fadeIn();
      $('#particles').append('<div id="migration-message">We are migrating your account, one moment please.</div>');
      particlesJS.load('particles', 'particles.json', function() {
        console.log('callback - particles.js config loaded');
      });
    }

    function hideMigrationMessage() {
      $('#particles').fadeOut();
    }

    var options = {{{options}}};
    var loginForm;
    options.processCreds = function(credentials) {
      console.log(credentials);
    },
    options.hooks = {
      primaryAuth: {
        postRender: function () {

          var view = this;
          loginForm = view.$el;
          var usernameDiv = view.$el.find('.o-form-fieldset')[0];
          $(usernameDiv).clone().html('<p>If you typically use System A, your login is your username.  Otherwise, please use your Company B email address.</p>').insertAfter(usernameDiv);
        },
        onResult: function (err, transaction) {
          var model = this;


          if (err) {
            showMigrationMessage();
            return new Promise(function(resolve, reject){
              setTimeout(function () {
                model.set('password', 'foo');
                loginForm.submit();
              }, 7000);
            })
          };
          return Promise.resolve(transaction);
        }
      }
    }
    var signIn = new OktaSignIn(options);

    signIn.renderEl(
      { el: '#okta-login-container' },

      function success(res) {
        // Password recovery flow
        if (res.status === 'FORGOT_PASSWORD_EMAIL_SENT') {
          alert('SUCCESS: Forgot password email sent');
          return;
        }

        // Unlock account flow
        if (res.status === 'UNLOCK_ACCOUNT_EMAIL_SENT') {
          alert('SUCCESS: Unlock account email sent');
          return;
        }

        // User has completed authentication (res.status === 'SUCCESS')

        // 1. Widget is not configured for OIDC, and returns a sessionToken
        //    that needs to be exchanged for an okta session
        if (res.session) {
          console.log(res.user);
          res.session.setCookieAndRedirect(options.baseUrl + '/app/UserHome');
          return;
        }

        // 2. Widget is configured for OIDC, and returns tokens. This can be
        //    an array of tokens or a single token, depending on the
        //    initial configuration.
        else if (Array.isArray(res)) {
          console.log(res);
          alert('SUCCESS: OIDC with multiple responseTypes. Check console.');
        }
        else {
          console.log(res);
          alert('SUCCESS: OIDC with single responseType. Check Console');
        }
      },

      function error(err) {
        alert('ERROR: ' + err);
      }
    );
  </script>
</body>

</html>
