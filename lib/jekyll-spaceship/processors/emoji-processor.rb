# frozen_string_literal: true

require 'net/http'
require 'uri'
require 'json'

module Jekyll::Spaceship
  class EmojiProcessor < Processor
    EMOJI_MARKUP_HOST = 'https://api.github.com/emojis'
    EMOJI_MARKUP_DATA = {}

    def initialize
      super()
      self.initialize_emoji_data
    end

    def initialize_emoji_data
      EMOJI_MARKUP_DATA.update get_emoji_markup_data
    end

    def on_handle_html(content)
      return content if EMOJI_MARKUP_DATA.size.zero?
      # handle emoji markup
      content.scan(/:([\w+-]+):/) do |match_data|
        emoji_markup = match_data[0]
        emoji_image = EMOJI_MARKUP_DATA[emoji_markup]
        next if emoji_image.nil?
        self.handled = true

        # convert hex string to unicode
        unicode = emoji_image.match(/unicode\/([\d\w]+)/)
        if unicode[1]
          unicode = "0x#{unicode[1]}".to_i(16)
          alt = [unicode].pack('U*')
        end
        alt = emoji_markup if alt.nil?

        content = content.gsub(
          ":#{emoji_markup}:",
          "<image class=\"emoji\" \
            title=\"#{emoji_markup}\" \
            alt=\"#{alt}\" \
            src=\"#{emoji_image}\" \
            style=\"vertical-align: middle; \
            max-width: 1em; visibility: hidden;\" \
            onload=\"this.style.visibility='visible'\" \
            onerror=\"this.replaceWith(this.alt)\"> \
          </image>"
        )
      end
      content
    end

    def get_emoji_markup_data
      data = {}
      begin
        source = Net::HTTP.get URI(EMOJI_MARKUP_HOST)
        data = JSON.parse(source)
      rescue StandardError => msg
        logger.log msg
      end
      data
    end
  end
end
