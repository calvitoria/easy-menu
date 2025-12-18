module ApplicationHelper
  def status_badge(status)
    case status
    when "completed"
      content_tag(:span, "Completed", class: "px-2 inline-flex text-xs leading-5 font-semibold rounded-full bg-green-100 text-green-800")
    when "failed"
      content_tag(:span, "Failed", class: "px-2 inline-flex text-xs leading-5 font-semibold rounded-full bg-red-100 text-red-800")
    when "processing"
      content_tag(:span, "Processing", class: "px-2 inline-flex text-xs leading-5 font-semibold rounded-full bg-yellow-100 text-yellow-800")
    else
      content_tag(:span, "Pending", class: "px-2 inline-flex text-xs leading-5 font-semibold rounded-full bg-gray-100 text-gray-800")
    end
  end

  def success_rate_color(rate)
    if rate >= 0.9
      "text-green-600"
    elsif rate >= 0.7
      "text-yellow-600"
    else
      "text-red-600"
    end
  end
end
