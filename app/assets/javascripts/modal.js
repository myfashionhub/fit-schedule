function Modal(element) {
  var that = this;

  this.el = function() {
    return $('.modal-dialog');
  }

  this.init = function() {
    this.contentEl = element.clone(true, true);
    this.open();
    this.close();
  };

  this.open = function() {
    $('.overlay').addClass('active');
    $('.modal-dialog').addClass('active');
    $('body').addClass('no-scroll');

    this.el().find('.content').append(that.contentEl);
    that.contentEl.addClass('active');
  };

  this.close = function() {
    $('.modal-dialog i.fa-times').click(function() {
      $('.overlay').removeClass('active');
      $('.modal-dialog').removeClass('active');
      $('body').removeClass('no-scroll');
      $('.modal-dialog .content').empty();
    });
  };

  this.init();
}
