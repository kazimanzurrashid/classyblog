configure :production do
  require 'dalli'
  CACHE = Dalli::Client.new
end
