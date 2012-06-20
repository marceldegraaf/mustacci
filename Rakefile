#!/usr/bin/env rake

require 'rspec/core/rake_task'
require './app'

RSpec::Core::RakeTask.new(:spec)
task :default => :spec

namespace :db do
  desc "Seed the database with some default stuff"
  task :seed do
    Mustacci::Project.all.destroy!
    Mustacci::Build.all.destroy!

    project = Mustacci::Project.create(
      name: 'mustacci',
      owner: 'marceldegraaf',
      human_name: 'Mustacci'
    )

    project2 = Mustacci::Project.create(
      name: 'schoononline',
      owner: 'exodusbv',
      human_name: 'SchoonOnline'
    )

    project.builds.create(
      success: true,
      building: false,
      identifier: 'f0ea225f58bd435a7d85151e4b88cf4f',
      built_at: Time.now
    )
  end
end
