# frozen_string_literal: true

require 'net/http'
require 'json'
require 'gemoji'

module Jekyll::Spaceship
  class EmojiProcessor < Processor
    EMOJI_MARKUP_HOST = 'https://github.githubassets.com/images/icons/emoji/'

    def on_handle_html(content)
      # handle emoji markup
      content.scan(/:([\w\d+-]+):/) do |match|
        emoji = Emoji.find_by_alias match[0]
        next if emoji.nil?
        self.handled = true

        # escape plus sign
        emoji_name = emoji.name.gsub('+', '\\\+')

        content = content.gsub(
          /(?<!\=")\s*:#{emoji_name}:\s*(?!"\s)/,
          "<img class=\"emoji\" \
            title=\":#{emoji.name}:\" \
            alt=\":#{emoji.name}:\" \
            raw=\"#{emoji.raw}\" \
            src=\"#{EMOJI_MARKUP_HOST}#{emoji.image_filename}\" \
            style=\"vertical-align: middle; \
            max-width: 1em; visibility: hidden;\" \
            onload=\"this.style.visibility='visible'\" \
            onerror=\"this.replaceWith(this.getAttribute('raw'))\"> \
          </img>"
        )
      end
      content
    end
  end
end
