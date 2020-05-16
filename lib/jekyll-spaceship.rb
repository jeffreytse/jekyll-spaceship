# frozen_string_literal: true

require 'jekyll-spaceship/cores/logger'
require 'jekyll-spaceship/cores/manager'
require 'jekyll-spaceship/cores/processor'
require 'jekyll-spaceship/cores/register'

module Jekyll::Spaceship
  Logger.display_info
  Register.use 'table-processor'
  Register.use 'mathjax-processor'
  Register.use 'plantuml-processor'
  Register.use 'polyfill-processor'
  Register.use 'video-processor'
  Register.use 'emoji-processor'
end
