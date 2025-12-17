class ImportLogger
  attr_reader :stats, :logs

  def initialize
    @logs = []
    @stats = {
      restaurants: default_stats,
      menus: default_stats,
      menu_items: default_stats
    }
  end

  def info(message)
    log("INFO", message)
  end

  def error(message)
    log("ERROR", message)
  end

  def increment(type, key)
    @stats[type][key] += 1
  end

  private

  def default_stats
    { created: 0, updated: 0, errors: 0 }
  end

  def log(level, message)
    entry = {
      timestamp: Time.current.strftime("%Y-%m-%d %H:%M:%S"),
      level: level,
      message: message
    }

    @logs << entry
    Rails.logger&.public_send(level.downcase, message)
  end
end
