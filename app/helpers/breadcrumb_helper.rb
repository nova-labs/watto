module BreadcrumbHelper
  def crumb(name, to: nil, active: false)
    if to
      name = content_tag :a, name, href: to
    end

    content_tag :li, name, class: "breadcrumb-item #{"active" if active}"
  end
end
