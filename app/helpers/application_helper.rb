module ApplicationHelper
  def full_title(page_title = '')
    base_title = 'Lybrary'
    if page_title.empty?
      base_title
    else
      "#{base_title} | #{page_title}"
    end
  end

  def nav_tab(title, url, options = {})
    current_page = options.delete :current_page

    css_class = current_page == title ? 'text-white' : 'text-secondary'

    options[:class] = if options[:class]
                        "#{options[:class]} #{css_class}"
                      else
                        css_class
                      end

    link_to title, url, options
  end

  def currently_at(current_page)
    render partial: 'shared/menu', locals: { current_page: current_page }
  end
end
