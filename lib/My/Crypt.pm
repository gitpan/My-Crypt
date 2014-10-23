package My::Crypt;
use strict;
############################################################
# Author  :  Reto.Hersiczky@infocopter.com
# Created :  07FEB2002
#
# Licencing:
# http://www.infocopter.com/perl/licencing-print.htm
#
# Usage:
# ----------------------------------------------------------
#	use My::Crypt;
#
#	$crypt = My::Crypt->new( debug => 0 );
#	$enc   = $crypt->encrypt('myguess', 'secret');
#
#	print "encrypted = '$enc'\n";
#
#	$dec = $crypt->decrypt($enc, 'secret');
#
#	print "'$enc' is decrypted: '$dec'\n";
# ----------------------------------------------------------
# http://www.infocopter.com/perl/modules/my-crypt.htm
############################################################

my $package = __PACKAGE__;
require MIME::Base64;

our $VERSION = '0.82.02';

# GLOBAL VARIABLES
my $contentType = "";
my $priv = ""; # challenge key
my $debug = 0;

#-----  FORWARD DECLARATIONS & PROTOTYPING
sub iso2hex($);
sub hex2iso($);
sub Error($);
sub Debug($);

sub new {
	my $type = shift;
	my %params = @_;
	my $self = {};

	$params{'encoding'} ||= 'base64'; # base64 || hex8
	$params{'debug'   } ||= 0;

	$self->{'debug'   } = $debug = $params{'debug'};
	$self->{'encoding'} = $params{'encoding'};

	$debug = $params{'debug'};

	bless $self, $type;
}

sub encrypt {
	my $self = shift;

	my $text = shift;
	   $priv = shift;
	
	# Make sure to encrypt similar or equal text to different strings
	my $scramble_left  = sprintf("%04d", substr(1048576 * rand(), 0, 4));
	my $scramble_right = sprintf("%04d", substr(1048576 * rand(), 0, 4));

	my $text_scrambled = "$scramble_left\t$text\t$priv\t$scramble_right";

	my $bin_text = &atob($text_scrambled);
	my $bin_priv = &atob($priv);

	Debug "N1000: Scrambling '$text' with '$priv'...";
	
	#####  Make test
	# my $check1 = '1010';
	# my $check2 = '0111';
	# my $check = &bin_add($check1, $check2);
	# Debug "BEGIN TEST"; Debug $check1; Debug $check2; Debug $check; Debug "END TEST";
	
	my $encryp = &bin_add($bin_text, $bin_priv);
	
	if ($self->{'debug'}) {
		Debug "$bin_text \t<- text";
		Debug "$bin_priv \t<- challenge";
		Debug "$encryp \t<- result";
	}
	
	my $encryp_pack = "";

	for (my $i = 0; $i < length($encryp); $i += 8) {
		my $elem = substr($encryp, $i, 8);
		# X my $elemp =  pack('C', $elem); # cannot be used on RH8.0
		$encryp_pack .= pack('B8', $elem);
	}

	Debug "N1003: encryp_pack -----> '$encryp_pack'\n";

	my $encrypted = '';

	if ($self->{'encoding'} eq 'hex8') {
		$encrypted = iso2hex $encryp_pack;
	}
	else {
		# base64
		$encrypted = MIME::Base64::encode($encryp_pack);
		chomp $encrypted;
	}

	$encrypted;
}

sub decrypt {
	my $self = shift;

	my $encryp_base64 = shift;
	   $priv = shift;
	   
	Debug 'N1002: Decrypting (' . $self->{'encoding'} . ") '$encryp_base64' with '$priv'...";
	
	my $bin_priv = &atob($priv);
	
	my $base64toplain = '';

	if ($self->{'encoding'} eq 'hex8') {
		$base64toplain = hex2iso $encryp_base64;
		Debug "hex8 -> '$encryp_base64' = '$base64toplain'" if $self->{'debug'};
	}
	else {
		$base64toplain = MIME::Base64::decode($encryp_base64);
	}

	Debug "N1004: -> base64toplain = '$base64toplain'...";

	my $encryp_pack = "";
	for (my $i = 0; $i < length($base64toplain); $i++) {
		my $elem = substr($base64toplain, $i, 1);
		my $bin  = unpack('B8', $elem);

		$encryp_pack .= $bin;
	}

	my $bin_new = &bin_add($encryp_pack, $bin_priv);

	$encryp_pack = "";
	for (my $i = 0; $i < length($bin_new); $i += 8) {
        	my $elem = substr($bin_new, $i, 8);
		print "'$elem' = ", pack('B8', $elem), "...\n" if $debug;
        	$encryp_pack .= pack('B8', $elem);
	}

	Debug "N1001: =====> '$encryp_pack' !!!";

	my ($rand1, $result, $priv_wrapped, $rand2) = split /\t/, $encryp_pack;
	return '' if $rand1 =~ /\D/;
	return '' if $rand2 =~ /\D/;
	return '' unless $priv eq $priv_wrapped;

	$result; # return middle element of array only
}

################################################
#	LOCAL SUB ROUTINES
################################################

sub atob ($) {
	my $str = shift;
	my $bin = "";
	for (my $i = 0; $i < length($str); $i++) { $bin .= unpack('B8', substr($str, $i, 1)); }
	$bin;
}

sub bin_add ($$) {
	my $a = shift;
	my $b = shift;

	my $i = my $j = 0;
	for ($j = 0; $j < length($a); $j++) {
		substr($a, $j, 1) += substr($b, $i, 1);
		substr($a, $j, 1) = 0 if substr($a, $j, 1) == 2;
		$i = 0 if ++$i > length($priv);
	}
	$a;
}

sub iso2hex ($) {
	my $string = $_[0];
	my $hex_string = '';

	for (my $i = 0; $i < length($string); $i++) {
		# print substr($string, $i, 1);
		$hex_string .= unpack('H8',  substr($string, $i, 1));
	}
	$hex_string;
}

sub hex2iso ($) {
	my $hex_string = $_[0];
	my $iso_string = '';

	for (my $i = 0; $i < length($hex_string); $i += 2) {
		my $char = substr(pack('H8',  substr($hex_string, $i, 2)), 0, 1); # 1 char
		$iso_string .= $char;
	}
	$iso_string;
}

sub Error ($) {
	print "Content-type: text/html\n\n" unless $contentType;
	print "<b>ERROR</b> ($package): $_[0]\n";
	exit(1);
}

sub Debug ($)  { return unless $debug; print "<b>[$package]</b> $_[0]<br>\n"; }

1;

####  Used Warning / Error Codes  ##########################
#	Next free W Code: 1000
#	Next free E Code: 1000
#	Next free N Code: 1005

__END__

=head1 NAME

My::Crypt - Perl extension for blah blah blah

=head1 SYNOPSIS

use My::Crypt;

$crypt = My::Crypt->new( debug => 0 );

[or] 

$crypt = My::Crypt->new( debug => 0, encoding => 'hex8' );

=head2 Encryption

$encrypted = $crypt->encrypt('plain text to encrypt', 'your_secret_string');

=head2 Decryption

$decrypted = $crypt->decrypt($encrypted, 'your_secret_string');

Returns an empty string if the encrypted hash has been broken

=head1 DESCRIPTION

Sometimes it's necessary to protect some certain data against plain reading or you intend to send information through the Internet. Another reason might be to assure users cannot modify their previously entered data in a follow-up step of a long Web transaction where you don't want to deal with server-side session data. The goal of My::Crypt was to have a pretty simple way to encrypt and decrypt data without the need to install and compile huge packages with lots of dependencies.

My::Crypt generates every time a different encrypted hash when you re-encrypt the same data with the same secret string. Nevertheless you are able to make double or tripple-encryption with any data to increase the security. Decryption works also on hashes that have been encrypted on a foreign host (try this with an unpatched IDEA installation ;-). 

=head2 EXPORT

None by default.



=head1 SEE ALSO

Please find a documentation and related news about this module on

http://www.infocopter.com/perl/modules/

There is currently no mailing list.

=head1 AUTHOR

Reto Hersiczky, E<lt>retoh@hatespam-infocopter.comE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2002-2005 by Reto Hersiczky

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.3 or,
at your option, any later version of Perl 5 you may have available.

Feel free to use it for commercial purposes or just for pleasure. You may change the code for your needs if you like. Redistribution and use in source and binary forms, with or without modification, are permitted. 

I ask you to leave the link to the related documentation anywhere at the the top of the module in case of redistribution my code.

=head2 SEE ALSO

http://www.infocopter.com/perl/licencing.html

=cut
