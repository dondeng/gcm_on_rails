require 'configatron'
require 'uri'

module Gcm
  module Errors

    # Missing registration_id.
    class MissingRegistration < StandardError
      def initialize(message) # :nodoc:
        super("Missing registration_id: '#{message}'")
      end
    end

    # Invalid registration_id. Check the formatting of the registration ID that is passed to the server. Make sure
    # it matches the the registration ID the phone receives in the com.google.android.c2dm.intent.REGISTRATION intent
    # and that it is not being truncated or additional characters being appended
    class InvalidRegistration < StandardError
      def initialize(message) # :nodoc:
        super("Invalid registration_id: '#{message}'")
      end
    end

    # A registration ID is tied to a certain group of senders. When an application registers  for GCM usage, it must
    # specify which senders are allowed to send messages.
    class MismatchSenderId < StandardError
      def initialize(message) # :nodoc
        super("Mismatched Sender Id: '#{message}'")
      end
    end

    # From Google:-
    # An existing registration ID may cease to be valid in a number of scenarios, including:
    #   - If the application manually unregisters
    #   - If the application is automatically unregistered which can (but not guaranteed) to happen if the user
    #     uninstalls the application
    #   - If the registration ID expires. Google might decide to refresh registration IDs
    #
    # For all cases above, it is recommended that this registration ID is removed from the 3rd party server
    class NotRegistered < StandardError
      def initialize(message) # :nodoc
        super("The registration_id is no longer valid: '#{message}'")
      end
    end

    # The payload of the message is too big, the limit is currently 4096
    # bytes. Reduce the size of the message.
    class MessageTooBig < StandardError
      def initialize(message) # :nodoc:
        super("The maximum size allowed for a notification payload is 4096 bytes: '#{message}'")
      end
    end

    # ClientLogin AUTH_TOKEN is invalid. Check the config
    class InvalidAuthToken < StandardError
      def initialize(message)
        super("Invalid auth token: '#{message}'")
      end
    end

    # Indicates that server is temporarily unavailable (i.e because of timeouts, etc.)
    # Sender must retry later, honoring any Retry-After header included in the response.
    # Application servers must implement exponential back-off
    class ServiceUnavailable < StandardError
      def initialize(message)
        super("Service is currently unavailable. Try again later: '#{message}'")
      end
    end

    # Indicates an internal server error with the GCM server
    class InternalServerError < StandardError
      def initialize(message)
        super("The was an internal error in the GCM server while trying to process the request: '#{message}'")
      end
    end
  end

  Dir.glob(File.join(File.dirname(__FILE__), 'app', 'models', 'gcm', '*.rb')).sort.each do |f|
    require f
  end

  %w{ models controllers helpers }.each do |dir|
    path = File.join(File.dirname(__FILE__), 'app', dir)
    $LOAD_PATH << path
    # puts "Adding #{path}"
    ActiveSupport::Dependencies.autoload_paths << path
    ActiveSupport::Dependencies.autoload_once_paths.delete(path)
  end
end