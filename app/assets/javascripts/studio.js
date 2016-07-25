function Studio() {

  var that = this;
  this.user_id = $('#user').attr('data-id');
  var notify = new Notify();

  this.init = function() {

  };

  this.getClasses = function() {
    $('.studio-form form').submit(function(e) {
      e.preventDefault();
      var url = $('.studio-form .url').val();

      $.ajax({
        url: '/classes',
        type: 'POST',
        data: { url: url },
        success: function(data) {
          that.populateStudio(data.studio);
          that.getStudioClassTypes(data.studio.id);
          $('.studio-show').addClass('active');
          // that.populateClasses(data.classes); all classes of a studio
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

  this.populateClasses = function(classes) {
    _.sortBy(classes, function(klass) {
      return klass.date || klass.start_time;
    });

    var dates = _.pluck(classes, 'date'),
        currentDate = dates[0],
        dateCounter = 0;
    
    var firstDate = $('<li>').addClass('date').html(convertDate(currentDate));
        $('.classes .schedule').append(firstDate);

    for (var i=0; i < classes.length; i++) {
      if (classes[i].date !== currentDate) {
        currentDate = classes[i].date;
        dateCounter = 0;
      } else {
        dateCounter += 1;
      }

      if (dateCounter === 0) {
        var dateLi = $('<li>').addClass('date').html(convertDate(currentDate));
        $('.classes .schedule').append(dateLi);
      }

      var classLi = $('<li>').addClass('class'),
          name = $('<span>').addClass('title').html(classes[i].name),
          time = $('<span>').addClass('time').
                   html(classes[i].start_time+' - '+classes[i].end_time)
          instructor = $('<span>').addClass('instructor').
                         html(classes[i].instructor);
      classLi.append(name).append(time).append(instructor);
      $('.classes .schedule').append(classLi);
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
      )

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
        if ( data.studios.length === 0 ) {
          $('.schedule-wrapper .suggested-classes .empty').addClass('active');
        }
        that.populateStudios(data.studios);
      },
      error: function(err) {
        console.log(err);
      }
    });
  };

  this.populateStudios = function(studios) {
    var studioUl = $('.schedule-wrapper .favorite-studios .studios');

    for (var i=0; i < studios.length; i++) {
      var studioLi = $('<li>').addClass('studio');
      var studioName = $('<h4>').html(studios[i].studio.name).
                         attr('data-id', studios[i].studio.id);
      var editButton = $("<i class='fa fa-pencil-square-o'></i>").addClass('edit')

      // var filters = studios[i].filters;
      // var filterUl = $('<ul>');
      // for (var j=0; j < filters.length; j++) {
      //   var filterLi = $('<li>').html(filters[j].class_name);
      //   filterUl.append(filterLi)
      // }

      studioName.append(editButton);
      studioLi.append(studioName);
      studioUl.append(studioLi);

      editButton.click(function(e) { that.toggleEditStudio(e); });
    }
  };

  this.toggleEditStudio = function(e) {
    var studio_id = $(e.target).parent().attr('data-id');
    this.getStudioClassTypes(studio_id, true);

    var modal = new Modal($('.studio-show'));
    modal.el().addClass('big');
  };

  this.init();

}
