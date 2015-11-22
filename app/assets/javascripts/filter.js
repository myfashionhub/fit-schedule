function Filter() {

  var that = this;
  this.user_id = $('#user').attr('data-id');

  this.init = function() {

  };

  this.updateUserAvailability = function() {
    // Save user availability as json string
  };
  
  this.showUserPreferences = function(studio_id) {
    // Pre-check filters saved for user
    var filtersPromise = new Promise(function(resolve, reject) {
      $.ajax({
        url: '/users/'+that.user_id+'/filters?studio_id='+studio_id,
        type: 'GET',
        success: function(data) {
          resolve(data.filters);
        },
        error: function(err) {
          reject(err);
          console.log(err);
        }
      });
    });

    return filtersPromise;
  };

  this.updateUserPreferences = function() {
    var studio_id = $('.classes .studio').attr('data-id');
    var classNames = [];

    _.each($('.class-types .class'), function(classLi) {
      var checkbox = $(classLi).find('.checkbox');

      if (checkbox.attr('class').indexOf('selected') > -1) {
        var className = $(classLi).find('.name').html();
        classNames.push(className);
      }
    });

    $.ajax({
      url: '/filters',
      type: 'POST',
      data: {
        class_names: JSON.stringify(classNames),
        studio_id: studio_id
      },
      success: function(data) {
        var studioName = $('.classes .studio .name a').html();
        console.log('Successfully saved your preferences for '+studioName);
      },
      error: function(data) {
        console.log(data);
      }
    });
  };

  this.select = function() {
    // toggle selected class names

    $('.class .checkbox').click(function(e) {
      var checkbox  = $(e.target).parent();
      console.log(checkbox)
      if (checkbox.attr('class').indexOf('selected') > 0) {
        checkbox.removeClass('selected');
        checkbox.empty().html("<i class='fa fa-square-o'></i>");
      } else {
        checkbox.addClass('selected');
        checkbox.empty().html("<i class='fa fa-check-square-o'></i>");
      }
    });

    $('.save-filters').click(function() { that.updateUserPreferences(); });
  };

  // see calendar events: '/calendars/events?id=v.nessa.nguyen@gmail.com'

  this.init();

}
