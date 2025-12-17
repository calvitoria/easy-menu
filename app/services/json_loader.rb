class JsonLoader
  def initialize(json_data, file_name, logger)
    @json_data = json_data
    @file_name = file_name
    @logger = logger
  end

  def load
    return @json_data if @json_data.present?

    path = Rails.root.join(@file_name)
    unless @file_name && File.exist?(path)
      @logger.error("Import file could not be found.")
      return {}
    end

    JSON.parse(File.read(path))
  rescue JSON::ParserError
    @logger.error("The import file is not a valid JSON document.")
    {}
  end
end
