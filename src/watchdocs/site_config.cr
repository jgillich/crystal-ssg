require "yaml"
require "crinja"

module Watchdocs
  class Site
    @[Crinja::Attributes(expose: [name, lang, description, keywords])]
    class Config
      include YAML::Serializable
      include Crinja::Object::Auto

      getter name : String?

      getter lang : String?

      getter description : String?

      getter keywords : String?
    end
  end
end
