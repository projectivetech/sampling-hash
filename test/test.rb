require 'minitest/autorun'
require 'minitest/spec'
require 'tempfile'
require 'sampling-hash'

describe 'SamplingHash' do
  describe 'hash' do
    it 'fails if not given a file' do
      assert_raises(ArgumentError) do
        SamplingHash.hash('not-existing', 123)
      end
    end

    it 'uses the file size as default seed' do
      h1 = SamplingHash.hash(__FILE__)
      h2 = SamplingHash.hash(__FILE__, File.size(__FILE__))
      assert_equal h1, h2
    end

    it 'calculates the correct xxhash for a small file' do
      h1 = XXhash.xxh32(File.read(__FILE__), 123)
      h2 = SamplingHash.hash(__FILE__, 123)
      assert_equal h1, h2
    end

    it 'is blazingly fast for large files' do
      Tempfile.open('sampling-hash') do |f|
        f.write '0' * 100000000 # 100 MB.
        SamplingHash.hash(f, 123)
      end
    end
  end

  describe 'Sampler' do
    it 'works' do
      s = SamplingHash::Sampler.new(1000000000, 1000, 0, 1000, 0.001)

      # Size is 1 billion, sample_size is 1000, 1000 samples minimum
      # equals 1 million minimum sampling size, of the remaining 999 million
      # we want 1 one-tenth of a percent, so 999000 (total sampling size)
      # in 1000 + (999000 / 1000) = 1999 samples.
      assert_equal s.size, 1999000
      assert_equal s.samples.size, 1999
    end
  end
end
