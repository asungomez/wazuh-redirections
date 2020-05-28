module PagesHelper

  def default_redirection_option_for_select(page, branch)
    case page.type(branch)
    when 'new'
      'new_page_form'
    when 'deleted'
      'deleted_page_form'
    when 'renamed'
      'renamed_page_form'
    else 
      'deleted_page_form'
    end
  end

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
    disabled = 'none'
    if(page.branch == branch)
      destination = page 
      disabled = 'destination'
      if page.is_renamed?
        origin = page.origins_from(branch.previous).first
      end
    else
      origin = page 
      disabled = 'origin'
    end
    return { branch: branch, origin: origin, destination: destination, disabled: disabled }
  end

  def origins_for_autocomplete(branch)
    branch.deleted_pages.map{ |page| [page.path, page.id] }.to_h
  end

  def destinations_for_autocomplete(branch)
    branch.new_pages.map{ |page| [page.path, page.id] }.to_h
  end
end
