require 'active_support/log_subscriber'

module ActionView
  # = Action View Log Subscriber
  #
  # Provides functionality so that Rails can output logs from Action View.
  class LogSubscriber < ActiveSupport::LogSubscriber
    VIEWS_PATTERN = /^app\/views\//

    def initialize
      @root = nil
      super
    end

    def render_template(event)
      return unless logger.info?
      message = "  Rendered #{from_rails_root(event.payload[:identifier])}"
      message << " within #{from_rails_root(event.payload[:layout])}" if event.payload[:layout]
      message << " (#{event.duration.round(1)}ms)"
      info(message)
    end
    alias :render_partial :render_template
    alias :render_collection :render_template

    def logger
      ActionView::Base.logger
    end

  protected

    EMPTY = ''
    def from_rails_root(string)
      string.sub(rails_root, EMPTY).sub!(VIEWS_PATTERN, EMPTY)
    end

    def rails_root
      @root ||= "#{Rails.root}/"
    end
  end
end

ActionView::LogSubscriber.attach_to :action_view
