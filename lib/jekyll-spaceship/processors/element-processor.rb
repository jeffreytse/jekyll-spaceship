# frozen_string_literal: true

require 'nokogiri'

module Jekyll::Spaceship
  class ElementProcessor < Processor
    priority :lowest

    def self.config
      { 'css' => [] }
    end

    def on_handle_html(content)
      return content if config['css'].size.zero?

      # use nokogiri to parse html content
      doc = Nokogiri::HTML(content)

      # handle each css pattern
      config['css'].each do |data|
        data.each do |key, val|
          key = [key] if key.kind_of? String
          key.each do |pattern|
            nodes = doc.css(pattern)
            nodes.each do |element|
              handle_css_pattern({
                :doc => doc,
                :element => element,
                :data => val
              })
            end
            self.handled = true
          end
        end
      end

      doc.to_html
    end

    def handle_css_pattern(data)
      doc = data[:doc]
      element = data[:element]
      data = data[:data]

      if data.kind_of? String
        element.replace Nokogiri::HTML.fragment(data)
      elsif data.kind_of? Hash
        # set name
        element.name = data['name'] unless data['name'].nil?

        # set props
        data['props']&.each do |prop, val|
          next element.remove_attribute if val.nil?
          if val.kind_of? Array
            next if val.size != 2
            val = element[prop].sub(/#{val[0]}/, val[1])
          elsif val.kind_of? Hash
            result = []
            val.each { |k, v| result.push "#{k}: #{v}" }
            val = result.join(";")
          end
          element.set_attribute(prop, val)
        end

        # processing children
        return unless data.has_key?('children')
        return element.inner_html = nil if data['children'].nil?
        children = self.create_children({
          :doc => doc,
          :data => data['children']
        })

        # replace whole inner html
        unless data['children'].kind_of? Array
          return element.inner_html = children
        end

        if element.children.size.zero?
          return element.inner_html = children
        end

        index = data['children'].index(nil)
        if index.nil?
          return element.inner_html = children
        end

        # insert to the end of children
        if index == 0
          return element.children.last.after(children)
        end

        # insert to the begin of children
        rindex = data['children'].rindex { |item| !item.nil? }
        if index == rindex + 1
          return element.children.first.before children
        end

        # wrap the children
        element.children.first.before children[0..index]
        element.children.last.after children[index..children.size]
      end
    end

    def create_children(data)
      doc = data[:doc]
      data = data[:data]
      root = Nokogiri::HTML.fragment("")

      data = [data] unless data.kind_of? Array
      data.each do |child_data|
        node = self.create_element({
          :doc => doc,
          :data => child_data
        })
        next if node.nil?
        unless child_data['children'].nil?
          node.children = self.create_children({
            :doc => doc,
            :data => child_data['children']
          })
        end
        root.add_child node
      end
      root.children
    end

    def create_element(data)
      doc = data[:doc]
      data = data[:data]

      return if data.nil?
      return Nokogiri::HTML.fragment(data) if data.kind_of? String
      return if data['name'].nil?

      # create node
      node = doc.create_element(data['name'])

      # set props
      data['props']&.each do |prop, val|
        if val.kind_of? Hash
          result = []
          val.each { |k, v| result.push "#{k}: #{v}" }
          val = result.join(";")
        end
        node.set_attribute(prop, val)
      end
      node
    end
  end
end
