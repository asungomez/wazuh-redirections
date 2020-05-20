

class Branch < ApplicationRecord
  validates :version, presence: true, uniqueness: true
  has_many :pages

  scope :ordered, -> { Branch.all.to_a.sort_by(&:sorting_value) }

  def deleted_pages
    deleted = []
    if previous
      Page.removed(previous, self).each do |page|
        unless page.destination_in(self)
          deleted.push(page)
        end
      end
    end
    return deleted
  end

  def new_pages
    if previous
      Page.added(previous, self).where.not(id: renamed_pages.pluck(:id))
    else
      pages
    end
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

  def renamed_pages
    renamed = []
    if previous
      Page.added(previous, self).each do |page|
        origins_from_previous_branch = page.origins.where(branch: previous)
        if origins_from_previous_branch.count == 1
          renamed.push(origins_from_previous_branch.first.destination_in(self))
        end
      end
    end
    return renamed
  end

  def sorting_value
    parts = version.split('.')
    major = parts[0].to_i
    minor = parts[1].to_i
    return major * 100 + minor
  end

  def update_pages(paths_list)
    pages.where.not(path: paths_list).destroy_all
    paths_list.each do |path|
      if pages.where(path: path).empty?
        pages.create(path: path)
      end
    end
  end
end
