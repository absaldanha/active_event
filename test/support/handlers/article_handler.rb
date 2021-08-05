# frozen_string_literal: true

class ArticleHandler
  def article_created(event)
    puts "ArticleHandler: Received event! article_created: #{event.payload}"
  end

  def handle(event)
    puts "ArticleHandler: Received event! #{event.name}: #{event.payload}"
  end
end
