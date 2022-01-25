require_relative 'src/youtube'

playlistId = nil
audio = false

ARGV.each do |arg|
  if arg.include?('://www.youtube.com/') || arg.include?('://m.youtube.com/')
    query = Hash[URI.decode_www_form(URI(arg).query.to_s)]
    playlistId = !query['list'].nil? ? query['list'] : nil
  elsif arg == 'a' || arg.include?('--audio')
    audio = true
  elsif arg.include?('l') || arg.include?('--list')
    playlistId = arg.split('=')[1]
  end
end

youtuber = YouTube.new(playlistId, audio)
sleep 1
youtuber.loading
sleep 1
youtuber.create_folder?
sleep 1
youtuber.download
