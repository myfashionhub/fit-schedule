function Session(redirect_path) {

  this.destroy = function() {
    $.ajax({
      url: '/logout',
      type: 'GET',
      success: function(data) {
        console.log(data);
        window.location = redirect_path;
      },
      error: function(err) {
        console.log(err);
      }
    });
  }

}
