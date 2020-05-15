import { loc } from 'okta';
import BaseView from '../../internals/BaseView';
import BaseForm from '../../internals/BaseForm';
import BaseFactorView from '../shared/BaseFactorView';

const Body = BaseForm.extend({
  title: function () {
    return loc('enroll.password.setup', 'login');
  },
  save: function () {
    return loc('save.password', 'login');
  },

  getUISchema () {
    const uiSchemas = BaseForm.prototype.getUISchema.apply(this, arguments);
    // TODO: need to re-order.
    return uiSchemas.concat([
      {
        name: 'credentials.question',
        label: 'Create security question',
        type: 'text',
        showWhen: {
          'credentials.questionMode': 'custom'
        }
      }
    ]);
  }
});

export default BaseFactorView.extend({

  Body,

  initializeModel () {
    const model = BaseView.prototype.initializeModel.apply(this, arguments);
    model.set('credentials.questionMode', 'suggested');
    return model;
  }
});
