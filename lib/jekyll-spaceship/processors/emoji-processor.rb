# frozen_string_literal: true

require 'net/http'
require 'json'
require 'gemoji'

module Jekyll::Spaceship
  class EmojiProcessor < Processor
    def self.config
      {
        'css' => {
          'class' => 'emoji'
        },
        'src' => 'https://github.githubassets.com/images/icons/emoji/'
      }
    end

    def on_handle_html(content)
      # handle emoji markup
      content.scan(/:([\w\d+-]+):/) do |match|
        emoji = Emoji.find_by_alias match[0]
        next if emoji.nil?
        self.handled = true

        # escape plus sign
        emoji_name = emoji.name.gsub('+', '\\\+')
        css_class = self.config['css']['class']

        content = content.gsub(
          /(?<!\=")\s*:#{emoji_name}:\s*(?!"\s)/,
          "<img class=\"#{css_class}\""\
            " title=\":#{emoji.name}:\""\
            " alt=\":#{emoji.name}:\""\
            " raw=\"#{emoji.raw}\""\
            " src=\"#{config['src']}#{emoji.image_filename}\""\
            " style=\"vertical-align: middle; display: inline;"\
            " max-width: 1em; visibility: hidden;\""\
            " onload=\"this.style.visibility='visible'\""\
            " onerror=\"this.replaceWith(this.getAttribute('raw'))\">"\
          "</img>"
        )
      end
      content
    end
  end
end
