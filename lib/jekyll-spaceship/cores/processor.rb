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
    attr_reader :priority
    attr_reader :registers
    attr_reader :exclusions
    attr_accessor :handled

    def name
      self.class.name.split('::').last
    end

    def initialize()
      self.initialize_priority
      self.initialize_register
      self.initialize_exclusions
      @logger = Logger.new(self.name)
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
        self.class.register :posts, :pre_render, :post_render
      end
      @registers = Array.new @@_registers
      @@_registers.clear
    end

    def initialize_exclusions
      if @@_exclusions.size.zero?
        self.class.exclude :code, :block_quotes
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
      file = page.path.gsub(/.*_posts\//, '')
      logger.log file
    end

    def pre_exclude(content)
      @exclusion_store = []
      @exclusions.each do |type|
        regex = nil
        if type == :code
          regex = /(`{3}\s*(\w*)((?:.|\n)*?)`{3})/
        end
        next if regex.nil?
        content.scan(regex) do |match_data|
          match = match_data[0]
          id = @exclusion_store.size
          content = content.gsub(match, "[//]: JEKYLL_EXCLUDE_##{id}")
          @exclusion_store.push match
        end
      end
      content
    end

    def after_exclude(content)
      while @exclusion_store.size > 0
        match = @exclusion_store.pop
        id = @exclusion_store.size
        content = content.gsub("[//]: JEKYLL_EXCLUDE_##{id}", match)
      end
      @exclusion_store = []
      content
    end
  end
end
