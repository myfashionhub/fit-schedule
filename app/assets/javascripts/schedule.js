function Schedule() {
  var that = this;

  this.init = function() {

  };

  this.getClasses = function() {
    $.ajax({
      url: '/appointments',
      type: 'GET',
      success: function(data) {
        console.log(data);
        that.populateClasses(data.classes, $('.current-schedule'));
      },
      error: function(data) {
        console.log(data);
      }
    });
  };

  this.populateClasses = function(classes, el) {
    for (var i=0; i < classes.length; i++) {
      var classLi = $('<li>').addClass('class'),
          
          name = $('<span>').addClass('title').html(classes[i].name),

          time = $('<span>').addClass('time').
                   html(classes[i].start_time+' - '+classes[i].end_time),

          date = $('<span>').addClass('date').html(formatDate(classes[i].date)),
                   
          instructor = $('<span>').addClass('instructor').
                         html(classes[i].instructor);

      classLi.append(date).append(name).append(time).append(instructor);
      el.append(classLi);
    }
  };

  this.saveAppointments = function() {

  };

  this.suggestClasses = function() {
    // Suggest all classes from user's favorite studios
    $.ajax({
      url: '/filters/apply',
      type: 'GET',
      success: function(data) {
        if (data.error != undefined) {
          window.alert(data.error);
          window.location.href = '/';
        } else {
          that.populateClasses(
            data.classes, $('.schedule-wrapper .suggested-classes')
          );
        }
      },
      error: function(data) {
        console.log(data);
      }
    });
  };

  var formatDate = function(dateStr) {
    var date = new Date(dateStr);
    return dayLookup(date.getUTCDay()) + ', ' + 
           monthLookup(date.getUTCMonth()) + ' ' + date.getUTCDate();
  };

  var dayLookup = function(num) {
    var dict = {
      0: 'Sun', 1: 'Mon', 2: 'Tue', 3: 'Wed',
      4: 'Thu', 5: 'Fri', 6: 'Sat' 
    }

    return dict[num];
  }

  var monthLookup = function(num) {
    var dict = { 
      0: 'January', 1: 'February', 2: 'March', 3: 'April', 4: 'May', 5: 'June',
      6: 'July', 7: 'August', 8: 'September', 9: 'October', 10: 'November',
      11: 'December'
    };

    return dict[num] 
  }

  this.init();
}
