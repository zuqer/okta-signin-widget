<!DOCTYPE html>
<html>

<head>
  <title>Okta Sign-in Widget</title>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0" />
  <script
  src="https://code.jquery.com/jquery-3.2.1.min.js"
  integrity="sha256-hwg4gsxgFZhOsEEamdOYGBf13FyQuiTwlAQgxVSNgt4="
  crossorigin="anonymous"></script>
  <link href="https://maxcdn.bootstrapcdn.com/bootstrap/4.0.0-beta/css/bootstrap.min.css" rel="stylesheet">
  <script src="https://maxcdn.bootstrapcdn.com/bootstrap/4.0.0-beta/js/bootstrap.min.js"></script>
  <style>
    body {
      padding-top: 40px;
      padding-bottom: 40px;
      background-color: #eee;
    }

    #overlay {
      background-color: #eee;
      position: fixed;
      width: 100%;
      height: 100%;
      left: 0;
      top: 0;
      z-index: 10;
    }

    .form-signin {
      max-width: 330px;
      padding: 15px;
      margin: 0 auto;
    }
    .form-signin .form-signin-heading,
    .form-signin .checkbox {
      margin-bottom: 10px;
    }
    .form-signin .checkbox {
      font-weight: normal;
    }
    .form-signin .form-control {
      position: relative;
      height: auto;
      -webkit-box-sizing: border-box;
              box-sizing: border-box;
      padding: 10px;
      font-size: 16px;
    }
    .form-signin .form-control:focus {
      z-index: 2;
    }
    .form-signin input[type="email"] {
      margin-bottom: -1px;
      border-bottom-right-radius: 0;
      border-bottom-left-radius: 0;
    }
    .form-signin input[type="password"] {
      margin-bottom: 10px;
      border-top-left-radius: 0;
      border-top-right-radius: 0;
    }
    .auth-footer {
      max-width: 330px;
      padding: 15px;
      margin: 0 auto;
    }
    [name="remember"] {
      margin-right: 5px;
    }
  </style>
</head>

<body>
  <div id="okta-login-container"></div>

  <script src="js/okta-sign-in.js"></script>
  <script type="text/javascript">
    var options = {{{options}}};
    delete options.logo;
    options.hooks = {
      primaryAuth: {
        postRender: function () {
          setTimeout(() => {
            $('.primary-auth-form').addClass('form-signin');
            $('#okta-signin-username').addClass('form-control');
            $('#okta-signin-password').addClass('form-control');
            $('.custom-checkbox').addClass('checkbox');
            $('[data-se-for-name="remember"]').text(' Remember me');
            $('#okta-signin-submit').addClass('btn btn-lg btn-primary btn-block');
            $('#overlay').hide();
          });
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
  <div id="overlay"></div>
</body>

</html>
