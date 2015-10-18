function Filter() {
  var that = this;

  this.init = function() {

  };

  this.updateUserAvailability = function() {
    // Save user availability as json string
  };
  
  this.updateUserPreferences = function() {
    var filters; // All classes chosen

    $.ajax({
      url: '/filters',
      type: 'POST',
      data: { filters: filters },
      success: function(data) {
        console.log(data);
      },
      error: function(data) {
        console.log(data);
      }
    });
  };

  this.apply = function() {
    $('.suggested-classes').click(function() {
      var studioId = $('.studio').attr('data-id');
      
      $.ajax({
        url: '/filters/apply?studio_id='+studioId,
        type: 'GET',
        success: function(data) {
          console.log(data);
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
