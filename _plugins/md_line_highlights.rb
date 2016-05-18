module Jekyll
  class RedcarpetWithoutPygmentsParser < Converter
    safe true
    priority :high

    def initialize(config)
      require 'redcarpet'

      @config = config
      @redcarpet_extensions = {}
      @config['redcarpet']['extensions'].each { |e| @redcarpet_extensions[e.to_sym] = true }

      @renderer ||= Class.new(Redcarpet::Render::HTML) do
        def block_code(code, lang)
          lang_parts = lang && lang.split('{')
          lang = lang_parts && !lang_parts[0].empty? && lang_parts[0] || 'text'
          hl_lines = ''
          if lang_parts && lang_parts.size >= 2
            hl_lines = lang_parts[1].gsub(/[{}]/, '')
          end
          if !lang or lang == 'bash' or lang == 'text'
              line_numbers = ''
          else
              line_numbers = "line-numbers"
          end
          escaped_html = CGI::escapeHTML(code)
          escaped_html.gsub!(/&lt;(\/ ?)?mark\s*&gt;/i,'<\1mark>')
          open_pre = "<pre data-line=\"#{hl_lines}\" class=\"#{line_numbers}\">"
          output = open_pre + '<code class="language-' + lang + '">' + escaped_html + '</code></pre>'
          return output
        end
      end
    rescue LoadError
      STDERR.puts 'You are missing a library required for Markdown. Please run:'
      STDERR.puts '  $ [sudo] gem install redcarpet'
      raise FatalException.new("Missing dependency: redcarpet")
    end


    def matches(ext)
      rgx = '(' + @config['markdown_ext'].gsub(',','|') +')'
      ext =~ Regexp.new(rgx, Regexp::IGNORECASE)
    end

    def output_ext(ext)
      ".html"
    end

    def convert(content)
      @redcarpet_extensions[:fenced_code_blocks] = !@redcarpet_extensions[:no_fenced_code_blocks]
      @renderer.send :include, Redcarpet::Render::SmartyPants if @redcarpet_extensions[:smart]
      markdown = Redcarpet::Markdown.new(@renderer.new(@redcarpet_extensions), @redcarpet_extensions)
      markdown.render(content)
    end
  end
end
