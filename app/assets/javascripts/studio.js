function Studio() {

  var that = this;
  this.user_id = $('#user').attr('data-id');
  var notify = new Notify();

  this.init = function() {

  };

  this.findOrCreate = function() {
    $('.studio-form form').submit(function(e) {
      e.preventDefault();
      var url = $('.studio-form .url').val();

      $.ajax({
        url: '/studios',
        type: 'POST',
        data: { url: url },
        success: function(data) {
          that.populateStudio(data.studio);
          that.getStudioClassTypes(data.studio.id);
          $('.studio-show').addClass('active');
        },
        error: function(err) {
          console.log(err);
          notify.build('Unable to get classes from schedule URL.', 'error');
        }
      });
    });
  };

  this.populateStudio = function(studio) {
    $('a.name').attr('href', studio.schedule_url).
      attr('target','_blank').html(studio.name);

    var studioEl = $('.studio-show .studio');
    studioEl.attr('data-id', studio.id);
    studioEl.find('.address').html(studio.address);
  };

  this.allClasses = function(studio_id, studioContainer) {
    $.ajax({
      url: '/classes',
      type: 'GET',
      data: { studio_id: studio_id },
      success: function(data) {
        that.populateClasses(data.classes, studioContainer);
      },
      error: function(err) {
        console.log(err);
      }
    });
  };

  this.populateClasses = function(classes, container) {
    container.empty();
    _.sortBy(classes, function(klass) {
      return klass.date || klass.start_time;
    });

    var dates = _.pluck(classes, 'date'),
        currentDate = dates[0],
        dateCounter = 0;

    var firstDate = $('<li>').addClass('date').html(convertDate(currentDate));
        container.append(firstDate);

    for (var i=0; i < classes.length; i++) {
      if (classes[i].date !== currentDate) {
        currentDate = classes[i].date;
        dateCounter = 0;
      } else {
        dateCounter += 1;
      }

      if (dateCounter === 0) {
        var dateLi = $('<li>').addClass('date').
                     html(convertDate(currentDate));
        container.append(dateLi);
      }

      var start_time = classes[i].start_time,
          end_time   = classes[i].end_time;
      if (start_time.split(' ')[1] === end_time.split(' ')[1]) {
        start_time = start_time.split(' ')[0];
      }

      var classLi = $('<li>').addClass('class'),
          name    = $('<span>').addClass('title').html(classes[i].name),
          time    = $('<span>').addClass('time').
                    html(start_time + ' - ' + end_time)
          instructor = $('<span>').addClass('instructor').
                         html(classes[i].instructor);
      classLi.append(time).append(name).append(instructor);
      container.append(classLi);
    }
  };

  this.getStudioClassTypes = function(studio_id, populateStudio) {
    $.ajax({
      url: '/studios/'+studio_id,
      type: 'GET',
      success: function(data) {
        if (populateStudio) {
          that.populateStudio(data.studio);
        }
        populateClassTypes(data.unique_classes, studio_id);
      },
      error: function(err) {
        console.log(err);
      }
    });

    var populateClassTypes = function(classTypes, studio_id) {
      var filter = new Filter();
      var userFilters;

      Promise.all([ filter.show(studio_id) ]).then(
        function(data) {
          buildFilters(data[0]);
        }
      );

      var buildFilters = function(userFilters) {
        $('.class-types').empty();

        for (var i=0; i < classTypes.length; i++) {
          var classLi = $('<li>').addClass('class');
          var name = $('<span>').addClass('name').html(classTypes[i]);

          var selectedFilter = _.detect(userFilters, function(filter) {
            return filter.class_name == classTypes[i];
          });

          var checkbox = $('<span>').addClass('checkbox');
          if (selectedFilter != undefined) {
            checkbox.addClass('selected').
              html("<i class='fa fa-check-square-o'></i>");
          } else {
            checkbox.html('<i class="fa fa-square-o"></i>');
          }

          classLi.append(checkbox).append(name);
          $('.class-types').append(classLi)
        }

        filter.select(); // event listener for checking boxes
      };
    }
  };

  var convertDate = function(dateObj) {
    var date = new Date(dateObj);
    return date.toDateString().replace(' ',', ').replace(/\s\d{4}/i, '');
  };

  this.showFavorites = function() {
    $.ajax({
      url: '/users/'+that.user_id+'/studios',
      type: 'GET',
      success: function(data) {
        that.populateStudios(data.studios);
      },
      error: function(err) {
        console.log(err);
      }
    });
  };

  this.populateStudios = function(studios) {
    var studioUl = $('.favorite-studios .studios');

    for (var i=0; i < studios.length; i++) {
      var studioLi   = $('<li>').addClass('studio');
      var studioName = $('<h4>').html(studios[i].studio.name).
                         attr('data-id', studios[i].studio.id);
      var classes    = $('<ul>').addClass('class-list');
      var editBtn = $("<i class='fa fa-pencil-square-o'></i>").addClass('edit').
                      attr('title', 'Edit classes');
      var showBtn = $("<i class='fa fa-list'></i>").addClass('show').
                      attr('title', 'Show all classes');
      var removeBtn = $("<i class='fa fa-times'></i>").addClass('remove').
                        attr('title', 'Remove from favorites');

      studioLi.append(studioName);
      studioLi.append(editBtn);
      studioLi.append(showBtn);
      studioLi.append(removeBtn);
      studioLi.append(classes);
      studioUl.append(studioLi);
    }

    this.listenForButtonClick();
  };

  this.listenForButtonClick = function() {
    $('.studio i').click(function(e) {
      var studio_id = $(e.target).parent().find('h4').attr('data-id');
      var btnClass = $(e.target).attr('class');

      if (btnClass.indexOf('edit') > -1) {
        that.toggleEditStudio(studio_id);
      } else if (btnClass.indexOf('show') > -1) {
        var studioContainer = $(e.target).parent().find('.class-list');
        studioContainer.toggleClass('show');
        that.allClasses(studio_id, studioContainer);
      } else if (btnClass.indexOf('remove') > -1) {
        that.removeStudio(studio_id);
      }
    });
  };

  this.toggleEditStudio = function(studio_id) {
    that.getStudioClassTypes(studio_id, true);

    var modal = new Modal($('.studio-show'));
    modal.el().addClass('big');
  };

  this.removeStudio = function(studio_id) {
    var modal = new Modal($('.studio-remove'));
  };

  this.init();

}
