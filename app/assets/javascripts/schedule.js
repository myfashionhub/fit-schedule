function Schedule() {
  var that = this;
  var notify = new Notify();
  this.user_id = $('#user').attr('data-id');

  this.init = function() {
    $('.upcoming .save-appointments').click(function() {
      that.saveAppointments();
    });
  };

  this.getAppointments = function() {
    $.ajax({
      url: '/users/'+ that.user_id +'/appointments',
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
      var classLi = this.buildClass(classes[i], classState);

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
    }
  };

  this.buildClass = function(classObj, classState) {
    var studioUrl = classObj.studio_url;
    if ( studioUrl.indexOf('fitreserve.com') > -1 ) {
      studioUrl += '?tab=schedule';
    }

    var classLi = $('<li>').addClass('class').attr('data-id', classObj.id),
        name = $('<span>').addClass('title').html(classObj.name),
        time = $('<span>').addClass('time').
                 html(classObj.start_time+' - '+classObj.end_time),
        studioEl = $('<span>').addClass('studio'),
        instructor = $('<span>').addClass('instructor').
                       html(classObj.instructor),
        action = $('<button>').addClass('action'),
        studio = $('<a>').attr('href', studioUrl).
                   attr('target', '_blank').html(classObj.studio_name);

    if (classState == 'added') {
      action.addClass('remove').
        html("Remove <i class='fa fa-times'></i>");
    } else {
      action.addClass('add').html("Add class");
    }

    studioEl.wrapInner(studio);
    classLi.append(name).append(time).append(studioEl).
      append(instructor).append(action);

    action.click(function(e) { 
      var action = $(this);
      if (e.target !== this) {
        action = $(e.target).parent();
      }
      that.selectClass(action); 
    });
    return classLi;
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
      url: '/users/'+ that.user_id +'/appointments',
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

  this.selectClass = function(action) {
    var classLi = action.parent();

    if (action.attr('class').indexOf('add') > -1) {
      this.cloneClass(classLi, action);
    }
    else if (action.attr('class').indexOf('remove') > -1) {
      var classBlock = classLi.parent();
      classLi.remove();
      if ( classBlock.find('.class').length === 0 ) {
        classBlock.remove();
      }
    }

    this.saveButtonState();
  };

  this.cloneClass = function(classLi, action) {
    var classBlock = classLi.parent();
    var clonedBlock, clonedClass;

    var existingClass = _.detect(
      $('.upcoming .classes li'),
      function(bookedClass) {
        return $(bookedClass).attr('data-id') == classLi.attr('data-id');
      }
    );

    if (existingClass === undefined) {
      clonedClass = classLi.clone(true, true);
      clonedClass.find('.action').removeClass('add').addClass('remove').
        html("Remove <i class='fa fa-times'></i>");
    } else {
      notify.build('The class is already in your schedule.', 'info');
      return;
    }

    var originalHeading = classLi.parent().find('.heading');
    var clonedHeading = _.detect(
      $('.upcoming .heading .date'),
      function(dateEl) {
        return $(dateEl).html() === originalHeading.find('.date').html();
      }
    );

    var addToSchedule = function(clonedBlock, clonedClass) {
      var classTimes = clonedClass.find('.time').html().split(' ');
      classTimes = [classTimes[0].replace(':', '.'), classTimes[3].replace(':', '.')];

      _.each(clonedBlock.find('.class'), function(classLi) {
        var times = $(classLi).find('.time').html().split(' ');
        times = [times[0].replace(':', '.'), times[3].replace(':', '.')];

        // New class ends before or starts after another class
        if (classTimes[1] < times[0]) {
          clonedClass.insertBefore($(classLi));
          return;
        }
        else if (classTimes[0] > times[1]) {
          clonedClass.insertAfter($(classLi));
          return;
        }
        else {
          notify.build('This class conflicts with another in your schedule', 'error');
          return
        }
      });
    };

    if (clonedHeading === undefined) {
      clonedBlock = $('<div>').addClass('block');
      clonedHeading = originalHeading.clone(true, true);
      clonedBlock.append(clonedHeading).append(clonedClass).
        appendTo($('.upcoming .classes'));
    } else {
      clonedBlock = $(clonedHeading).parent().parent();
      addToSchedule(clonedBlock, clonedClass);
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
      url: '/users/'+ that.user_id +'/classes',
      type: 'GET',
      success: function(data) {
        if (data.error != undefined) {
          notify.build(data.error, 'error');
          setTimeout(function() {
            var session = new Session('/');
            session.destroy();
          }, 1000);
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
