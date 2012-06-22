#!/usr/bin/env rake

require 'rspec/core/rake_task'
require './lib/mustacci/database'

RSpec::Core::RakeTask.new(:spec)
task :default => :spec

namespace :db do
  desc "Seed the database with defaults"
  task :seed do

    database = Mustacci::Database.reset

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

  end
end
