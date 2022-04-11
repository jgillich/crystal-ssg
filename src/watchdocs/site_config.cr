require "yaml"
require "crinja"

module Watchdocs
  class Site
    @[Crinja::Attributes(expose: [name])]
    class Config
      include YAML::Serializable
      include Crinja::Object::Auto

      @[YAML::Field]
      getter name : String?
    end
  end
end
