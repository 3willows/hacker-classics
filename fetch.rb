require 'open-uri'
require 'nokogiri'
require 'date'
require 'json'
require 'pry'

POINT_THRESHOLD = 50
EXCLUDE_KEYWORDS = /\b(engineer|tech|software|programming)\b/i  # Matches whole words like 'engineer' or 'tech', case-insensitive

stories = Hash.new { |h, k| h[k] = [] }

["philosophy", "history", "literature"].each do |topic|
  (0..200).each do |page|
    ct = 0
    puts "Fetch #{"https://hn.algolia.com/api/v1/search?tags=story&query=#{topic}&page=#{page}"}..."
    html = URI.parse("https://hn.algolia.com/api/v1/search?tags=story&query=#{topic}&page=#{page}").read
    data = JSON.parse(html)
  
    data['hits'].each do |h|
      title = h['title'] || ""
      if h['points'] > POINT_THRESHOLD && !title.match?(EXCLUDE_KEYWORDS)
        puts "  #{h['title']} -- #{h['points']}"
        stories[topic] << h
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