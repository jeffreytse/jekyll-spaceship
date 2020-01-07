# frozen_string_literal: true

module Jekyll::Spaceship
  class Processor
    @@_registers = []

    def initialize()
      @@_registers.each do |_register|
        container = _register.first
        events = _register.last.uniq
        events = events.select do |event|
          next true if event.match(/^post/)
          next !events.any?(event.to_s.gsub(/^pre/, 'post').to_sym)
        end
        events.each do |event|
          register container, event
        end
      end
      @@_registers.clear
    end

    def content_tag(post)
      # pre-handle content
      content_tag = "<content_tag id=\"#{post.url}\" />"
    end

    def self.register(container, *events)
      @@_registers << [container, events]
    end

    def register(container, event, &block)
      # define handle proc
      handle = ->(post) {
        method = "on_#{container}_#{event}"
        self.send method, post if self.respond_to? method
        block.call(post) if block
      }

      if event.to_s.start_with?("after")
        Jekyll::Hooks.register container, event do |post|
          handle.call post
        end
      elsif event.to_s.start_with?("post")
        Jekyll::Hooks.register container, event do |post|
          # remove content tags
          tag = self.content_tag(post)
          post.content = post.content.gsub(tag, "")

          handle.call post

          # replace output content
          post.output = post.output.gsub(/#{tag}.*#{tag}/m, post.content)
        end

        # auto add pre-event
        register container, event.to_s.sub("post", "pre").to_sym
      elsif event.to_s.start_with?("pre")
        Jekyll::Hooks.register container, event do |post|
          # wrap post content with tags
          tag = self.content_tag(post)

          handle.call post

          post.content = "#{tag}\n#{post.content}\n#{tag}"
        end
      end
    end
  end
end
