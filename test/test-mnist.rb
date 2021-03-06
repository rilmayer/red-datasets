class MNISTTest < Test::Unit::TestCase
  include Helper::Sandbox

  sub_test_case("MNIST Normal") do
    def setup_data
      setup_sandbox

      def @dataset.cache_dir_path
        @cache_dir_path
      end

      def @dataset.cache_dir_path=(path)
        @cache_dir_path = path
      end
      @dataset.cache_dir_path = @tmp_dir

      def @dataset.download(output_path, url)
        image_magic_number = 2051
        label_magic_number = 2049
        n_image, image_size_x, image_size_y, label = 10, 28, 28, 1

        Zlib::GzipWriter.open(output_path) do |gz|
          if output_path.basename.to_s.include?("-images-")
            image_data = ([image_magic_number, n_image]).pack('N2') +
                         ([image_size_x,image_size_y]).pack('N2') +
                         ([0] * image_size_x * image_size_y).pack("C*") * n_image
            gz.puts(image_data)
          else
            label_data = ([label_magic_number, n_image]).pack('N2') +
                         ([label] * n_image).pack("C*")
            gz.puts(label_data)
          end
        end
      end
    end

    def teardown
      teardown_sandbox
    end

    sub_test_case("train") do
      def setup
        @dataset = Datasets::MNIST.new(type: :train)
        setup_data()
      end

      test("#each") do
        raw_dataset = @dataset.collect do |record|
          {
            :label => record.label,
            :pixels => record.pixels
          }
        end

        assert_equal([
                       {
                         :label => 1,
                         :pixels => [0] * 28 * 28
                       }
                     ] * 10,
                     raw_dataset)
      end

      test("#to_table") do
        table_data = @dataset.to_table
        assert_equal([[0] * 28 * 28] * 10,
                     table_data[:pixels])
      end
    end

    sub_test_case("test") do
      def setup
        @dataset = Datasets::MNIST.new(type: :test)
        setup_data()
      end

      test("#each") do
        raw_dataset = @dataset.collect do |record|
          {
            :label => record.label,
            :pixels => record.pixels
          }
        end

        assert_equal([
                       {
                         :label => 1,
                         :pixels => [0] * 28 * 28
                       }
                     ] * 10,
                     raw_dataset)
      end

      test("#to_table") do
        table_data = @dataset.to_table
        assert_equal([[0] * 28 * 28] * 10,
                     table_data[:pixels])
      end
    end
  end

  sub_test_case("MNIST Abnormal") do
    test("SetTypeError") do
      other_type = :other
      e = assert_raises(SetTypeError) do
        Datasets::MNIST.new(type: other_type)
      end
      error_message = "Please set type :train or :test: #{other_type.inspect}"
      assert_equal(error_message, e.message)
    end
  end
end
