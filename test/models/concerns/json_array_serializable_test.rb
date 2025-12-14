require "test_helper"

class JsonArraySerializableTest < ActiveSupport::TestCase
  class DummyModel < ApplicationRecord
    self.table_name = "menus"

    include JsonArraySerializable
    json_array_field :categories
  end

  test "returns empty array when value is nil" do
    model = DummyModel.new
    assert_equal [], model.categories
  end

  test "serializes array to json string" do
    model = DummyModel.new
    model.categories = [ "vegan", "dessert" ]

    assert_equal [ "vegan", "dessert" ], model.categories
    assert_equal '["vegan","dessert"]', model.read_attribute(:categories)
  end

  test "handles invalid json gracefully" do
    model = DummyModel.new
    model.write_attribute(:categories, "invalid-json")

    assert_equal [], model.categories
  end
end
