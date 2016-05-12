=begin
  Tag to include Markdown text from _includes directory preprocessing with Liquid.
=end
require "redcarpet"
module Jekyll
  class MarkdownTag < Liquid::Tag
    def initialize(tag_name, text, tokens)
      super
      @text = text.strip
      @renderer = Redcarpet::Markdown.new(Redcarpet::Render::HTML.new())
    end
    def render(context)
      tmpl = File.read File.join Dir.pwd, "_includes", @text
      site = context.registers[:site]
      tmpl = (Liquid::Template.parse tmpl).render site.site_payload
      html = @renderer.render(tmpl)
    end
  end
end
Liquid::Template.register_tag('markdown', Jekyll::MarkdownTag)
