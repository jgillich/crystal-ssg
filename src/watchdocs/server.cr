require "inotify"
require "kemal"
require "./site"

# add_handler LivereloadHandler.new
add_handler Kemal::StaticFileHandler.new("./site")

# public_folder "./site"

elapsed_time = Time.measure do
  Watchdocs::Site.new.render Path[Dir.current, "site"]
end
puts elapsed_time

SOCKETS = [] of HTTP::WebSocket

def watch(dir : Dir)
  pp dir.path
  Inotify.watch dir.path do |event|
    puts event
    Watchdocs::Site.new.render Path[Dir.current, "site"]
    SOCKETS.each do |socket|
      socket.send "reload"
    end
  end
end

def watch_recursive(dir : Dir)
  watch dir
  dir.each_child do |name|
    path = Path[dir.path, name]
    if File.directory?(path)
      watch_recursive Dir.new(path)
    end
  end
end

watch_recursive Dir.new(Path[Dir.current, "content"])

get "/" do |env|
  env.redirect "/index.html"
end

ws "/livereload" do |socket|
  puts "new client"
  socket.send "Hello from Kemal!"
  SOCKETS << socket
  socket.on_close do
    SOCKETS.delete socket
  end
end

# class LivereloadHandler < Kemal::Handler
#  def call(context)
#    html = <<-HTML
#      <script type="text/javascript">
#      if ('WebSocket' in window) {
#        (() => {
#          var proto = window.location.protocol === 'http:' ? 'ws://' : 'wss://';
#          var ws = new WebSocket(`${proto}//${location.host}/livereload`);
#          ws.onmessage = (msg) => {
#            if (msg.data == "reload") {
#              window.location.reload();
#            }
#          };
#          ws.onclose = () => {
#            console.log('close')
#            setTimeout(() => {
#              //window.location.reload();
#            }, 2000);
#          };
#        })();
#      }
#      </script>
#    HTML
#    if context.response.headers["Content-Type"]? == "text/html"
#      # context.response.print html
#      call_next context
#      if content_length = context.response.headers["Content-Length"]?
#        # context.response.headers["Content-Length"] = (content_length.to_i + html.bytesize).to_s
#      else
#        # context.response.headers["Content-Length"] = html.bytesize.to_s
#      end
#    else
#      call_next context
#    end
#  end
# end

Signal::TERM.trap do
  Kemal.stop
  exit
end

Kemal.run
