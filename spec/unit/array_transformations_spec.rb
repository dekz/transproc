require 'spec_helper'

describe Transproc::ArrayTransformations do
  describe '.extract_key' do
    it 'extracts values by key from all hashes' do
      extract_key = t(:extract_key, 'name')

      original = [
        { 'name' => 'Alice', 'role' => 'sender' },
        { 'name' => 'Bob', 'role' => 'receiver' },
        { 'role' => 'listener' }
      ]

      input = original

      output = ['Alice', 'Bob', nil]

      expect(extract_key[input]).to eql(output)
      expect(input).to eql(original)
    end
  end

  describe '.extract_key!' do
    it 'extracts values by key from all hashes' do
      extract_key = t(:extract_key!, 'name')

      input = [
        { 'name' => 'Alice', 'role' => 'sender' },
        { 'name' => 'Bob', 'role' => 'receiver' },
        { 'role' => 'listener' }
      ]

      output = ['Alice', 'Bob', nil]

      expect(extract_key[input]).to eql(output)
      expect(input).to eql(output)
    end
  end

  describe '.insert_key' do
    it 'wraps values to tuples with given key' do
      insert_key = t(:insert_key, 'name')

      original = ['Alice', 'Bob', nil]

      input = original

      output = [
        { 'name' => 'Alice' },
        { 'name' => 'Bob' },
        { 'name' => nil }
      ]

      expect(insert_key[input]).to eql(output)
      expect(input).to eql(original)
    end
  end

  describe '.insert_key!' do
    it 'wraps values to tuples with given key' do
      insert_key = t(:insert_key!, 'name')

      original = ['Alice', 'Bob', nil]

      input = original

      output = [
        { 'name' => 'Alice' },
        { 'name' => 'Bob' },
        { 'name' => nil }
      ]

      expect(insert_key[input]).to eql(output)
      expect(input).to eql(output)
    end
  end

  describe '.add_keys' do
    it 'returns a new array with missed keys added to tuples' do
      add_keys = t(:add_keys, [:foo, :bar, :baz])

      original = [{ foo: 'bar' }, { bar: 'baz' }]

      input = original

      output = [
        { foo: 'bar', bar: nil, baz: nil },
        { foo: nil, bar: 'baz', baz: nil }
      ]

      expect(add_keys[input]).to eql(output)
      expect(input).to eql(original)
    end
  end

  describe '.add_keys!' do
    it 'adds missed keys to tuples' do
      add_keys = t(:add_keys!, [:foo, :bar, :baz])

      original = [{ foo: 'bar' }, { bar: 'baz' }]

      input = original

      output = [
        { foo: 'bar', bar: nil, baz: nil },
        { foo: nil, bar: 'baz', baz: nil }
      ]

      expect(add_keys[input]).to eql(output)
      expect(input).to eql(output)
    end
  end

  describe '.map_array' do
    it 'applies funtions to all values' do
      map = t(:map_array, t(:symbolize_keys))

      original = [
        { 'name' => 'Jane', 'title' => 'One' },
        { 'name' => 'Jane', 'title' => 'Two' }
      ]

      input = original

      output = [
        { name: 'Jane', title: 'One' },
        { name: 'Jane', title: 'Two' }
      ]

      expect(map[input]).to eql(output)
      expect(input).to eql(original)
    end
  end

  describe '.map_array!' do
    it 'updates array with the result of the function applied to each value' do
      map = t(:map_array!, t(:symbolize_keys))

      input = [
        { 'name' => 'Jane', 'title' => 'One' },
        { 'name' => 'Jane', 'title' => 'Two' }
      ]

      output = [
        { name: 'Jane', title: 'One' },
        { name: 'Jane', title: 'Two' }
      ]

      map[input]

      expect(input).to eql(output)
    end
  end

  describe '.wrap' do
    it 'returns a new array with wrapped hashes' do
      wrap = t(:wrap, :task, [:title])

      input = [{ name: 'Jane', title: 'One' }]
      output = [{ name: 'Jane', task: { title: 'One' } }]

      expect(wrap[input]).to eql(output)
    end

    it 'returns a array new with deeply wrapped hashes' do
      wrap =
        t(
          :map_array,
          t(:nest, :user, [:name, :title]) +
          t(:map_value, :user, t(:nest, :task, [:title]))
        )

      input = [{ name: 'Jane', title: 'One' }]
      output = [{ user: { name: 'Jane', task: { title: 'One' } } }]

      expect(wrap[input]).to eql(output)
    end
  end

  describe '.group' do
    it 'returns a new array with grouped hashes' do
      group = t(:group, :tasks, [:title])

      input = [{ name: 'Jane', title: 'One' }, { name: 'Jane', title: 'Two' }]
      output = [{ name: 'Jane', tasks: [{ title: 'One' }, { title: 'Two' }] }]

      expect(group[input]).to eql(output)
    end
  end

  describe '.ungroup' do
    subject(:ungroup) { t(:ungroup, :tasks, [:title]) }

    it 'returns a new array with ungrouped hashes' do
      input = [{ name: 'Jane', tasks: [{ title: 'One' }, { title: 'Two' }] }]
      output = [{ name: 'Jane', title: 'One' }, { name: 'Jane', title: 'Two' }]

      expect(ungroup[input]).to eql(output)
    end

    it 'returns an input with empty array removed' do
      input = [{ name: 'Jane', tasks: [] }]
      output = [{ name: 'Jane' }]

      expect(ungroup[input]).to eql(output)
    end

    it 'returns an input when a key is absent' do
      input = [{ name: 'Jane' }]
      output = [{ name: 'Jane' }]

      expect(ungroup[input]).to eql(output)
    end
  end

  describe '.combine' do
    let(:input) do
      [
        # parent users
        [
          { name: 'Jane', email: 'jane@doe.org' },
          { name: 'Joe', email: 'joe@doe.org' }
        ],
        [
          [
            # user tasks
            [
              { user: 'Jane', title: 'One' },
              { user: 'Jane', title: 'Two' },
              { user: 'Joe', title: 'Three' }
            ],
            [
              # task tags
              [
                { task: 'One', tag: 'red' },
                { task: 'Three', tag: 'blue' }
              ]
            ]
          ]
        ]
      ]
    end

    let(:output) do
      [
        { name: 'Jane', email: 'jane@doe.org', tasks: [
          { user: 'Jane', title: 'One', tags: [{ task: 'One', tag: 'red' }] },
          { user: 'Jane', title: 'Two', tags: [] }]
        },
        { name: 'Joe', email: 'joe@doe.org', tasks: [
          { user: 'Joe', title: 'Three', tags: [{ task: 'Three', tag: 'blue' }] }]
        }
      ]
    end

    it 'merges hashes from arrays using provided join keys' do
      combine = t(:combine, [
        [:tasks, { name: :user }, [[:tags, title: :task]]]
      ])

      expect(combine[input]).to eql(output)
    end
  end
end
