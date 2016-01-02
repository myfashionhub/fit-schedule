function Schedule() {
  var that = this;
  var notify = new Notify();

  this.init = function() {
    $('.upcoming .save-appointments').click(function() {
      that.saveAppointments();
    });
  };

  this.getAppointments = function() {
    $.ajax({
      url: '/appointments',
      type: 'GET',
      success: function(data) {
        if ( data.classes.length === 0 ) {
          $('.schedule-wrapper .upcoming .empty').addClass('active');
        }
        that.populateClasses(data.classes, $('.upcoming .classes'), 'added');
      },
      error: function(err) {
        console.log(err);
      }
    });
  };

  this.populateClasses = function(classes, el, classState) {
    var dates = [];

    for (var i=0; i < classes.length; i++) {
      var studioUrl = classes[i].studio_url;
      if ( studioUrl.indexOf('fitreserve.com') > -1 ) {
        studioUrl += '?tab=schedule';
      }

      var classLi = $('<li>').addClass('class').attr('data-id', classes[i].id),
          name = $('<span>').addClass('title').html(classes[i].name),
          time = $('<span>').addClass('time').
                   html(classes[i].start_time+' - '+classes[i].end_time),
          studioEl = $('<span>').addClass('studio'),
          instructor = $('<span>').addClass('instructor').
                         html(classes[i].instructor),
          actionSpan = $('<span>').addClass('action-span'),
          action = $('<div>').addClass('action'),
          studio = $('<a>').attr('href', studioUrl).
                     attr('target', '_blank').html(classes[i].studio_name);

      if (classState == 'added') {
        action.addClass('remove').
          html("<i class='fa fa-times'></i> Remove class");
      } else {
        action.addClass('add').html("<i class='fa fa-plus'></i> Add class");
      }

      actionSpan.append(action);
      studioEl.wrapInner(studio);
      classLi.append(name).append(time).append(studioEl).
        append(instructor).append(actionSpan);

      // Build date heading & classes container
      var existingDate = _.detect(dates, function(date) {
        return date == classes[i].date;
      });

      if (existingDate === undefined) {
        dates.push(classes[i].date);
        var heading = this.buildHeading(classes[i].date);
        var container = $('<div>').addClass('block');
        container.append(heading).append(classLi).appendTo(el);
      } else {
        var index = dates.indexOf(existingDate);
        if ( index > -1 ) {
          $(el.find('.block')[index]).append(classLi);
        }
      }

      action.click(function(e) { that.selectClass(e) });
    }
  };

  this.buildHeading = function(dateValue) {
    var heading = $('<div>').addClass('heading'),
        date = $('<p>').addClass('date').html(formatDate(dateValue)),
        labelLi = $('<div>').addClass('label'),
        nameLabel = $('<span>').addClass('title').html('Class'),
        timeLabel = $('<span>').addClass('time').html('Time'),
        studioLabel = $('<span>').addClass('studio').html('Studio'),
        instructorLabel = $('<span>').addClass('instructor').html('Instructor');

    labelLi.append(nameLabel).append(timeLabel).
      append(studioLabel).append(instructorLabel);

    heading.append(date).append(labelLi);
    return heading;
  };

  this.saveAppointments = function() {
    var class_ids = _.map($('.upcoming .classes li'), function(classLi) {
      return $(classLi).attr('data-id');
    });

    $.ajax({
      url: '/appointments',
      type: 'POST',
      data: { class_ids: class_ids },
      success: function(response) {
        notify.build(response.msg, 'success');
        $('.save-appointments').addClass('disabled');
      },
      error: function(err) {
        console.log(err)
      }
    });
    // save or remove + update Google calendar
  };

  this.selectClass = function(e) {
    var action = $(e.target).parent();
    var classLi = action.parent().parent();

    if (action.attr('class').indexOf('add') > -1) {
      var existingClass = _.detect(
        $('.upcoming .classes li'),
        function(bookedClass) {
          return $(bookedClass).attr('data-id') == classLi.attr('data-id');
        }
      );

      if (existingClass === undefined) {
        var clonedLi = classLi.clone(true, true);
        clonedLi.find('.action').removeClass('add').addClass('remove').
          html("<i class='fa fa-times'></i> Remove class");
        this.addOrRemoveHeading(classLi, 'add');
        clonedLi.appendTo($('.upcoming .classes'));
      } else {
        notify.build('The class is already in your schedule.', 'info');
      }
    } else if (action.attr('class').indexOf('remove') > -1) {
      classLi.remove();
      this.addOrRemoveHeading(classLi, 'remove');
    }

    this.saveButtonState();
  };

  this.addOrRemoveHeading = function(classLi, action) {
    var headingOriginal = classLi.parent().find('.heading');
    var headingCloned = _.detect(
      $('.upcoming .heading .date'),
      function(dateEl) {
        return $(dateEl).html() === headingOriginal.find('.date').html();
      }
    );

    if ( headingCloned === undefined ) {
      if ( action === 'add' ) {
        $('.upcoming .classes').append( headingOriginal.clone(true, true) );
      }
    }
  };

  this.saveButtonState = function() {
    if ( $('.upcoming .classes li').length > 0 ) {
      $('.upcoming .empty').removeClass('active');
      $('.save-appointments').removeClass('disabled');
    } else {
      $('.save-appointments').addClass('disabled');
      $('.upcoming .empty').addClass('active');
    }
  };

  this.suggestClasses = function() {
    // Suggest all classes from user's favorite studios
    $.ajax({
      url: '/filters/apply',
      type: 'GET',
      success: function(data) {
        if (data.error != undefined) {
          window.alert(data.error);
          var session = new Session('/');
          session.destroy();
        } else {
          that.populateClasses(
            data.classes, $('.schedule-wrapper .suggested-classes .classes'), ''
          );
        }
      },
      error: function(err) {
        console.log(err);
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
  };

  var monthLookup = function(num) {
    var dict = { 
      0: 'January', 1: 'February', 2: 'March', 3: 'April',
      4: 'May', 5: 'June', 6: 'July', 7: 'August',
      8: 'September', 9: 'October', 10: 'November', 11: 'December'
    };

    return dict[num] 
  };

  this.init();
}
