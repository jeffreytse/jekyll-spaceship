# frozen_string_literal: true

module Jekyll::Spaceship
  class Config
    CONFIG_NAME = 'jekyll-spaceship'
    DEFAULT_CONFIG = {
      'processors' => [
        'table-processor',
        'mathjax-processor',
        'plantuml-processor',
        'mermaid-processor',
        'polyfill-processor',
        'video-processor',
        'emoji-processor',
        'element-processor'
      ]
    }

    @@store = {}

    def self.deep_merge(first, second)
      merger = proc do |_, f, s|
        if Hash === f && Hash === s
          f.merge(s, &merger)
        elsif Array === f && Array === s
          s || f
        else
          [:undefined, nil, :nil].include?(s) ? f : s
        end
      end
      first.merge(second.to_h, &merger)
    end

    def self.store(section, default)
      return @@store[section] if default.nil?
      @@store[section] = deep_merge(default, @@store[section])
    end

    def self.load(config = {})
      config = deep_merge(
        { CONFIG_NAME => DEFAULT_CONFIG },
        config
      )[CONFIG_NAME]
      @@store = config
      self.use_processors(config)
    end

    def self.use_processors(config)
      config['processors'].each do |processor|
        Register.use processor
      end
    end

    def self.load_config
      # post load site config for `group :jekyll_plugin`
      Jekyll::Hooks.register :site, :after_init do |site|
        self.load(site.config)
      end
    end
  end
end
