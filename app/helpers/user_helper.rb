# frozen_string_literal: true

module UserHelper
  def gravatar_url(user, size=200)
    gravatar_id = Digest::MD5.hexdigest(user.email)
    "https://gravatar.com/avatar/#{gravatar_id}.png?d=mp&s=#{size}"
  end

  def youth_badge(user)
    case user.age_category
    when :under_8
      content_tag(:span, "Youth under 8", class: "badge bg-warning text-dark", title: "Youth age 7 and under")
    when :age_8_to_11
      content_tag(:span, "Youth 8–11", class: "badge bg-warning text-dark", title: "Youth age 8 to 11")
    when :age_12_to_15
      content_tag(:span, "Youth 12–15", class: "badge bg-warning text-dark", title: "Youth age 12 to 15")
    when :age_16_to_17
      content_tag(:span, "Youth 16–17", class: "badge bg-warning text-dark", title: "Youth age 16 to 17")
    else
      ""
    end
  end


  def youth_access_details(user)
    case user.age_category
    when :under_12
      "Youth under 12 are not allowed access to tools"
    when :age_12_to_14
      "Youth age 12 to 14"
    when :age_15_to_17
      "Youth age 15 to 17"
    else
      ""
    end
  end
end
