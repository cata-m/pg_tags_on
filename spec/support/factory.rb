# frozen_string_literal: true

class Factory
  def self.array_strings
    Entity.insert_all([
                        { tags_str: %w[a b c], attr: 'test1' },
                        { tags_str: %w[b c],   attr: 'test2' },
                        { tags_str: ['d'],     attr: 'test3' }
                      ])
  end

  def self.array_integers
    Entity.insert_all([
                        { tags_int: [1, 2, 3], attr: 'test1' },
                        { tags_int: [2, 3],    attr: 'test2' },
                        { tags_int: [4],       attr: 'test3' }
                      ])
  end

  def self.array_jsonb
    Entity.insert_all([
                        { tags_jsonb: [{ name: 'a' },
                                       { name: 'b' },
                                       { name: 'c' }],
                          attr: 'test1' },
                        { tags_jsonb: [{ name: 'b' },
                                       { name: 'c' }],
                          attr: 'test2' },
                        { tags_jsonb: [{ name: 'd' }],
                          attr: 'test3' }
                      ])
  end

  def self.array_jsonb_with_attrs
    Entity.insert_all([
                        { tags_jsonb: [{ name: 'a', meta: 'a' },
                                       { name: 'b', meta: 'b' },
                                       { name: 'c', meta: 'c' }],
                          attr: 'test1' },
                        { tags_jsonb: [{ name: 'b', meta: 'b' },
                                       { name: 'c', meta: 'c' }],
                          attr: 'test2' },
                        { tags_jsonb: [{ name: 'd', meta: 'd' }],
                          attr: 'test3' }
                      ])
  end
end
