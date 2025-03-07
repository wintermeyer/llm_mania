module PromptsHelper
  def prompt_status_color(status)
    case status
    when "waiting"
      "bg-gray-100 text-gray-800"
    when "in_queue"
      "bg-yellow-100 text-yellow-800"
    when "processing"
      "bg-blue-100 text-blue-800"
    when "completed"
      "bg-green-100 text-green-800"
    when "failed"
      "bg-red-100 text-red-800"
    else
      "bg-gray-100 text-gray-800"
    end
  end
end
