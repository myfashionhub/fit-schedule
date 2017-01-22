function Modal(element) {
  var that = this;

  this.el = function() {
    return $('.modal-dialog');
  }

  this.init = function() {
    this.contentEl = element.clone(true, true);
    $('.modal-dialog .close').click(function() {
      that.close();
    });
  };

  this.open = function() {
    $('.overlay').addClass('active');
    $('.modal-dialog').addClass('active');
    $('body').addClass('no-scroll');

    this.el().find('.content').append(that.contentEl);
    that.contentEl.addClass('active');
  };

  this.close = function() {
    $('.overlay').removeClass('active');
    $('.modal-dialog').removeClass('active');
    $('body').removeClass('no-scroll');
    $('.modal-dialog .content').empty();
  };

  this.init();
}


function Notify(el) {
  var that = this;

  this.init = function() {
    this.el = el || $('.notify');
    this.el.find('.close').click(function() { that.close(); });
  };

  this.build = function(msg, type) {
    var top = document.body.scrollTop < 60 ? 60 : (document.body.scrollTop + 10);
    this.el.css('top',  top+'px');
    this.el.find('.content').html(msg);
    this.el.addClass(type).addClass('active');

    setTimeout(function() {
      that.close(type);
    }, 2500);
  };

  this.close = function(type) {
    this.el.find('.content').empty();
    this.el.removeClass(type).removeClass('active');
  }

  this.init();
}
