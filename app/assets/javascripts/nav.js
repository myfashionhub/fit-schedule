function Navigation(pathname, tabs, ul, sectionSelector) {

  var that = this;
  var navLinks = ul.find('a');
  var cal = new Calendar();
  var availability = new Availability();

  this.pathname = pathname;

  this.init = function() {
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
    } else {
      window.location.hash = '#' + tabs[0];
    }
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
      availability.getUserAvailability();
    }
  };

  this.init();
}


function toggleByPath() {
  var path = window.location.pathname.replace('/','');
  $('nav .options a.'+path).addClass('active');
};
