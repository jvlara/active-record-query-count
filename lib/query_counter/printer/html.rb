require 'erb'
require 'tempfile'
require 'launchy'

module QueryCounter
  module Printer
    class Html < Base
      TEMPLATE = <<-HTML
      <!DOCTYPE html>
      <html>
      <head>
        <title>Query Counter Report</title>
        <style>
          body { font-family: Arial, sans-serif; }
          table { width: 100%; border-collapse: collapse; }
          th, td { border: 1px solid #ddd; padding: 8px; }
          th { background-color: #f2f2f2; }
          tr:nth-child(even) { background-color: #f9f9f9; }
          .sub-row { background-color: #f9f9f9; }
        </style>
      </head>
      <body>
        <h2>Query Counter Report</h2>
        <p>Total query count: <%= total_query_count %></p>
        <table>
          <tr>
            <th>Table</th>
            <th>Total Query Count</th>
            <th>Location</th>
            <th>Location Count</th>
          </tr>
          <% data.each do |table, info| %>
            <tr>
              <td rowspan="<%= info[:location].size + 1 %>"><%= table %></td>
              <td rowspan="<%= info[:location].size + 1 %>"><%= info[:count] %></td>
            </tr>
            <% info[:location].each do |loc, count| %>
              <tr class="sub-row">
                <td><%= loc %></td>
                <td><%= count %></td>
              </tr>
            <% end %>
          <% end %>
        </table>
      </body>
      </html>
      HTML

      def self.print(raw_data)
        data = data(raw_data)
        total_query_count = data.values.sum { |v| v[:count] }
        template = ERB.new(TEMPLATE)
        html_content = template.result(binding)

        # Ver porque cuando se cierra el proceso de borra el archivo y con ello la vista de chrome
        file = Tempfile.new(['query_counter_report', '.html'])
        file.write(html_content)
        file.close
        if ENV['WSL_DISTRIBUTION']
          Launchy.open("file://wsl%24/#{ENV["WSL_DISTRIBUTION"]}#{file.path}")
          binding.pry
        else
          Launchy.open(file.path)
        end
      end
    end
  end
end