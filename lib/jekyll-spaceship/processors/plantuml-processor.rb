# frozen_string_literal: true

module Jekyll::Spaceship
  class PlantUMLProcessor < Processor
    exclude :none

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
      uml = "@startuml#{code}@enduml"

      dir = File.dirname(__FILE__)
      jar = dir + "/../utils/plantuml/plantuml.jar"
      echo = "echo -e \"#{uml.gsub('"', '\"')}\""
      plantuml = "java -jar \"#{jar}\" -pipe 2>/dev/null"

      # exec plantuml.jar and output base64 data
      base64 = `#{echo} | #{plantuml} | base64`

      # return img tag
      "<img src=\"data:image/png;base64, #{base64}\">"
    end
  end
end
