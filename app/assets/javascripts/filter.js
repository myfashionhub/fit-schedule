function Filter() {

  var that = this;
  this.filters = [];
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

    $('.save-filters').click(function() { that.updateUserPreferences(); });
  };

  // see calendar events: '/calendars/events?id=v.nessa.nguyen@gmail.com'

  this.init();

}
