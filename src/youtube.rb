require 'uri'
require 'yaml'
require 'net/http'

class YouTube
  def initialize(playlistId = nil, audio = false)
    system('clear')
    puts '🎮 O programa foi iniciado...'
    configurations = YAML.load_file('config.yml')
    @url = configurations['default']['api_url']
    @params = {
      playlistId: playlistId,
      key: configurations['default']['api_key'], # KEY API https://developers.google.com/youtube/v3/docs/playlists/
      alt: 'json',
      part: 'snippet,contentDetails',
      prettyPrint: false,
      fields: 'nextPageToken,items(contentDetails(videoId))',
      maxResults: 100
    }
    @audio = audio
    @videos_ids = []
  end

  def loading
    system('clear')
    puts '🤖 Carregando a lista ...'
    uri = URI(@url)
    uri.query = URI.encode_www_form(@params)
    res = Net::HTTP.get(uri)
    videos_ids = eval res
    if !videos_ids.nil? and !videos_ids[:items].nil?
      @videos_ids = videos_ids[:items]
    else
      system('clear')
      puts '🚨 Não consegui indenticar nenhum video nessa lista. 😔'
      @videos_ids = []
    end
    @videos_ids
  end

  def create_folder?(_folder = 'Output')
    create = system('mkdir Output') ? true : false
    system('clear')
    if create
      puts '📂 Criando a pasta (Output).'
    else
      puts '📂 A pasta (Output) já existe.'
    end
  end

  def list_size
    @videos_ids.length || 0
  end

  def download
    videos_current = 0
    @videos_ids.each do |item|
      videos_current += 1
      id = item[:contentDetails][:videoId]
      cmd_audio = @audio ? "-x --audio-format 'mp3'" : ''
      system('clear')
      puts "🛸 Progresso geral #{(videos_current * 100) / list_size}% ..."
      system("cd Output/ && youtube-dl 'https://www.youtube.com/watch?v=#{id}' #{cmd_audio} ")
    end
  end
end
