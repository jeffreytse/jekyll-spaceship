# frozen_string_literal: true

require "ostruct"
require 'nokogiri'

module Jekyll::Spaceship
  class TableProcessor < Processor
    register :posts, :pre_render, :post_render

    def on_posts_pre_render(post)
      # pre-handle table in markdown
      post.content = post.content
        .gsub(/\|(?=\|)/, '\\|')
        .gsub(/\\:(?=.*?(?<!\\)\|)/, '\\\\\\\\:')
        .gsub(/((?<!\\)\|.*?)(\\:)/, '\1\\\\\\\\:')
    end

    def on_posts_post_render(post)
      # use nokogiri to parse html content
      doc = Nokogiri::HTML(post.content)

      data = OpenStruct.new(_: OpenStruct.new)
      data.reset = ->(scope, namespace = nil) {
        data._.marshal_dump.each do |key, val|
          if namespace == key or namespace.nil?
            data._[key][scope] = OpenStruct.new
          end
        end
      }
      data.scope = ->(namespace) {
        if not data._[namespace]
          data._[namespace] = OpenStruct.new(
            table: OpenStruct.new,
            row: OpenStruct.new
          )
        end
        data._[namespace]
      }

      # handle each table
      doc.css('table').each do |table|
        rows = table.css('tr')
        data.table= table
        data.rows = rows
        data.reset.call :table
        rows.each do |row|
          cells = row.css('th, td')
          data.row = row
          data.cells = cells
          data.reset.call :row
          cells.each do |cell|
            data.cell = cell
            handle_colspan(data)
            handle_multi_rows(data)
            handle_text_align(data)
            handle_rowspan(data)
          end
        end
      end

      post.content = doc.at('body').inner_html
    end

    def handle_colspan(data)
      scope = data.scope.call __method__
      scope_table = scope.table
      scope_row = scope.row
      cells = data.cells
      cell = data.cell

      if scope_table.row != data.row
        scope_table.row = data.row
        scope_row.colspan = 0
      end

      # handle colspan
      result = cell.content.match(/(\s*\|)+$/)
      if cell == cells.last and scope_row.colspan > 0
        range = (cells.count - scope_row.colspan)...cells.count
        for i in range do
          cells[i].remove
        end
      end
      if result
        result = result[0]
        scope_row.colspan += result.scan(/\|/).count
        cell.content = cell.content.gsub(/(\s*\|)+$/, "")
        cell.set_attribute("colspan", scope_row.colspan + 1)
      end
    end

    def handle_multi_rows(data)
      scope = data.scope.call __method__
      scope_table = scope.table
      cells = data.cells
      row = data.row
      cell = data.cell

      if scope_table.table != data.table
        scope_table.table = data.table
        scope_table.multi_row_cells = nil
        scope_table.multi_row_start = false
      end

      # handle multi-rows
      return if cell != cells.last

      match = cell.content.match(/\\$/)
      if match
        cell.content = cell.content.gsub(/\\$/, '')
        if not scope_table.multi_row_start
          scope_table.multi_row_cells = cells
          scope_table.multi_row_start = true
        end
      end

      if scope_table.multi_row_cells != cells and scope_table.multi_row_start
        for i in 0...scope_table.multi_row_cells.count do
          scope_table.multi_row_cells[i].inner_html += "<br>#{cells[i].content}"
        end
        row.remove
      end
      scope_table.multi_row_start = false if not match
    end

    def handle_rowspan(data)
      scope = data.scope.call __method__
      scope_table = scope.table
      scope_row = scope.row
      cell = data.cell
      cells = data.cells

      if scope_table.table != data.table
        scope_table.table = data.table
        scope_table.span_row_cells = []
      end

      if scope_row.row != data.row
        scope_row.row = data.row
        scope_row.col_index = 0
      end

      # handle rowspan
      span_cell = scope_table.span_row_cells[scope_row.col_index]
      if span_cell and cell.content.match(/^\^{2}/)
        cell.content = cell.content.gsub(/^\^{2}/, "")
        span_cell.inner_html += "<br>#{cell.content}"
        rowspan = span_cell.get_attribute("rowspan") || 1
        rowspan = rowspan.to_i + 1
        span_cell.set_attribute("rowspan", "#{rowspan}")
        cell.remove
      else
        scope_table.span_row_cells[scope_row.col_index] = cell
      end

      scope_row.col_index += 1
    end

    def handle_text_align(data)
      cell = data.cell

      # pre-handle text align
      align = 0
      if cell.content.match(/^:(?!:)/)
        cell.content = cell.content.gsub(/^:/, "")
        align += 1
      end
      if cell.content.match(/(?<!\\):$/)
        cell.content = cell.content.gsub(/:$/, "")
        align += 2
      end

      # handle escape colon
      cell.content = cell.content.gsub(/\\:/, ":")

      # handle text align
      return if align == 0

      style = cell.get_attribute("style")
      if align == 1
        align = "text-align: left"
      elsif align == 2
        align = "text-align: right"
      elsif align == 3
        align = "text-align: center"
      end

      # handle existed inline-style
      if style&.match(/text-align:.+/)
        style = style.gsub(/text-align:.+/, align)
      else
        style = align
      end
      cell.set_attribute("style", style)
    end
  end
end
