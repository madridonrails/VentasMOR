class ActiveSupport::BufferedLogger
  SEVERITY_NAMES = %w(DEBUG INFO WARN ERROR FATAL UNKNOWN)

  def add_with_context(severity, message=nil, progname=nil, &block)
    sname = SEVERITY_NAMES[severity]
    message = (message || (block && block.call) || progname).to_s
    message = "[#{Time.now.strftime('%Y/%m/%d %H:%M:%S')}] (pid:#{$$}) [#{sname}]: #{message}"
    add_without_context(severity, message, progname, &block)
  end
  alias_method_chain :add, :context
end
