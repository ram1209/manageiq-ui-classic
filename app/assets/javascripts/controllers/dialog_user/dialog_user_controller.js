ManageIQ.angular.app.controller('dialogUserController', ['API', 'dialogFieldRefreshService', 'miqService', 'dialogId', 'apiSubmitEndpoint', 'apiAction', 'cancelEndpoint', function(API, dialogFieldRefreshService, miqService, dialogId, apiSubmitEndpoint, apiAction, cancelEndpoint) {
  var vm = this;

  vm.$onInit = function() {
    return new Promise(function(resolve) {
      resolve(API.get('/api/service_dialogs/' + dialogId, {expand: 'resources', attributes: 'content'}).then(init));
    });
  };

  function init(dialog) {
    vm.dialog = dialog.content[0];
  }

  vm.refreshField = refreshField;
  vm.setDialogData = setDialogData;
  vm.refreshUrl = '/api/service_dialogs/';

  vm.submitButtonClicked = submitButtonClicked;
  vm.cancelClicked = cancelClicked;
  vm.saveable = saveable;

  function refreshField(field) {
    return dialogFieldRefreshService.refreshField(vm.dialogData, [field.name], vm.refreshUrl, dialogId);
  }

  function setDialogData(data) {
    vm.dialogData = data.data;
  }

  function submitButtonClicked() {
    vm.dialogData.action = apiAction;
    miqService.sparkleOn();
    API.post(apiSubmitEndpoint, vm.dialogData).then(function() {
      miqService.redirectBack(__('Service ordered successfully!'), 'info', '/miq_request?typ=service');
    }).catch(function(err) {
      miqService.sparkleOff();
      add_flash(__('Error requesting data from server'), 'error');
      console.log(err);
      return Promise.reject(err);
    });
  }

  function cancelClicked(_event) {
    miqService.miqAjaxButton(cancelEndpoint);
  }

  function saveable() {
    return ! dialogFieldRefreshService.areFieldsBeingRefreshed;
  }
}]);