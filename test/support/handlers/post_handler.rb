# frozen_string_literal: true

class PostHandler
  def post_created(event)
    puts "PostHandler: Received event! post_created: #{event.payload}"
  end

  def post_updated(event)
    puts "PostHandler: Received event! #{event.name}: #{event.payload}"
  end
end
