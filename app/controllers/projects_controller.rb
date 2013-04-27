class ProjectsController < ApplicationController

  def index
    render json: projects
  end

  def show
    render json: { project: project }
  end

  private

  def project
    projects.select { |project| project.id == params[:id].to_i }.first
  end

  def projects
    [
      Project.new(id: 1, name: 'Toad', description: 'Toad is our ad processing server'),
      Project.new(id: 2, name: 'QD', description: 'The analysis dashboard we sell to clients')
    ]
  end

end
