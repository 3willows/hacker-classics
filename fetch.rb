require 'open-uri'
require 'nokogiri'
require 'date'
require 'json'
require 'pry'

POINT_THRESHOLD = 40

stories = Hash.new { |h, k| h[k] = [] }

["philosophy", "history", "literature"].each do |year|
  (0..5).each do |page|
    ct = 0
    puts "Fetch #{"https://hn.algolia.com/api/v1/search?tags=story&query=#{year}&page=#{page}"}..."
    html = URI.parse("https://hn.algolia.com/api/v1/search?tags=story&query=#{year}&page=#{page}").read
    data = JSON.parse(html)
  
    data['hits'].each do |h|
      if h['points'] > POINT_THRESHOLD
        puts "  #{h['title']} -- #{h['points']}"
        stories[year] << h
        ct += 1
      end
    end
    if ct == 0
      break
    end
  end
end

File.open("./stories.json", "w") do |f|
  f.puts JSON.generate(stories)
end