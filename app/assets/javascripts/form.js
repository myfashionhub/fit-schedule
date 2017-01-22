function Form(selector, options={}) {
  this.el = $(selector);

  this.init = function() {

  };

  // This should only be called once
  this.addEventListeners = function(){
    this.onSubmit();
    this.onCancel();
  }

  this.focusOnInput = function() {
    this.el.find('input').focus();
  };

  this.clearInput = function() {
    this.el.find('input').val() = '';
  };

  this.onSubmit = function() {
    this.el.submit(function(e) {
      e.preventDefault();
      options.submitCallback();
    });
  }

  this.onCancel = function() {
    this.el.find(options.cancelClass).click(function(e) {
      console.log('Form cancel')
      e.preventDefault();
      this.options.cancelCallback();
    });
  };

  this.init();
}
