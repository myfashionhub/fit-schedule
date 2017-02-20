function Studio() {

  var that = this;
  this.user_id = $('#user').attr('data-id');
  var notify = new Notify();

  this.showModal = new Modal($('.studio-show'));
  this.removeModal = new Modal($('.studio-remove'));
  this.resultList = $('.studio-form .search-results');

  this.init = function() {
    this.form = new Form('#studio-schedule', {
      submitCallback: that.search,
      cancelClass: '> .cancel',
      cancelCallback: that.resetStudioForm
    });

    this.form.addEventListeners();
    this.filterActions();
  };

  this.filterActions = function() {
    $('.studio-new .cancel').click(function(e) {
      e.preventDefault();
      $('.studio-new .class-types').empty();
      $('.studio-new').removeClass('active');
      that.form.clearInput();
    });
  };

  this.search = function() {
    var val = $('.studio-form input').val();
    var query;
    if (val.indexOf('http') > -1) {
      query = {url: val};
    } else {
      query = {term: val};
    }

    $.ajax({
      url: '/studios/search',
      type: 'GET',
      data: query,
      success: function(data) {
        if (data.error) {
          that.resultList.html(data.error);
        } else {
          that.renderSearchResults(query, data);
        }
      }
    });
  };

  this.renderSearchResults = function(query, studios) {
    this.resultList.empty();

    if (studios.length === 0) {
      this.resultList.html('<h4>No studio matches your search.</h4>');
    } else {
      if (query.term) {
        var noun = studios.length > 1 ? 'results' : 'result';
        var heading = $('<h4>').html(studios.length + ' ' + noun + ' for "' + query.term + '":');
        this.resultList.append(heading);
      }
    }

    var column1 = $('<ul>');
    var column2 = $('<ul>');
    var studiosPerCol = Math.ceil(studios.length / 2);

    for (var i = 0; i < studios.length; i++) {
      var studioLi = $('<li>').attr('data-id', studios[i].id).html(studios[i].name);
      studioLi.click(function(e) {
        $('.studio-form .loading').addClass('active');

        var studio_id = $(e.target).attr('data-id');
        that.getStudioFilters(studio_id, true, '.studio-new', function() {
          $('.studio-form .loading').removeClass('active');
          $('.studio-new').addClass('active');
        });
      });

      if (i < studiosPerCol) {
        column1.append(studioLi);
      } else {
        column2.append(studioLi);
      }
    }

    this.resultList.append(column1).append(column2);
    $('.studio-form .cancel').addClass('active');
  };

  this.resetStudioForm = function() {
    $('.studio-form .cancel').removeClass('active');
    that.resultList.empty();
    that.form.clearInput();
  };

  this.populateStudio = function(studio) {
    var studioEl = $('.studio-info');

    studioEl.find('.name').attr('href', studio.schedule_url).
      attr('target','_blank').html(studio.name);
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

    if (classes.length === 0) {
      container.append('No class found for this studio.');
      return;
    }

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

  this.getStudioFilters = function(studio_id, populateStudio, classesDiv, callback) {
    $.ajax({
      url: '/studios/'+studio_id,
      type: 'GET',
      success: function(data) {
        if (populateStudio) {
          that.populateStudio(data.studio);
        }
        that.populateFilters(data.unique_classes, studio_id, classesDiv, callback);
      },
      error: function(err) {
        console.log(err);
      }
    });
  };

  this.populateFilters = function(classTypes, studio_id, classesDiv, callback) {
    var filter = new Filter();
    var userFilters;

    var buildFilters = function(userFilters) {
      var classList = $(classesDiv+' .class-types');
      classList.empty();

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
        classList.append(classLi)
      }

      filter.select(); // event listener for checking boxes
    };

    var resizeClassList = function() {
      // Dynamically resize class-types list
      var total = $('.studio-show').height();
      var header = $('.studio-show .studio-info').outerHeight();
      var button = $('.studio-show button').outerHeight();
      var classTypes = total - header - button - 32 /* list margins */;
      $('.studio-show .class-types').css('height', classTypes);
    };

    Promise.all([ filter.show(studio_id) ]).then(
      function(data) {
        buildFilters(data[0]);
        resizeClassList();
      }
    );
    if (callback) callback();
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
    studioUl.empty();

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
    $('.favorite-studios .studios .studio i').click(function(e) {
      var studio_id = $(e.target).parent().find('h4').attr('data-id');
      var btnClass = $(e.target).attr('class');

      if (btnClass.indexOf('edit') > -1) {
        that.toggleEditStudio(studio_id);
      } else if (btnClass.indexOf('show') > -1) {
        var studioContainer = $(e.target).parent().find('.class-list');
        studioContainer.toggleClass('show');
        that.allClasses(studio_id, studioContainer);
      } else if (btnClass.indexOf('remove') > -1) {
        that.confirmRemoval(studio_id);
      }
    });
  };

  this.toggleEditStudio = function(studio_id) {
    this.getStudioFilters(studio_id, true, '.studio-show');
    this.showModal.el().addClass('big');
    this.showModal.open();

    $('.studio-show .cancel').click(function(e) {
      e.preventDefault();
      that.showModal.close();
    });
  };

  this.confirmRemoval = function(studio_id) {
    this.removeModal.open();

    $('.studio-remove .actions').children().click(function(e) {
      that.removeModal.close();

      var btnClass = $(e.target).attr('class');
      if (btnClass.indexOf('confirm') > -1) {
        that.removeStudio(studio_id);
      }
    });
  };

  this.removeStudio = function(studio_id) {
    var filter = new Filter();
    filter.deleteStudioFilters(studio_id).then(function(msg, status) {
      var notify = new Notify();
      notify.build(msg, status);

      that.showFavorites();
    });
  };

  this.init();
}
