# frozen_string_literal: true

require "net/http"
require "base64"

module Jekyll::Spaceship
  class PlantumlProcessor < Processor
    exclude :none

    PLANTUML_PATTERNS = [
      /(\\?(@startuml)((?:.|\n)*?)@enduml)/,
      /((`{3,})\s*plantuml((?:.|\n)*?)\2)/
    ]

    def self.config
      { 'src' => 'http://www.plantuml.com/plantuml/png/' }
    end

    def on_handle_markdown(content)
      # match default plantuml block and code block
      PLANTUML_PATTERNS.each do |pattern|
        content = handle_plantuml_block(pattern, content)
      end

      # handle escape default plantuml block
      content.gsub(/\\(@startuml|@enduml)/, '\1')
    end

    def handle_plantuml_block(pattern, content)
      content.scan pattern do |match|
        match = match.select { |m| not m.nil? }
        block = match[0]
        code = match[2]

        # skip escape default plantuml block
        if block.match(/(^\\@startuml|\\@enduml$)/)
          next
        end

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

      # encode to hex string
      code = '~h' + code.unpack("H*").first
      data = self.get_plantuml_img_data(code)

      # return img tag
      "<img class=\"plantuml\" src=\"#{data}\">"
    end

    def get_plantuml_img_data(code)
      data = ''
      url = "#{config['src']}#{code}"
      begin
        data = Net::HTTP.get URI(url)
        data = Base64.encode64(data)
        data = "data:image/png;base64, #{data}"
      rescue StandardError => msg
        data = url
        logger.log msg
      end
      data
    end
  end
end
