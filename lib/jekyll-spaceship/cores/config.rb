# frozen_string_literal: true

require 'yaml'

module Jekyll::Spaceship
  class Config
    CONFIG_NAME = 'jekyll-spaceship'
    DEFAULT_CONFIG = {
      'processors' => [
        'table-processor',
        'mathjax-processor',
        'plantuml-processor',
        'polyfill-processor',
        'video-processor',
        'emoji-processor'
      ],
      'mathjax-processor' => {
        'src' => '//cdn.mathjax.org/mathjax/latest/MathJax.js?config=TeX-AMS-MML_HTMLorMML',
        'config' => {
          'tex2jax' => { 'inlineMath' => [['$','$'], ['\\(','\\)']] }
        }
      },
      'plantuml-processor' => {
        'src' => 'http://www.plantuml.com/plantuml/png/'
      },
      'emoji-processor' => {
        'src' => 'https://github.githubassets.com/images/icons/emoji/'
      }
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

    def self.store(section)
      @@store[section]
    end

    def self.load(filename = '_config.yml')
      config = deep_merge(
        { CONFIG_NAME => DEFAULT_CONFIG },
        YAML.load_file(File.expand_path(filename))
      )[CONFIG_NAME]
      @@store = config
      self.use_processors(config)
    end

    def self.use_processors(config)
      config['processors'].each do |processor|
        Register.use processor
      end
    end
  end
end
