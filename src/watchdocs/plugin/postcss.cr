module Watchdocs
  class Plugin
    class Postcss < Plugin
      def initialize
      end

      def static(path : Path, io : IO::Memory)
        if path.extension == ".css"
          Process.run("npx", args: ["-y", "postcss-cli"]) do |proc|
            proc.input.write io.to_slice
            proc.input.close
            io.clear
            io.write proc.output.getb_to_end
          end
        end
      end
    end
  end
end
