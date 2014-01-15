require_relative 'logging'

# Some crazy code to load modules from a specific directory structure.
module EVD::PluginLoader
  include EVD::Logging

  MODULE_NAME = 'evd'

  def self.list_modules(module_category, blacklist, &block)
    $:.each do |path|
      dir = File.join(path, MODULE_NAME, module_category)

      next unless File.directory? dir

      Dir.foreach(dir) do |entity|
        next if entity.start_with? "."
        next unless entity.end_with? ".rb"
        next unless File.file? File.join(dir, entity)

        base = entity.slice(0, entity.size - 3)

        if blacklist.include? base
          log.warning "Ignoring blacklisted module: #{base}"
          next
        end

        yield [MODULE_NAME, module_category, base].join('/')
      end
    end
  end

  def self.load module_category, blacklist
    self.list_modules(module_category, blacklist) do |m|
      require m
    end
  end
end
