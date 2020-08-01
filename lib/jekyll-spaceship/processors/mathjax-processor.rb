# frozen_string_literal: true

require "nokogiri"

module Jekyll::Spaceship
  class MathjaxProcessor < Processor
    def self.config
      {
        'src' => [
          'https://polyfill.io/v3/polyfill.min.js?features=es6',
          'https://cdn.jsdelivr.net/npm/mathjax@3/es5/tex-mml-chtml.js',
        ],
        'config' => {
          'tex' => { 'inlineMath' => [['$','$'], ['\\(','\\)']] },
          'svg': { 'fontCache': 'global' }
        }
      }
    end

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

      # add mathjax config
      cfg = config['config'].to_json
      head.add_child("<script>MathJax=#{cfg}</script>")

      # add mathjax dependencies
      config['src'] = [config['src']] if config['src'].is_a? String
      config['src'].each do |src|
        head.add_child("<script src=\"#{src}\"></script>")
      end

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
