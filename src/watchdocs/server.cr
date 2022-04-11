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
  rescue e
    pp e
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
watch_recursive Dir.new(Path[Dir.current, "templates"])

get "/" do |env|
  env.redirect "/index.html"
end

ws "/livereload" do |socket|
  SOCKETS << socket
  socket.on_close do
    SOCKETS.delete socket
  end
end

Signal::TERM.trap do
  Kemal.stop
  exit
end

Kemal.run
