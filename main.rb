require 'uri'
require 'yaml'
require 'net/http'

system("clear")
puts "🎮 O programa foi iniciado..."
sleep 3

@configurations = YAML.load_file('config.yml')

url = 'https://www.googleapis.com/youtube/v3/playlistItems'

params = {
  playlistId: nil,
  key: @configurations['default']['api_key'], # KEY API https://developers.google.com/youtube/v3/docs/playlists/
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
  elsif arg == 'a' || arg.include?('--audio')
    audio = true
  elsif arg.include?('l') || arg.include?('--list')
    params[:playlistId] = arg.split('=')[1]
  end
end

system("clear")
puts "🤖 Carregando a lista ..."
uri = URI(url)
uri.query = URI.encode_www_form(params)
res = Net::HTTP.get(uri)
videos_ids = eval res
sleep 3

system("clear")
if videos_ids.nil?
  puts "🚨 Não consegui indenticar nenhum video nessa lista. 😔"
  exit
else
  videos_ids = videos_ids[:items]
end

if system("mkdir Output")
  system("clear")
  puts "📂 Criando a pasta (Output)."
else
  system("clear")
  puts "📂 A pasta (Output) já existe."
end
sleep 3

total_de_videos = videos_ids.length
video_atual = 0

sleep 3
videos_ids.each do |item|
  video_atual += 1
  id = item[:contentDetails][:videoId]
  cmd_audio = audio ? "-x --audio-format 'mp3'" : ""
  system("clear")
  puts "🛸 Progresso geral #{(video_atual * 100) / total_de_videos}% ..."
  system("cd Output/ && youtube-dl 'https://www.youtube.com/watch?v=#{id}' #{cmd_audio} ")
end

puts "✅ Processo concluído. 🕺🎉🎊"
