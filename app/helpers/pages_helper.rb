module PagesHelper
  def redirection_options_for_select(page, branch)
    same_branch = page.branch.id == branch.id
    [
      same_branch ? ['New page', 'new_page_form'] : ['Deleted page', 'deleted_page_form'],  
      ['Renamed page', 'renamed_page_form']
    ]
  end

  def rename_form_params(branch, page)
    origin = nil
    destination = nil 
    if(page.branch == branch)
      destination = page 
    else
      origin = page 
    end
    return { branch: branch, origin: origin, destination: destination }
  end

  def origins_for_autocomplete(branch)
    branch.deleted_pages.map{ |page| [page.path, page.id] }.to_h
  end

  def destinations_for_autocomplete(branch)
    branch.new_pages.map{ |page| [page.path, page.id] }.to_h
  end
end
