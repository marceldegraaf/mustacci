Mustacci.ProjectsRoute = Ember.Route.extend({
  model: function() {
    return Mustacci.Project.find();
  }
});
