require "yaml"

module Watchdocs
  class FrontMatter
    include YAML::Serializable

    @[YAML::Field]
    property draft : Bool?

    @[YAML::Field]
    property summary : String?

    @[YAML::Field]
    property title : String?

    def initialize
    end
  end
end
