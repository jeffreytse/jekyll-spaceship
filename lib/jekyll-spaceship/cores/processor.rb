# frozen_string_literal: true

module Jekyll::Spaceship
  class Processor
    DEFAULT_PRIORITY = 20

    PRIORITY_MAP = {
      :lowest  => 0,
      :low     => 10,
      :normal  => 20,
      :high    => 30,
      :highest => 40,
    }.freeze

    @@_registers = []
    @@_exclusions = []
    @@_priority = nil

    attr_reader :page
    attr_reader :logger
    attr_reader :config
    attr_reader :priority
    attr_reader :registers
    attr_reader :exclusions
    attr_accessor :handled

    def name
      self.class.name.split('::').last
    end

    def filename
      self.name
        .gsub(/([A-Z]+)([A-Z][a-z])/,'\1-\2')
        .gsub(/([a-z\d])([A-Z])/,'\1-\2')
        .tr("_", "-")
        .downcase
    end

    def initialize()
      self.initialize_priority
      self.initialize_register
      self.initialize_exclusions
      @logger = Logger.new(self.name)
      @config = Config.store(self.filename, self.class.config)
      @handled_files = {}
    end

    def initialize_priority
      @priority = @@_priority
      unless @priority.nil? or @priority.is_a? Numeric
        @priority = PRIORITY_MAP[@priority.to_sym]
      end
      @priority = DEFAULT_PRIORITY if @priority.nil?
      @@_priority = nil
    end

    def initialize_register
      if @@_registers.size.zero?
        self.class.register :pages, :pre_render, :post_render
        self.class.register :documents, :pre_render, :post_render
      end
      @registers = Array.new @@_registers
      @@_registers.clear
    end

    def initialize_exclusions
      if @@_exclusions.size.zero?
        self.class.exclude :code, :math
      end
      @exclusions = @@_exclusions.uniq
      @@_exclusions.clear
    end

    def self.priority(value)
      @@_priority = value.to_sym
    end

    def self.register(container, *events)
      @@_registers << [container, events]
    end

    def self.exclude(*types)
      @@_exclusions = types
    end

    def self.config
    end

    def process?
      Type.html?(output_ext) or Type.markdown?(ext)
    end

    def ext
      Manager.ext @page
    end

    def output_ext
      Manager.output_ext @page
    end

    def converter(name)
      Manager.converter @page, name
    end

    def dispatch(page, container, event)
      @page = page
      @handled = false
      return unless self.process?
      method = "on_#{container}_#{event}"
      self.send method, @page if self.respond_to? method
      method = ''
      if event.to_s.start_with?('pre')
        if Type.markdown? ext
          method = 'on_handle_markdown'
        end
        if self.respond_to? method
          @page.content = self.pre_exclude @page.content
          @page.content = self.send method, @page.content
          @page.content = self.after_exclude @page.content
        end
      else
        if Type.html? output_ext
          method = 'on_handle_html'
        elsif css? output_ext
          method = 'on_handle_css'
        end
        if self.respond_to? method
          @page.output = self.send method, @page.output
          if Type.html? output_ext
            @page.output = self.class.escape_html(@page.output)
          end
        end
      end
    end

    def on_handle_html_block(content, type)
      # default handle method
      content
    end

    def on_handle_html(content)
      # default handle method
      content
    end

    def on_handled
      source = page.site.source
      file = page.path.sub(/^#{source}\//, '')
      return if @handled_files.has_key? file
      @handled_files[file] = true
      logger.log file
    end

    def pre_exclude(content)
      @exclusion_store = []
      @exclusions.each do |type|
        regex = nil
        if type == :code
          regex = /((`+)\s*(\w*)((?:.|\n)*?)\2)/
        elsif type == :math
          regex = /(((?<!\\)\${1,2})[^\n]*?\1)/
        end
        next if regex.nil?
        content.scan(regex) do |match_data|
          match = match_data[0]
          id = @exclusion_store.size
          content = content.sub(match, "[JEKYLL@#{object_id}@#{id}]")
          @exclusion_store.push match
        end
      end
      content
    end

    def after_exclude(content)
      while @exclusion_store.size > 0
        match = @exclusion_store.pop
        id = @exclusion_store.size
        content = content.sub("[JEKYLL@#{object_id}@#{id}]", match)
      end
      @exclusion_store = []
      content
    end

    def self.escape_html(content)
      # escape link
      content.scan(/((https?:)?\/\/\S+\?[a-zA-Z0-9%\-_=\.&;]+)/) do |result|
        result = result[0]
        link = result.gsub('&amp;', '&')
        content = content.gsub(result, link)
      end
      content
    end
  end
end
