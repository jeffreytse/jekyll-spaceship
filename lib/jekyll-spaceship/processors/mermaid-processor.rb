# frozen_string_literal: true

require "net/http"
require "base64"
require "fileutils"
require "open3"
require "tempfile"

module Jekyll::Spaceship
  class MermaidProcessor < Processor
    exclude :none

    LOCAL_RENDERERS = {
      'pre-build' => :render_mermaid_figure,
      'pre-build-inline' => :render_mermaid_locally
    }.freeze
    PRE_FETCH_MODES = (LOCAL_RENDERERS.keys + ['pre-fetch']).freeze

    def self.config
      {
        'mode' => 'default',
        'syntax' => {
          'code' => 'mermaid!',
          'custom' => ['@startmermaid', '@endmermaid']
        },
        'css' => {
          'class' => 'mermaid'
        },
        'config': {
          'theme' => 'default'
        },
        'mmdc_args' => [],
        'src' => 'https://mermaid.ink/svg/'
      }
    end

    def on_handle_markdown(content)
      # match custom mermaid block and code block
      syntax = self.config['syntax']
      code_name = syntax['code']
      custom = syntax['custom'][-2, 2]

      patterns = [
        /((`{3,})\s*#{code_name}((?:.|\n)*?)\2)/,
        /((?<!\\)(#{custom[0]})((?:.|\n)*?)(?<!\\)(#{custom[1]}))/
      ]

      patterns.each do |pattern|
        content = handle_mermaid_block(pattern, content)
      end

      # handle escape custom mermaid block
      content.gsub(/\\(#{custom[0]}|#{custom[1]})/, '\1')
    end

    def handle_mermaid_block(pattern, content)
      content.scan pattern do |match|
        match = match.select { |m| not m.nil? }
        block = match[0]
        code = match[2]

        self.handled = true

        content = content.gsub(
          block,
          handle_mermaid(code)
        )
      end
      content
    end

    def handle_mermaid(code)
      # Handle extra empty lines, otherwise it would cause error
      code = code.gsub(/\n\s*\n/, "\n%%-\n")

      # encode to UTF-8
      code = code.encode('UTF-8')

      # render mode
      mode = self.config['mode']
      rendered = render_mermaid_by_mode(code, mode)
      return rendered if rendered.is_a?(String)

      data = rendered || fallback_mermaid_data(code, mode)

      # return img tag
      data['class'] = self.config['css']['class']
      self.class.make_img_tag(data)
    end

    def render_mermaid_by_mode(code, mode)
      renderer = LOCAL_RENDERERS[mode]
      return unless renderer

      rendered = send(renderer, code)
      logger.log "#{mode} failed; falling back to pre-fetch" if rendered.nil?
      rendered
    end

    def fallback_mermaid_data(code, mode)
      url = get_url(code)
      fallback = { 'type' => 'url', 'body' => url }
      return fallback unless PRE_FETCH_MODES.include?(mode)

      data = self.class.fetch_img_data(url)
      logger.log 'pre-fetch failed; falling back to default URL' if data.nil?
      data || fallback
    end

    def render_mermaid_figure(code)
      require 'jekyll-mermaid-prebuild'

      cli_dir = local_mermaid_cli_dir
      unless cli_dir || JekyllMermaidPrebuild::MmdcWrapper.available?
        logger.log 'mmdc not found'
        return
      end

      with_mermaid_cli_path(cli_dir) do
        site = page.site
        prebuild_config = JekyllMermaidPrebuild::Configuration.new(site)
        generator = JekyllMermaidPrebuild::Generator.new(prebuild_config)
        return render_configured_mermaid_figure(
          code, site, prebuild_config, generator
        ) unless mmdc_args.empty?

        result = JekyllMermaidPrebuild::Processor.new(prebuild_config, generator)
          .convert_block(:content => code)
        return unless result

        register_mermaid_prebuild_svgs(site, prebuild_config, result[:svgs])
        result[:html]
      end
    rescue LoadError, StandardError => error
      logger.log "local Mermaid rendering failed: #{error.message}"
      nil
    end

    def register_mermaid_prebuild_svgs(site, prebuild_config, svgs)
      site.data['mermaid_prebuild_enabled'] = true
      site.data['mermaid_prebuild_config'] = prebuild_config
      site.data['mermaid_prebuild_svgs'] ||= {}
      site.data['mermaid_prebuild_svgs'].merge!(svgs)
    end

    def render_mermaid_locally(code)
      require 'jekyll-mermaid-prebuild'

      cli_dir = local_mermaid_cli_dir
      unless cli_dir || JekyllMermaidPrebuild::MmdcWrapper.available?
        logger.log 'mmdc not found'
        return
      end

      svg = Tempfile.new(['jekyll-spaceship-mermaid', '.svg'])
      begin
        rendered = with_mermaid_cli_path(cli_dir) do
          render_mermaid_svg(code, svg.path)
        end
        return unless rendered

        { 'type' => 'image/svg+xml', 'body' => File.read(svg.path) }
      ensure
        svg.close!
      end
    rescue LoadError, StandardError => error
      logger.log "local Mermaid rendering failed: #{error.message}"
      nil
    end

    def render_configured_mermaid_figure(code, site, prebuild_config, generator)
      cache_key = JekyllMermaidPrebuild::DigestCalculator.content_digest(
        ([code] + mmdc_args).join("\0")
      )
      cache_path = File.join(prebuild_config.cache_dir, "#{cache_key}.svg")

      unless File.exist?(cache_path)
        FileUtils.mkdir_p(prebuild_config.cache_dir)
        return unless render_mermaid_svg(code, cache_path)
      end

      svgs = { cache_key => cache_path }
      register_mermaid_prebuild_svgs(site, prebuild_config, svgs)
      generator.build_figure_html(generator.build_svg_url(cache_key))
    end

    def mmdc_args
      Array(config['mmdc_args']).map(&:to_s)
    end

    def render_mermaid_svg(code, output_path)
      args = mmdc_args
      return JekyllMermaidPrebuild::MmdcWrapper.render(code, output_path) if args.empty?

      input = Tempfile.new(['jekyll-spaceship-mermaid', '.mmd'])
      begin
        input.write(code)
        input.close
        command = JekyllMermaidPrebuild::MmdcWrapper::MMDC_COMMAND
        _, _, status = Open3.capture3(
          command, '-i', input.path, '-o', output_path, '-e', 'svg', *args
        )
        status.success?
      ensure
        input.close!
      end
    end

    def local_mermaid_cli_dir
      local_mermaid_cli_roots.each do |root|
        bin = File.join(root, 'node_modules', '.bin')
        return bin if mermaid_cli_executable?(bin)
      end
      nil
    end

    def local_mermaid_cli_roots
      roots = [Dir.pwd]
      site = page.site if page && page.respond_to?(:site)
      roots.unshift(site.source) if site
      roots.uniq
    end

    def mermaid_cli_executable?(bin)
      command = File.join(bin, Gem.win_platform? ? 'mmdc.cmd' : 'mmdc')
      File.file?(command) && File.executable?(command)
    end

    def with_mermaid_cli_path(cli_dir)
      return yield unless cli_dir

      original_path = ENV['PATH']
      ENV['PATH'] = [cli_dir, original_path].compact.join(File::PATH_SEPARATOR)
      begin
        yield
      ensure
        ENV['PATH'] = original_path
      end
    end

    def get_url(code)
      src = self.config['src']

      # wrap code
      code = {
        'code' => code.gsub(/^\s*|\s*$/, ''),
        'mermaid' => config['config']
      }.to_json

      # set default method
      src += '{code}' if src.match(/\{.*\}/).nil?

      # encode to base64 string
      if src.include?('{code}')
        code = Base64.urlsafe_encode64(code, padding: false)
        return src.gsub('{code}', code)
      else
        raise "No supported src ! #{src}"
      end
    end
  end
end
