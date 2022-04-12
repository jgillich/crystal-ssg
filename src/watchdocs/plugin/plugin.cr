module Watchdocs
  PLUGINS = HashMap(String, Plugin).new

  abstract class Plugin
    def pre_build
    end

    def post_build
    end

    def page(p : Page, io : IO)
    end

    def static(p : Path, io : IO)
    end
  end
end
