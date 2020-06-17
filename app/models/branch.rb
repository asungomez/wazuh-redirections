

class Branch < ApplicationRecord
  validates :version, presence: true, uniqueness: true
  has_many :pages

  scope :ordered, -> { self.all.to_a.sort_by(&:sorting_value) }

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
      pages.limit(-1).each do |page|
        page.redirections_to(previous).each do |redirection|
          bidirectional = Redirection.where(to: redirection.from, from: redirection.to, destination_anchor: redirection.origin_anchor, origin_anchor: redirection.destination_anchor).count > 0

          unique = Redirection.where(from: previous.pages.pluck(:id), to: page.id, destination_anchor: redirection.origin_anchor).count == 1

          if bidirectional && unique && !renamed.include?(page)
            renamed.push(page)
          end
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
