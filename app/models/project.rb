class Project

  attr_accessor :id, :name, :description

  def initialize(attributes = {})
    attributes.each do |k,v|
      send("#{k}=", v)
    end
  end

end
