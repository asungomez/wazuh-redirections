class PagesDownloader
  
  def self.download(version)
    paths_list = []
    doclist_file = Down.download(doclist_url(version))
    doclist_file.each_line do |line|
      line.chomp!
      paths_list = paths_list.push(line)
    end
    doclist_file.unlink
    return paths_list
  rescue Down::NotFound
    return []
  end

  private
    def self.doclist_url(version)
      "https://documentation-dev.wazuh.com/#{version}/.doclist"
    end
end