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

  # Returns a badge class for the LLM based on its size
  def llm_size_badge_class(size)
    case size
    when 1..5
      "bg-green-100 text-green-800" # Small models
    when 6..10
      "bg-blue-100 text-blue-800"   # Medium models
    else
      "bg-purple-100 text-purple-800" # Large models
    end
  end

  # Get top performing LLM jobs (those that completed fastest)
  def top_performing_llm_jobs(prompt, limit = 3)
    prompt.llm_jobs
          .select { |job| job.status == "completed" && job.response_time_ms.present? }
          .sort_by(&:response_time_ms)
          .first(limit)
  end

  # Clean LLM response - remove <think> elements
  def clean_llm_response(response)
    return response unless response.present?

    # If the response starts with a <think> tag, remove everything between <think> and </think>
    if response.strip.start_with?("<think>")
      # Find the closing tag position
      closing_tag_pos = response.index("</think>")
      if closing_tag_pos
        # Return everything after the closing tag plus its length (8 chars)
        return response[(closing_tag_pos + 8)..-1].to_s.strip
      end
    end

    # Return the original response if no <think> tag was found
    response
  end

  # Get a preview of the prompt that shows the actual question
  # This tries to extract the most meaningful part of the prompt
  def smart_prompt_preview(prompt, length = 50)
    content = prompt.content

    # If content has a question mark, try to extract the question
    if content.include?('?')
      # Find the last question in the text
      question_parts = content.split('?')
      if question_parts.size > 1
        # Get the last complete question
        last_question = question_parts[-2].split('.').last.strip
        # Return question with the question mark
        return truncate("#{last_question}?", length: length)
      end
    end

    # Otherwise just use the standard truncate
    truncate(content, length: length)
  end
end
