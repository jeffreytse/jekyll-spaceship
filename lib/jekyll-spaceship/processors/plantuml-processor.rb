# frozen_string_literal: true

require "net/http"
require "base64"

module Jekyll::Spaceship
  class PlantumlProcessor < Processor
    exclude :none

    def self.config
      {
        'mode' => 'default',
        'syntax' => {
          'code' => 'plantuml!',
          'custom' => ['@startuml', '@enduml']
        },
        'css' => {
          'class' => 'plantuml'
        },
        'src' => 'http://www.plantuml.com/plantuml/png/'
      }
    end

    def on_handle_markdown(content)
      # match custom plantuml block and code block
      syntax = self.config['syntax']
      code_name = syntax['code']
      custom = syntax['custom'][-2, 2]

      patterns = [
        /((`{3,})\s*#{code_name}((?:.|\n)*?)\2)/,
        /((?<!\\)(#{custom[0]})((?:.|\n)*?)(?<!\\)(#{custom[1]}))/
      ]

      patterns.each do |pattern|
        content = handle_plantuml_block(pattern, content)
      end

      # handle escape custom plantuml block
      content.gsub(/\\(#{custom[0]}|#{custom[1]})/, '\1')
    end

    def handle_plantuml_block(pattern, content)
      content.scan pattern do |match|
        match = match.select { |m| not m.nil? }
        block = match[0]
        code = match[2]

        self.handled = true

        content = content.gsub(
          block,
          handle_plantuml(code)
        )
      end
      content
    end

    def handle_plantuml(code)
      # wrap plantuml code
      code = "@startuml#{code}@enduml".encode('UTF-8')

      url = get_url(code)

      # render mode
      case self.config['mode']
      when 'pre-fetch'
        url = self.get_plantuml_img_data(url)
      end

      # return img tag
      css_class = self.config['css']['class']
      "<img class=\"#{css_class}\" src=\"#{url}\">"
    end

    def get_url(code)
      src = self.config['src']

      # set default method
      src += '{hexcode}' if src.match(/\{.*\}/).nil?

      # encode to hex string
      if src.include?('{hexcode}')
        code = '~h' + code.unpack("H*").first
        return src.gsub('{hexcode}', code)
      else
        raise "No supported src ! #{src}"
      end
    end

    def get_plantuml_img_data(url)
      data = ''
      begin
        res = Net::HTTP.get_response URI(url)
        raise res.body unless res.is_a?(Net::HTTPSuccess)
        data = Base64.encode64(res.body)
        content_type = res.header['Content-Type']
        raise 'Unknown content type!' if content_type.nil?
        data = "data:#{content_type};base64, #{data}"
      rescue StandardError => msg
        data = url
        logger.log msg
      end
      data
    end
  end
end
