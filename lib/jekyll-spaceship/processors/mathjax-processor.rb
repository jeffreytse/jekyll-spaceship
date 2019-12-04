# frozen_string_literal: true

require 'nokogiri'

module Jekyll::Spaceship
  class MathjaxProcessor < Processor
    register :posts, :post_render

    def on_posts_post_render(post)
      # use nokogiri to parse html
      doc = Nokogiri::HTML(post.output)

      params = "config=TeX-AMS-MML_HTMLorMML"
      src = "//cdn.mathjax.org/mathjax/latest/MathJax.js?#{params}"
      doc.at('head').add_child("<script src=\"#{src}\"></script>")

      post.output = doc.to_s
    end
  end
end
