require 'co2mini'
require 'faraday'
require 'json'

dev = CO2mini.new

conn = Faraday.new(
  url: "https://genya0407:#{ENV.fetch('PASSWORD')}@datastore.genya0407.net",
  headers: {'Content-Type' => 'application/json'}
)

dev.on(:co2) do |op, val|
  puts "Co2: #{val}ppm"
  conn.post('/topics/post/co2') do |req|
    req.body = JSON.generate(created_at: Time.now.to_i, value: val)
  end.tap { |r| p r.status }
end

dev.on(:temp) do |op, val|
  puts "Temp: #{val}"
  conn.post('/topics/post/temp') do |req|
    req.body = JSON.generate(created_at: Time.now.to_i, value: val)
  end.tap { |r| p r.status }
end

dev.loop
