function Filter() {
  var that = this;
  this.filters = [];

  this.init = function() {
    this.select();
    this.apply();

    $('.save-filters').click(function() { that.updateUserPreferences(); });
  };

  this.updateUserAvailability = function() {
    // Save user availability as json string
  };
  
  this.showUserPreferences = function() {
    // Pre-check filters saved for user
  };

  this.updateUserPreferences = function() {
    var studioId = $('.classes .studio').attr('data-id');

    $.ajax({
      url: '/filters',
      type: 'POST',
      data: { filters: JSON.stringify(that.filters), studio_id: studioId },
      success: function(data) {
        console.log(data);
      },
      error: function(data) {
        console.log(data);
      }
    });
  };

  this.select = function() {
    // toggle selected class names & modify filter array

    $('.class .checkbox').click(function(e) {
      var classLi   = $(e.target).parent().parent();
      var className = classLi.find('.name').html();
      var checkbox  = classLi.find('.checkbox');

      if (classLi.attr('class').indexOf('selected') > 0) {
        classLi.removeClass('selected');
        checkbox.empty().html("<i class='fa fa-square-o'></i>");

        _.each(that.filters, function(filter) {
          if (filter.class_name == className) {
            var i = that.filters.indexOf(filter);
            that.filters.splice(i, 1);
            return;
          }
        });
      } else {
        classLi.addClass('selected');
        checkbox.empty().html("<i class='fa fa-check-square-o'></i>");

        var exist = false;
        _.each(that.filters, function(filter) {
          if (filter.class_name == className) {
            exist = true; return;
          }
        });

        if (!exist) {
          var filter = { class_name: className };
          that.filters.push(filter);
        }
      }
    });
  };

  this.apply = function() {
    $('.customize-wrapper .suggested-classes').click(function(e) {
      e.preventDefault();
      var studioId = $('.studio').attr('data-id');

      $.ajax({
        url: '/filters/show?studio_id='+studioId,
        type: 'GET',
        success: function(data) {
          console.log(data);
          if (data.classes.error !== undefined) {
            window.alert(data.classes.error);
            window.location.href = '/welcome';
          }          
        },
        error: function(data) {
          console.log(data);
        }
      });
    });
  };

  // see calendar events: '/calendars/events?id=v.nessa.nguyen@gmail.com'

  this.init();

}
