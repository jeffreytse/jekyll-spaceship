# frozen_string_literal: true

require 'jekyll-spaceship/version'

module Jekyll::Spaceship
  class Logger
    def self.display_info
      self.log "Jekyll-Spaceship #{Jekyll::Spaceship::VERSION}"
      self.log "A powerful Jekyll plugin."
      self.log "https://github.com/jeffreytse/jekyll-spaceship"
    end

    def self.log(content)
      self.output "Jekyll Spaceship", content
    end

    def self.output(title, content)
      puts "#{title.rjust(18)}: #{content}"
    end
  end
end
