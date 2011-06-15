module Themenap
  class Config
    class << self
      attr_accessor :active, :server, :server_path, :verify_ssl, :use_basic_auth,
                    :layout_name, :layout_root, :layout_path, :snippets

      def configure
        yield self if block_given?
      end
    end
  end

  Themenap::Config.configure do |c|
    c.active = false
    c.server = 'http://www.gavrog.org'
    c.server_path = ''
    c.verify_ssl = true
    c.use_basic_auth = false
    c.layout_name = 'theme'
    c.layout_root = ''
    c.layout_path = File.join 'app', 'views', 'layouts'
    c.snippets =
      [ { :css => 'title', :text => '<%= yield :title %>' },
        { :css => 'body', :text => '<%= yield %>' } ]
  end
end
