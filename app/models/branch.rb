

class Branch < ApplicationRecord
  validates :version, presence: true, uniqueness: true
  has_many :pages

  scope :ordered, -> { Branch.all.to_a.sort_by(&:sorting_value) }

  def refresh
    paths_list = retrieve_paths_list
    paths_list.each do |path|
      if pages.where(path: path).empty?
        pages.create(path: path)
      end
    end
  end

  def sorting_value
    parts = version.split('.')
    major = parts[0].to_i
    minor = parts[1].to_i
    return major * 10 + minor
  end

  def previous
  end

  def next 
  end

  private

    def doclist_url
      "https://documentation-dev.wazuh.com/#{version}/.doclist"
    end

    def retrieve_paths_list
      paths_list = []
      doclist_file = Down.download(doclist_url)
      doclist_file.each_line do |line|
        line.chomp!
        paths_list = paths_list.push(line)
      end
      doclist_file.unlink
      return paths_list
    rescue Down::NotFound
      return []
    end
end
