Mustacci.Router.map(function() {
  this.resource('projects', function() {
    this.resource('project', { path: ':project_id' })
  });
});
