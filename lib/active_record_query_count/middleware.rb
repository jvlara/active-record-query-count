require 'json'
require 'nokogiri'

module ActiveRecordQueryCount
  class Middleware
    def initialize(app)
      @app = app
    end

    def call(env)
      return @app.call(env) unless Configuration.enable_middleware

      status, headers, response, query_count_data = nil
      ActiveRecordQueryCount.start_recording
      status, headers, response = @app.call(env)
      query_count_data = ActiveRecordQueryCount.tracker.active_record_query_tracker.clone
      ActiveRecordQueryCount.end_recording(printer: :none)
      if headers['Content-Type']&.include?('text/html') && response.respond_to?(:body) && response.body['<body']
        response_body = inject_query_counter_js(response.body, query_count_data)
        headers['Content-Length'] = response_body.bytesize.to_s
        response = [response_body]
      end
      [status, headers, response]
    end

    def inject_query_counter_js(response_body, query_count_data)
      injected_html = ::ActiveRecordQueryCount::Printer::Html.new(data: query_count_data).inject_in_html
      # Parse the response body with Nokogiri
      doc = Nokogiri::HTML(response_body)

      # Inject the query counter JS before the closing </body> tag
      doc.at('body').add_child(injected_html)

      doc.to_html
    end
  end
end
