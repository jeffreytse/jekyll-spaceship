# frozen_string_literal: true

require 'uri'

module Jekyll::Spaceship
  class VideoProcessor < Processor
    def on_handle_markdown(content)
      content = handle_youtube(content)
      content = handle_vimeo(content)
      content = handle_dailymotion(content)
    end

    # Examples:
    # ![youtube](https://www.youtube.com/watch?v=XA2WjJbmmoM "title")
    # ![youtube](http://www.youtube.com/embed/w-m_yZCLF5Q)
    # ![youtube](//youtu.be/mEP3YXaSww8?height=100%&width=400)
    def handle_youtube(content)
      handle_video(content, {
        host: '(https?:)?\\/\\/.*youtu.*',
        id: '(?<=\\?v\\=|embed\\/|\\.be\\/)([a-zA-Z0-9\\_\\-]+)',
        iframe_url: "https://www.youtube.com/embed/"
      })
    end

    # Examples:
    # ![vimeo](https://vimeo.com/263856289)
    # ![vimeo](https://vimeo.com/263856289?height=100%&width=400)
    def handle_vimeo(content)
      handle_video(content, {
        host: '(https?:)?\\/\\/vimeo\\.com\\/',
        id: '([0-9]+)',
        iframe_url: "https://player.vimeo.com/video/",
        width: 600,
        height: 350
      })
    end

    # Examples:
    # ![dailymotion](https://www.dailymotion.com/video/x7tgcev)
    # ![dailymotion](https://dai.ly/x7tgcev?height=100%&width=400)
    def handle_dailymotion(content)
      handle_video(content, {
        host: '(https?:)?\\/\\/.*dai.?ly.*',
        id: '(?<=video\\/|\\/)([a-zA-Z0-9\\_\\-]+)',
        iframe_url: "https://www.dailymotion.com/embed/video/"
      })
    end

    def handle_video(content, data)
      host = data[:host]
      return content if content.sub(/#{host}/, '').nil?

      iframe_url = data[:iframe_url]
      id = data[:id]
      url = "(#{host}#{id}\\S*)"
      title = '("(.*)".*){0,1}'

      # pre-handle reference-style links
      regex = /(\[(.*)\]:\s*(#{url}\s*#{title}))/
      content.scan regex do |match_data|
        match = match_data[0]
        ref_name = match_data[1]
        ref_value = match_data[2]
        content = content.gsub(match, '')
          .gsub(/\!\[(.*)\]\s*\[#{ref_name}\]/,
            "![\1](#{ref_value})")
      end

      # handle inline-style links
      regex = /(\!\[(.*)\]\(.*#{url}\s*#{title}\))/
      content.scan regex do |match_data|
        url = match_data[2]
        id = match_data[4]
        title = match_data[6]
        qs = url.match(/(?<=\?)(\S*?)$/)
        qs = Hash[URI.decode_www_form(qs.to_s)].reject do |k, v|
          next true if v == id or v == ''
        end

        width = qs['width'] || data[:width] || 600
        height = qs['height'] || data[:height] || 400
        style = "max-width: 100%" if width.nil?

        url = URI("#{iframe_url}#{id}").tap do |v|
          v.query = URI.encode_www_form(qs) if qs.size > 0
        end

        html = "<iframe \
          src=\"#{url}\" \
          title=\"#{title}\" \
          width=\"#{width}\" \
          height=\"#{height}\" \
          style=\"#{style}\" \
          allow=\"autoplay; encrypted-media\" \
          frameborder=\"0\" \
          allowfullscreen=\"\">\
          </iframe>"

        content = content.gsub(match_data[0], html)
        self.handled = true
      end
      content
    end
  end
end
