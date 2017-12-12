require 'open3'
include Open3
Puppet::Type.type(:assert).provide(:ruby) do
  desc "The assert implementation."

  def exists?
    if resource[:path]
      File.exist? resource[:path]

    elsif resource[:file]
      File.file? resource[:file]

    elsif resource[:directory]
      File.directory? resource[:directory]

    elsif resource[:command]

      withenv = Puppet::Util.method(:withenv) if Puppet::Util.respond_to?(:withenv)
      withenv = Puppet::Util::Execution.method(:withenv) if Puppet::Util::Execution.respond_to?(:withenv)
      withenv.call({'PATH' => ''}) do
        _, stdout, stderr, thread = popen3(resource[:command])
        @stdout = stdout.read
        @stderr = stderr.read
        thread.value.success?
      end

    else
      # must be last, because we cannot validate false/undef conditions
      resource[:condition]
    end
  end

  def assert_message
    value = resource[:message] || resource[:name]
    "Assert Failed: #{value}, #{@stderr}, #{@stdout}"
  end

  def create
    raise Puppet::Error, assert_message
  end

  def destroy
    raise Puppet::Error, assert_message
  end

end
