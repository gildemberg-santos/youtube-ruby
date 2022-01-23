require 'uri'
require 'net/http'

url = 'https://www.googleapis.com/youtube/v3/playlistItems'

params = {
  playlistId: nil,
  key: '', # KEY API https://developers.google.com/youtube/v3/docs/playlists/
  alt: 'json',
  part: 'snippet,contentDetails',
  prettyPrint: false,
  fields: 'nextPageToken,items(contentDetails(videoId))',
  maxResults: 100
}

audio = false

ARGV.each do |arg|
  if arg.include?('://www.youtube.com/') || arg.include?('://m.youtube.com/')
    query = Hash[URI.decode_www_form(URI(arg).query.to_s)]
    params[:playlistId] = !query['list'].nil? ? query['list'] : nil
  elsif arg == 'a' || arg == '--audio'
    audio = true
  elsif arg.include?('l') || arg.include?('--list')
    params[:playlistId] = arg.split('=')[1]
  end
end

uri = URI(url)
uri.query = URI.encode_www_form(params)
res = Net::HTTP.get(uri)
videos_ids = eval res

puts videos_ids
puts audio
