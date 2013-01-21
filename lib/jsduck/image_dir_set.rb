require "jsduck/image_dir"
require "jsduck/logger"
require "fileutils"

module JsDuck

  # Looks up images from directories specified through --images option.
  class ImageDirSet
    def initialize(full_paths, relative_path)
      @dirs = full_paths.map {|path| ImageDir.new(path, relative_path) }
    end

    def get(filename)
      @dirs.each do |dir|
        if img = dir.get(filename)
          return img
        end
      end
      return nil
    end

    def all_used
      @dirs.map {|dir| dir.all_used }.flatten
    end

    def all_unused
      @dirs.map {|dir| dir.all_unused }.flatten
    end

    # Copys over images to given output dir
    def copy(output_dir)
      all_used.each {|img| copy_img(img, output_dir) }
      all_unused.each {|img| report_unused(img) }
    end

    private

    # Copy a single image
    def copy_img(img, output_dir)
      dest = File.join(output_dir, img[:filename])
      Logger.log("Copying image", dest)
      FileUtils.makedirs(File.dirname(dest))
      FileUtils.cp(img[:full_path], dest)
    end

    def report_unused(img)
      Logger.warn(:image_unused, "Image not used.", img[:full_path])
    end

  end

end