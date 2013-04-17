use strict;
use warnings;
use utf8;

weechat::register ("wat", "shmibs", "0.3", "GPL", "replace words at random ( usage: enable/disable with /wat <on|off> )", "", "");
weechat::hook_command("wat", "", "", "", "", "toggle", "");
weechat::hook_modifier("input_text_content", "catch_word", "");
weechat::hook_modifier("input_text_for_buffer", "catch_send", "");

my @replacements = (
	'fairy',
	'pony',
	'accidentally',
	'broken',
	'attractive',
	'portable',
	'salivating',
	'wipe',
	'boring',
	'garish',
	'flamboyant',
	'putrid'
);

my $state="off";

sub toggle {
	my $output="";
	my $buffer=$_[1];
	if($_[2] eq "on") {
		$state="on";
	}
	if($_[2] eq "off") {
		$state="off";
	}
    return weechat::WEECHAT_RC_OK;
}

# catch words as they are typed
sub catch_word {
	my ($data, $modifier_name, $buffer, $rval) = @_;

	if($rval) {
		if( $state eq "on" && substr($rval, 0, 1) ne "/" ) {
			if(length($rval) > 1) {
				if( substr($rval, length($rval)-1, 1) eq " " && substr($rval, length($rval)-2, 1) ne " " ) {
					$rval=mutate($rval);
					$rval.=" ";
					my $length=length($rval);
					weechat::buffer_set($buffer, 'input', "$rval");
					weechat::buffer_set($buffer, 'input_pos', "$length");
				}
			}
		}
	}

	return $rval;
}

# check the last word before sending
sub catch_send {
	my ($data, $modifier_name, $buffer, $rval) = @_;
	
	if( $state eq "on" && substr($rval, 0, 1) ne "/" ) {
		$rval=mutate($rval);
	}

	return $rval;
}

# apply modifications to the last word of the input string
sub mutate {
	my @words=split(/ |\t|\n/, $_[0]);

	if($words[$#words]) {
		# apply desired transformations to the most
		# recently typed word here
		if( !int(rand(20)) ) {
			$words[$#words]=$replacements[int(rand(@replacements))];
		}
	}

	my $rval=join(' ', @words);
	return $rval;
}
