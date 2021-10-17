
#Metasploit
require 'msf/core'

class MetasploitModule < Msf::Auxiliary
  include Msf::Exploit::Remote::Tcp
  include Msf::Auxlliary::Scanner
  
  def initialize
    super(
      'Name'          => 'My custom TCP scan' ，
      'Version'       => '$Revision : 1 $',
      'Description'   => 'My quick scanner',
      'Author'        => 'Your name here' ，
      'License'       => MSF_ LICENSE
    )

    # 如果 RHOSTS 设置为 范围，将会由 Auxiliary.rb 如下 语句 迭代
    # ar = Rex::Socket::RangeWalker.new(datastore['RHOSTS'])
    # host = ar.next_host
    register_options(      # 继承了Auxiliary::Scanner 的 Opt::RHOSTS
      [                    # 和 THREADS，所以，msfconsole 才会有 ← ↑
        Opt::RPORT(12345)  # 设置 扫描 的 默认端口
      ], self.class        # 为 类 注册 几个 选项
    )
  end


  def run_host(ip)
    # 根据 include 知道 需要看 lib/msf/core/exploit/remote/tcp.rb
    connect()      
    sock.puts('HELLO SERVER')          # sock.puts 的 出处 没找到
    data = sock.recv(1024)             
    print_status("Received: #{data} from #{ip}")
    disconnect()                                  # 同看 tcp.rb
  end
  
end
