module Mustacci
  class Seed

    include Helpers

    def self.call
      new.call
    end

    def call
      info "Creating views"

      # Project views
      project_views = {
        "_id" => "_design/projects",
        views: {
          by_name: {
            map: "function(doc) {
                    if(doc.type && doc.type == 'project' && doc.name && doc.owner) {
                      emit(doc.owner + '/' + doc.name, doc); 
                    }
                  }"
          }
        }
      }

      # Build views
      build_views = {
        "_id" => "_design/builds",
        views: {
          by_project: {
            map: "function(doc) {
                    if(doc.type && doc.type == 'build' ) {
                      emit(doc.project_id, doc)
                    }
                  }"
          }
        }
      }

      database.save(project_views)
      database.save(build_views)

      info "Views created"
    end

    def database
      @database ||= Mustacci::Database.reset
    end
  end
end
