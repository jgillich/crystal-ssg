require "yaml"
require "crinja"

module Watchdocs
  @[Crinja::Attributes(expose: [draft, summary, title])]
  class FrontMatter
    include YAML::Serializable
    include Crinja::Object::Auto

    property draft : Bool?

    property summary : String?

    property title : String?

    property date : Time?

    def initialize
    end
  end
end
