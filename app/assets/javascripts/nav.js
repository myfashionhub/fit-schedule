function Navigation(ul, sectionSelector) {

  var that = this;
  var navLis = ul.find('li');

  this.init = function() {
    $(sectionSelector).first().addClass('active');
    navLis.first().addClass('active');

    this.toggle();
  };

  this.toggle = function() {
    navLis.click(function(e) {
      var index = navLis.index(e.target);
      
      $(sectionSelector+'.active').removeClass('active');
      ul.find('li.active').removeClass('active');

      $(e.target).addClass('active');
      $($(sectionSelector)[index]).addClass('active');      
    });
  };

  this.init();
}
