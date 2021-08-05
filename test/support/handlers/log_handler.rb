# frozen_string_literal: true

class LogHandler
  def handle(event)
    puts "LogHandler: Received event! #{event.name}: #{event.payload}"
  end
end
