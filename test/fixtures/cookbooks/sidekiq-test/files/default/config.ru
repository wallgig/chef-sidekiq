require 'rack'

class MyApp
  def call env
    [200, {"Content-Type" => "text/html"}, ["Hello from Puma"]] 
  end
end

run MyApp.new
