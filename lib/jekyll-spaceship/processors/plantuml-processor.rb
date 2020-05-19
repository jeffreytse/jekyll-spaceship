# frozen_string_literal: true

require "base64"

module Jekyll::Spaceship
  class PlantUMLProcessor < Processor
    exclude :none

    PLANT_UML_HOST = 'http://www.plantuml.com/plantuml/png/'

    def on_handle_markdown(content)
      # match default plantuml block and code block
      pattern = Regexp.union(
        /(\\?@startuml((?:.|\n)*?)@enduml)/,
        /(`{3}\s*plantuml((?:.|\n)*?)`{3})/
      )

      content.scan pattern do |match|
        match = match.select { |m| not m.nil? }
        block = match[0]
        code = match[1]

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

      # handle escape default plantuml block
      content.gsub(/\\(@startuml|@enduml)/, '\1')
    end

    def handle_plantuml(code)
      # wrap plantuml code
      code = "@startuml#{code}@enduml".encode('UTF-8')

      # encode to hex string
      code = '~h' + code.unpack("H*").first
      data = self.get_plantuml_img_data(code)

      # return img tag
      "<img src=\"#{data}\">"
    end

    def get_plantuml_img_data(code)
      data = ''
      url = "#{PLANT_UML_HOST}#{code}"
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
