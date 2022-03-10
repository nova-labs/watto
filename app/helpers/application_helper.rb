module ApplicationHelper
  def page_title(*segments)
    ([ENV["PAGE_TITLE"]]+segments).join(" | ")
  end

  def login_path
    "/auth/wildapricot"
  end

  def admin?
    controller.class < Admin::BaseController
  end

  def header_class
    if admin?
      "bg-danger"
    else
      "bg-dark"
    end
  end
end
