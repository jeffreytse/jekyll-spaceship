# frozen_string_literal: true

require 'nokogiri'

module Jekyll::Spaceship
  class Processor
    @@_hooks = {}
    @@_registers = []
    @@_processers = []
    @@_exclusions = []
    @@_priority = nil

    attr_accessor :priority
    attr_accessor :page
    attr_accessor :handled

    DEFAULT_PRIORITY = 20

    PRIORITY_MAP = {
      :low    => 10,
      :normal => 20,
      :high   => 30,
    }.freeze

    HTML_EXTENSIONS = %w(
      .html
      .xhtml
      .htm
    ).freeze

    CSS_EXTENSIONS = %w(
      .css
      .scss
    ).freeze

    MD_EXTENSIONS = %w(
      .md
      .markdown
    ).freeze

    def initialize()
      self.initialize_priority
      self.initialize_register
      self.initialize_exclusions
    end

    def initialize_priority
      @@_priority = DEFAULT_PRIORITY if @@_priority.nil?
      @priority = @@_priority
      @@_priority = nil

      @@_processers.push(self)
      @@_processers = @@_processers.sort { |a, b| b.priority <=> a.priority }
    end

    def initialize_register
      if @@_registers.size.zero?
        self.class.register :pages, :pre_render, :post_render
        self.class.register :posts, :pre_render, :post_render
      end

      @@_registers.each do |_register|
        container = _register.first
        events = _register.last.uniq
        events = events.select do |event|
          next true if event.match(/^post/)
          next !events.any?(event.to_s.gsub(/^pre/, 'post').to_sym)
        end
        events.each do |event|
          self.class.hook container, event
        end
      end
      @@_registers.clear
    end

    def initialize_exclusions
      if @@_exclusions.size.zero?
        self.class.exclude :code, :block_quotes
      end
      @_exclusions = @@_exclusions.uniq
      @@_exclusions.clear
    end

    def self.priority(value)
      value = value.to_sym
      if PRIORITY_MAP.has_key? value
        @@_priority = PRIORITY_MAP[value]
      elsif value.nil?
        @@_priority = DEFAULT_PRIORITY
      else
        @@_priority = value
      end
    end

    def self.register(container, *events)
      @@_registers << [container, events]
    end

    def self.hook_register(container, event)
      hook_name = "#{container}_#{event}".to_sym
      return false if @@_hooks.has_key? hook_name
      @@_hooks[hook_name] = true
    end

    def self.hook(container, event, &block)
      return if not hook_register container, event

      # define dispatch proc
      dispatch = ->(instance) {
        @@_processers.each do |processor|
          processor.page = instance
          processor.handled = false
          next if not processor.process?
          processor.dispatch container, event
        end
        if event.to_s.start_with?('post') and self.html? output_ext(instance)
          self.handle_html_block(instance)
        end
        @@_processers.each do |processor|
          processor.page = instance
          if processor.handled
            processor.on_handled
          end
        end
        block.call if block
      }

      if event.to_s.start_with?('after')
        Jekyll::Hooks.register container, event do |instance|
          dispatch.call instance
        end
      elsif event.to_s.start_with?('post')
        Jekyll::Hooks.register container, event do |instance|
          dispatch.call instance
        end

        # auto add pre-event
        register container, event.to_s.sub('post', 'pre').to_sym
      elsif event.to_s.start_with?('pre')
        Jekyll::Hooks.register container, event do |instance|
          dispatch.call instance
        end
      end
    end

    def dispatch(container, event)
      method = "on_#{container}_#{event}"
      self.send method, @page if self.respond_to? method

      if event.to_s.start_with?('pre')
        if markdown? ext
          method = 'on_handle_markdown'
        else
          method = ''
        end

        if self.respond_to? method
          @page.content = self.pre_exclude @page.content
          @page.content = self.send method, @page.content
          @page.content = self.after_exclude @page.content
        end
      else
        if html? output_ext
          method = 'on_handle_html'
        elsif css? output_ext
          method = 'on_handle_css'
        else
          method = ''
        end

        if self.respond_to? method
          @page.output = self.send method, @page.output
        end
      end
    end

    def self.exclude(*types)
      @@_exclusions = types
    end

    def html?(_ext)
      self.class.html? _ext
    end

    def css?(_ext)
      self.class.css? _ext
    end

    def markdown?(_ext)
      self.class.markdown? _ext
    end

    def self.html?(_ext)
      HTML_EXTENSIONS.include?(_ext)
    end

    def self.css?(_ext)
      CSS_EXTENSIONS.include?(_ext)
    end

    def self.markdown?(_ext)
      MD_EXTENSIONS.include?(_ext)
    end

    def converter(name)
      self.class.converter(@page, name)
    end

    def self.converter(instance, name)
      instance.site.converters.each do |converter|
        class_name = converter.class.to_s.downcase
        return converter if class_name.end_with?(name.downcase)
      end
    end

    def ext
      self.class.ext @page
    end

    def output_ext
      self.class.output_ext @page
    end

    def self.ext(instance)
      instance.data['ext']
    end

    def self.output_ext(instance)
      instance.url_placeholders[:output_ext]
    end

    def process?
      html?(output_ext) or markdown?(ext)
    end

    def pre_exclude(content)
      @_exclusion_store = []
      @_exclusions.each do |type|
        regex = nil
        if type == :code
          regex = /(`{3}\s*(\w*)((?:.|\n)*?)`{3})/
        end
        next if regex.nil?
        content.scan(regex) do |match_data|
          match = match_data[0]
          id = @_exclusion_store.size
          content = content.gsub(match, "[//]: JEKYLL_EXCLUDE_##{id}")
          @_exclusion_store.push match
        end
      end
      content
    end

    def after_exclude(content)
      while @_exclusion_store.size > 0
        match = @_exclusion_store.pop
        id = @_exclusion_store.size
        content = content.gsub("[//]: JEKYLL_EXCLUDE_##{id}", match)
      end
      @_exclusion_store = []
      content
    end

    def on_handled
      processor = self.class.name.split('::').last
      file = page.path.gsub(/.*_posts\//, '')
      Logger.log "[#{processor}] #{file}"
    end

    def self.handle_html_block(instance)
      doc = Nokogiri::HTML(instance.output)

      doc.css('script').each do |node|
        blk_type = node['type']
        blk_content = node.content

        cvter = nil
        method = ''
        block_method = 'on_handle_html_block'

        case blk_type
        when 'text/markdown'
          method = 'on_handle_markdown'
          cvter = self.converter(instance, 'markdown')
        end

        @@_processers.each do |processor|
          processor.page = instance
          next if not processor.process?

          # dispatch to on_handle_html_block
          if processor.respond_to? block_method
            blk_content = processor.send block_method blk_content, blk_type
          end

          # dispatch to other handlers
          if processor.respond_to? method
            blk_content = processor.pre_exclude blk_content
            blk_content = processor.send method, blk_content
            blk_content = processor.after_exclude blk_content
          end
        end

        if not cvter.nil?
          blk_content = cvter.convert blk_content
        end

        next if method == ''

        method = 'on_handle_html'
        @@_processers.each do |processor|
          processor.page = instance
          next if not processor.process?
          if processor.respond_to? method
            blk_content = processor.send method, blk_content
          end
        end

        node.replace Nokogiri::HTML.fragment(blk_content)
      end

      instance.output = doc.to_html
    end
  end
end
