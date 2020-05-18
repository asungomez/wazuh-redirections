

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
    return major * 100 + minor
  end

  def previous
    previous_branch = nil
    ordered_branches = Branch.ordered
    ordered_branches.each_with_index do |branch, i|
      if branch.version == self.version && i != 0
        previous_branch = ordered_branches[i-1]
      end
    end
    return previous_branch
  end

  def next 
    next_branch = nil
    ordered_branches = Branch.ordered
    ordered_branches.each_with_index do |branch, i|
      if branch.version == self.version && i < ordered_branches.count - 1
        next_branch = ordered_branches[i+1]
      end
    end
    return next_branch
  end

  def new_pages
    if previous
      pages.where.not(path: previous.pages.pluck(:path))
    else
      pages
    end
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
