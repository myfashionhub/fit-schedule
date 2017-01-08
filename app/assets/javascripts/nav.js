function Navigation(pathname, tabs, ul, sectionSelector) {

  var that = this;
  var navLinks = ul.find('a');
  var cal = new Calendar();

  this.pathname = pathname;

  this.init = function() {
    this.toggleByPath();
    this.toggleByHash();

    $(window).on('hashchange', function() {
      if (window.location.pathname === that.pathname) {
        that.toggleByHash();
      }
    });
  };

  this.toggleByHash = function() {
    if (window.location.hash !== '') {
      var index = tabs.indexOf( window.location.hash.replace('#','') );
      if (index > -1) {
        that.toggle(index);
        return;
      }
    }
    this.toggle(0);
  };

  this.toggle = function(index) {
    $(sectionSelector+'.active').removeClass('active');
    ul.find('a.active').removeClass('active');

    $(navLinks[index]).addClass('active');
    var targetSection = $($(sectionSelector)[index]);
    targetSection.addClass('active');

    if (targetSection.hasClass('calendars')) {
      cal.getAllCalendars();
    } else if (targetSection.hasClass('availability')) {
      cal.getUserAvailability();
    }
  };

  this.toggleByPath = function() {
    var path = window.location.pathname.replace('/','');
    $('nav .options a.'+path).addClass('active');
  };

  this.init();
}
