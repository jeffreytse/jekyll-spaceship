# frozen_string_literal: true

require "ostruct"
require "nokogiri"

module Jekyll::Spaceship
  class TableProcessor < Processor
    def on_handle_markdown(content)
      # pre-handle reference-style links
      references = {}
      content.scan(/(\[(.*)\]:\s*(.*))/) do |match_data|
        ref_name = match_data[1]
        ref_value = match_data[2]
        references[ref_name] = ref_value
      end
      if references.size > 0
        content.scan(/.*(?<!\\)\|.*/) do |result|
          references.each do |key, val|
            replace = result.gsub(/\[(.*)\]\s*\[#{key}\]/, "[\1](#{val})")
            next if result == replace
            content = content.gsub(result, replace)
          end
        end
      end

      # pre-handle row-span
      content = content.gsub(/(?<!\\)(\|.*\\\s*)\|\s*\n/, "\\1\n")

      # escape | and :
      content = content.gsub(/\|(?=\|)/, '\\|')
        .gsub(/\\:(?=.*?(?<!\\)\|)/, '\\\\\\\\:')
        .gsub(/((?<!\\)\|.*?)(\\:)/, '\1\\\\\\\\:')

      # escape * and _ and $ etc.
      content.scan(/.*(?<!\\)\|.*/) do |result|
        replace = result.gsub(
          /(?<!(?<!\\)\\)(\*|\$|\[|\(|\"|_)/,
          '\\\\\\\\\1')
        next if result == replace
        content = content.gsub(result, replace)
      end
      content
    end

    def on_handle_html(content)
      # use nokogiri to parse html content
      doc = Nokogiri::HTML(content)

      data = self.table_scope_data

      # handle each table
      doc.css('table').each do |table|
        rows = table.css('tr')
        data.table = table
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
        rows.each do |row|
          cells = row.css('th, td')
          cells.each do |cell|
            data.cell = cell
            handle_format(data)
          end
        end
        self.handled = true
      end

      doc.to_html
    end

    def table_scope_data
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
      data
    end

    def handle_colspan(data)
      scope = data.scope.call __method__
      cells = data.cells
      cell = data.cell

      if scope.table.row != data.row
        scope.table.row = data.row
        scope.row.colspan = 0
      end

      # handle colspan
      if cell == cells.last and scope.row.colspan > 0
        cells.count.downto(cells.count - scope.row.colspan + 1) do |i|
          c = cells[i - 1]
          return unless c.get_attribute('colspan').nil?
          c.remove
        end
      end

      result = cell.content.match(/(\|)+$/)
      return if result.nil?

      cell.content = cell.content.gsub(/(\|)+$/, '')
      result = result[0]
      colspan = result.scan(/\|/).count
      scope.row.colspan += colspan
      cell.set_attribute('colspan', colspan + 1)
    end

    def handle_multi_rows(data)
      scope = data.scope.call __method__
      cells = data.cells
      row = data.row
      cell = data.cell

      if scope.table.table != data.table
        scope.table.table = data.table
        scope.table.multi_row_cells = nil
        scope.table.multi_row_start = false
      end

      # handle multi-rows
      return if cell != cells.last

      match = cell.content.match(/(?<!\\)\\\s*$/)
      if match
        cell.content = cell.content.gsub(/(?<!\\)\\\s*$/, '')
        if not scope.table.multi_row_start
          scope.table.multi_row_cells = cells
          scope.table.multi_row_start = true
        end
      end

      if scope.table.multi_row_cells != cells and scope.table.multi_row_start
        for i in 0...scope.table.multi_row_cells.count do
          multi_row_cell = scope.table.multi_row_cells[i]
          multi_row_cell.content += "  \n#{cells[i].content}"
        end
        row.remove
      end
      scope.table.multi_row_start = false if not match
    end

    def handle_rowspan(data)
      scope = data.scope.call __method__
      cell = data.cell
      cells = data.cells

      if scope.table.table != data.table
        scope.table.table = data.table
        scope.table.span_row_cells = []
      end
      if scope.row.row != data.row
        scope.row.row = data.row
        scope.row.col_index = 0
      end

      # handle rowspan
      span_cell = scope.table.span_row_cells[scope.row.col_index]
      if span_cell and cell.content.match(/^\s*\^{2}/)
        cell.content = cell.content.gsub(/^\s*\^{2}/, '')
        span_cell.content += "  \n#{cell.content}"
        rowspan = span_cell.get_attribute('rowspan') || 1
        rowspan = rowspan.to_i + 1
        span_cell.set_attribute('rowspan', "#{rowspan}")
        cell.remove
      else
        scope.table.span_row_cells[scope.row.col_index] = cell
      end
      scope.row.col_index += [cell.get_attribute('colspan').to_i, 1].max
    end

    def handle_text_align(data)
      cell = data.cell

      # pre-handle text align
      align = 0
      if cell.content.match(/^\s*:(?!:)/)
        cell.content = cell.content.gsub(/^\s*:/, '')
        align += 1
      end
      if cell.content.match(/(?<!\\):\s*$/)
        cell.content = cell.content.gsub(/:\s*$/, '')
        align += 2
      end

      # handle escape colon
      cell.content = cell.content.gsub(/\\:/, ':')

      # handle text align
      return if align == 0
      style = cell.get_attribute('style')
      if align == 1
        align = 'text-align: left'
      elsif align == 2
        align = 'text-align: right'
      elsif align == 3
        align = 'text-align: center'
      end

      # handle existed inline-style
      if style&.match(/text-align:.+/)
        style = style.gsub(/text-align:.+/, align)
      else
        style = align
      end
      cell.set_attribute('style', style)
    end

    def handle_format(data)
      cell = data.cell
      cvter = self.converter('markdown')
      return if cvter.nil?
      content = cell.content.gsub(/(?<!\\)\|/, '\\|')
      content = cvter.convert(content.strip)
      cell.inner_html = Nokogiri::HTML.fragment(content)
    end
  end
end
