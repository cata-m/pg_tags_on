# frozen_string_literal: true

module DatabaseHelpers
  def establish_connection
    ActiveRecord::Base.establish_connection(config)
  end

  def config
    @config ||= begin
      file = File.expand_path('../config/database.yml', File.dirname(__FILE__))
      YAML.safe_load(ERB.new(File.read(file)).result)
    end
  end

  def load_schema
    @connection = ActiveRecord::Base.connection
    @connection.drop_table :entities
    @connection.transaction do
      @connection.create_table :entities, force: true do |t|
        t.integer :tags_int, array: true
        t.string  :tags_str, array: true
        t.text    :tags_text, array: true
        t.jsonb   :tags_jsonb, array: true
        t.string  :attr
      end
      @connection.add_index :entities, :tags_str, using: 'gin'
    end
  end

  def truncate
    ActiveRecord::Base.connection.truncate(Entity.table_name)
  end

  def encode_json(json)
    case json
    when String
      ActiveSupport::JSON.encode(json)
    when Hash
      ActiveSupport::JSON.encode(json.to_json)
    when Array
      "'{" + json.map { |item| encode_json(item) }.join(',') + "}'"
    end
  end

  module_function :config, :establish_connection, :load_schema, :truncate
end
