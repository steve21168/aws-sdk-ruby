module AwsSdkCodeGenerator
  class Service

    # @param [Hash] options
    # @option options [required, String] :version Gem version, e.g. "1.0.0".
    # @option options [required, String] :name The service name, e.g. "S3"
    # @option options [required, Hash, String] :api
    # @option options [Hash, String] :docs
    # @option options [Hash, String] :paginators
    # @option options [Hash, String] :waiters
    # @option options [Hash, String] :resources
    # @option options [Hash, String] :examples
    # @option options [Hash<gem,version>] :gem_dependencies ({})
    # @option options [Hash] :add_plugins ({})
    # @option options [Hash] :remove_plugins ([])
    def initialize(options)
      @version = options.fetch(:version)
      @name = options.fetch(:name)
      @api = load_json(options.fetch(:api))
      ApplyDocs.new(@api).apply(load_json(options[:docs]))
      @paginators = load_json(options[:paginators])
      @waiters = load_json(options[:waiters])
      @resources = load_json(options[:resources])
      @examples = load_json(options[:examples])
      @gem_dependencies = options.fetch(:gem_dependencies, {})
      @gem_dependencies['aws-sdk-core'] ||= '~> 3.0'
      @add_plugins = options.fetch(:add_plugins, {})
      @remove_plugins = options.fetch(:remove_plugins, [])

      # computed attributes
      @identifier = name.downcase
      @module_name = "Aws::#{name}"
      @gem_name = "aws-sdk-#{identifier}"
      @protocol = api.fetch('metadata').fetch('protocol')
      @api_version = api.fetch('metadata').fetch('apiVersion')
      @signature_version = api.fetch('metadata').fetch('signatureVersion')
      @full_name = api.fetch('metadata').fetch('serviceFullName')
      @short_name = api.fetch('metadata').fetch('serviceAbbreviation', @full_name)
    end

    # @return [String]
    attr_reader :version

    # @return [String] The service name, e.g. "S3"
    attr_reader :name

    # @return [String] The service module, e.g. "Aws::S3"
    attr_reader :module_name

    # @return [Hash] The service API model.
    attr_reader :api

    # @return [Hash, nil] The service paginators model.
    attr_reader :paginators

    # @return [Hash, nil] The service waiters model.
    attr_reader :waiters

    # @return [Hash, nil] The service resource model.
    attr_reader :resources

    # @return [Hash, nil] The service shared examples model.
    attr_reader :examples

    # @return [Hash<String,String>] A hash of gem dependencies. Hash keys
    #   are gem names, values are versions.
    attr_reader :gem_dependencies

    # @return [Hash<String,String>] A hash of plugins to add.
    attr_reader :add_plugins

    # @return [Array<String>] A list of default plugins to remove.
    attr_reader :remove_plugins

    # @return [String] The service identifier, e.g. "s3"
    attr_reader :identifier

    # @return [String] The gem name, e.g. "aws-sdk-s3"
    attr_reader :gem_name

    # @return [String] The service protocol, e.g. "json", "query", etc.
    attr_reader :protocol

    # @return [String] The service API version, e.g. "YYYY-MM-DD".
    attr_reader :api_version

    # @return [String] The signature version, e.g. "v4"
    attr_reader :signature_version

    # @return [String] The full product name for the service,
    #   e.g. "Amazon Simple Storage Service".
    attr_reader :full_name

    # @return [String] The short product name for the service, e.g. "Amazon S3".
    attr_reader :short_name

    # @api private
    def inspect
      "#<#{self.class.name}>"
    end

    private

    def load_json(value)
      case value
      when nil then nil
      when Hash then value
      when String
        File.open(value, 'rb') do |file|
          JSON.load(file.read)
        end
      else
        "expected String, Hash, or nil, got `#{value.class}'"
        raise ArgumentError, msg
      end
    end

  end
end
