# frozen_string_literal: true

require "nokogiri"

module Jekyll::Spaceship
  class MathjaxProcessor < Processor
    def process?
      return true if Type.html?(output_ext)
    end

    def on_handle_html(content)
      # use nokogiri to parse html
      doc = Nokogiri::HTML(content)

      head = doc.at('head')
      return content if head.nil?
      return content if not self.has_mathjax_expression? doc

      self.handled = true

      cfg = "MathJax.Hub.Config(#{config['config'].to_json});"
      head.add_child("<script src=\"#{config['src']}\">#{cfg}</script>")

      doc.to_html
    end

    def has_mathjax_expression?(doc)
      doc.css('*').each do |node|
        if node.content.match(/(?<!\\)\$.+(?<!\\)\$/)
          return true
        end
        if node.content.match(/(?<!\\)\\\(.+(?<!\\)\\\)/)
          return true
        end
      end

      doc.css('script').each do |node|
        type = node['type']
        if type and type.match(/math\/tex/)
          return true
        end
      end
      false
    end
  end
end
