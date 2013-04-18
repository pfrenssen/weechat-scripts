use strict;
use warnings;
use utf8;
use List::Util 'shuffle';

weechat::register ("wat", "shmibs", "0.3", "GPL", "replace words at random ( usage: enable/disable with /wat <on|off> )", "", "");
weechat::hook_command("wat", "", "", "", "", "toggle", "");
weechat::hook_modifier("input_text_content", "catch_word", "");
weechat::hook_modifier("input_text_for_buffer", "catch_send", "");

my @replacements = (
	'fairy', 'pony', 'accidentally', 'broken', 'attractive',
	'portable', 'salivating', 'wipe', 'boring', 'garish',
	'flamboyant', 'putrid', 'pustule', 'cardigan', 'waldo',
	'foreign', 'dumpling', 'phalanges', 'goose', 'didactic',
	'vroom', 'zygote', 'tractor', 'blatant', 'authoritatively',
	'feral', 'dung', 'scones', 'busted', 'tortoise',
	'willingly', 'excited', 'glorious'
);

my $state="off";
my $length=0;

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
			if(length($rval) > $length) {
				$length=length($rval);
				if($length > 1) {
					if( substr($rval, $length-1, 1) eq " " && substr($rval, $length-2, 1) ne " " ) {
						$rval=mutate($rval);
						$rval.=" ";
						$length=length($rval);
						
						weechat::buffer_set($buffer, 'input', "$rval");
						weechat::buffer_set($buffer, 'input_pos', "$length");
					}
				}
			} else {
				$length=length($rval);
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
	my $punctuation=0;

	if($words[$#words]) {
		if( $words[$#words]=~/.|,|'|"|\?|!|:|;|[|]|(|)/ ) {
			$punctuation=substr($words[$#words], length($words[$#words])-1, 1);
			$words[$#words]=substr($words[$#words], 0, length($words[$#words])-1);
		}
		
		# apply desired transformations to the most
		# recently typed word here
		if( !int(rand(20)) ) {
			$words[$#words]=$replacements[int(rand(@replacements))];
		}
	}
	
	# shuffle all words in sentence
	if( !int(rand(20)) ) {
		@words=shuffle(@words);
	}
	
	# shuffle a single word
	if( !int(rand(15)) ) {
		my @chars=split(//, $words[$#words]);
		@chars=shuffle(@chars);
		$words[$#words]=join('', @chars);
	}
	
	if($punctuation) {
		$words[$#words].=$punctuation;
	}
	
	my $rval=join(' ', @words);
	return $rval;
}
