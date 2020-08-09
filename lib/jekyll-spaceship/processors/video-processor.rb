# frozen_string_literal: true

require 'uri'

module Jekyll::Spaceship
  class MediaProcessor < Processor
    def self.config
      {
        'default' => {
          'audio' => {
            'id' => 'audio-{id}',
            'class' => 'audio',
            'autoplay' => false,
            'loop' => false,
            'style' => 'outline: none',
          },
          'video' => {
            'id' => 'video-{id}',
            'class' => 'video',
            'width' => '100%',
            'height' => 350,
            'frameborder' => 0,
            'style' => 'max-width: 600px',
            'allow' => 'encrypted-media; picture-in-picture',
          }
        }
      }
    end

    def on_handle_markdown(content)
      content = handle_normal_audio(content)
      content = handle_normal_video(content)
      content = handle_youtube(content)
      content = handle_vimeo(content)
      content = handle_dailymotion(content)
    end

    # Examples:
    # ![audio](//www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3)
    # ![audio](//www.expample.com/examples/t-rex-roar.mp3?autoplay=true&loop=true)
    def handle_normal_audio(content)
      handle_media(content, {
        media_type: 'audio',
        host: '(https?:)?\\/\\/.*\\/',
        id: '(.+?\\.(mp3|wav|ogg|mid|midi|aac|wma))',
      })
    end


    # Examples:
    # ![video](//www.html5rocks.com/en/tutorials/video/basics/devstories.webm)
    # ![video](//techslides.com/demos/sample-videos/small.ogv?allow=autoplay)
    # ![video](//techslides.com/demos/sample-videos/small.mp4?width=400)
    def handle_normal_video(content)
      handle_media(content, {
        media_type: 'video',
        host: '(https?:)?\\/\\/.*\\/',
        id: '(.+?\\.(avi|mp4|webm|ogg|ogv|flv|mkv|mov|wmv|3gp|rmvb|asf))',
      })
    end

    # Examples:
    # ![youtube](https://www.youtube.com/watch?v=XA2WjJbmmoM "title")
    # ![youtube](http://www.youtube.com/embed/w-m_yZCLF5Q)
    # ![youtube](//youtu.be/mEP3YXaSww8?height=100%&width=400)
    def handle_youtube(content)
      handle_media(content, {
        media_type: 'video',
        host: '(https?:)?\\/\\/.*youtu.*',
        id: '(?<=\\?v\\=|embed\\/|\\.be\\/)([a-zA-Z0-9\\_\\-]+)',
        base_url: "https://www.youtube.com/embed/"
      })
    end

    # Examples:
    # ![vimeo](https://vimeo.com/263856289)
    # ![vimeo](https://vimeo.com/263856289?height=100%&width=400)
    def handle_vimeo(content)
      handle_media(content, {
        media_type: 'video',
        host: '(https?:)?\\/\\/vimeo\\.com\\/',
        id: '([0-9]+)',
        base_url: "https://player.vimeo.com/video/"
      })
    end

    # Examples:
    # ![dailymotion](https://www.dailymotion.com/video/x7tgcev)
    # ![dailymotion](https://dai.ly/x7tgcev?height=100%&width=400)
    def handle_dailymotion(content)
      handle_media(content, {
        media_type: 'video',
        host: '(https?:)?\\/\\/.*dai.?ly.*',
        id: '(?<=video\\/|\\/)([a-zA-Z0-9\\_\\-]+)',
        base_url: "https://www.dailymotion.com/embed/video/"
      })
    end

    def handle_media(content, data)
      host = data[:host]
      return content if content.sub(/#{host}/, '').nil?

      media_type = data[:media_type]
      base_url = data[:base_url]
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

        cfg = self.config['default'][media_type].clone
        cfg['id'] = qs['id'] || cfg['id']
        cfg['class'] = qs['class'] || cfg['class']
        cfg['style'] = qs['style'] || cfg['style']
        cfg['id'] = cfg['id'].gsub('{id}', id)
        cfg['class'] = cfg['class'].gsub('{id}', id)

        cfg['src'] = URI(base_url ? "#{base_url}#{id}" : url).tap do |v|
          v.query = URI.encode_www_form(qs) if qs.size > 0
        end

        case media_type
        when 'audio'
          cfg['autoplay'] = qs['autoplay'] || data[:autoplay] || cfg['autoplay']
          cfg['loop'] = qs['loop'] || data[:loop] || cfg['loop']
          cfg['style'] += ';display: none;' if qs['hidden']
          content = handle_audio(content, { target: match_data[0], cfg: cfg })
        when 'video'
          cfg['title'] = title
          cfg['width'] = qs['width'] || data[:width] || cfg['width']
          cfg['height'] = qs['height'] || data[:height] || cfg['height']
          cfg['frameborder'] = qs['frameborder'] || cfg['frameborder']
          cfg['allow'] ||= cfg['allow']
          content = handle_video(content, { target: match_data[0], cfg: cfg })
        end
        self.handled = true
      end
      content
    end

    def handle_audio(content, data)
      cfg = data[:cfg]
      html = "<audio"\
        " id=\"#{cfg['id']}\""\
        " class=\"#{cfg['class']}\""\
        " #{cfg['autoplay'] ? 'autoplay' : ''}"\
        " #{cfg['loop'] ? 'loop' : ''}"\
        " src=\"#{cfg['src']}\""\
        " style=\"#{cfg['style']}\""\
        " controls>" \
        "<p> Your browser doesn't support HTML5 audio."\
        " Here is a <a href=\"#{cfg['src']}\">link to download the audio</a>"\
        "instead. </p>"\
        "</audio>"
      content.gsub(data[:target], html)
    end

    def handle_video(content, data)
      cfg = data[:cfg]
      html = "<iframe"\
        " id=\"#{cfg['id']}\""\
        " class=\"#{cfg['class']}\""\
        " src=\"#{cfg['src']}\""\
        " title=\"#{cfg['title']}\""\
        " width=\"#{cfg['width']}\""\
        " height=\"#{cfg['height']}\""\
        " style=\"#{cfg['style']}\""\
        " allow=\"#{cfg['allow']}\""\
        " frameborder=\"#{cfg['frameborder']}\""\
        " allowfullscreen>"\
        "</iframe>"
      content.gsub(data[:target], html)
    end
  end
end
