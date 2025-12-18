require_relative "boot"

require "rails/all"

Bundler.require(*Rails.groups)

module MenuManagementApi
  class Application < Rails::Application
    config.load_defaults 8.1

    config.autoload_lib(ignore: %w[assets tasks])
    config.assets.paths << Rails.root.join("app", "assets", "stylesheets")
  end
end
