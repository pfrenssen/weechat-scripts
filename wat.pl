use strict;
use warnings;
use utf8;
use List::Util 'shuffle';

weechat::register ("wat", "shmibs", "0.3", "GPL", "intentionally obfuscate speach ( usage: enable/disable with /wat <on|off> )", "", "");
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
	'willingly', 'excited', 'glorious', 'torpor', 'light',
	'gracious', 'cretan', 'variantly', 'stammers', 'knifed',
	'slashed', 'occupational', 'dissipated', 'Singapore',
	'afterglow', 'toes', 'whorls', 'sneakiness', 'dodgers',
	'Johannesburg', 'inextricable', 'slaughterhouse',
	'prophecy', 'lobster', 'contraption', 'hook', 'zoos',
	'beafy', 'impersonated', 'telescope', 'countess',
	'marsupial', 'boots', 'guided', 'titillating', 'bonds',
	'bequeathing', 'delineation', 'associators', 'ballpark',
	'stultify', 'ionise', 'expanders', 'cybernetics',
	'alluring', 'medicinal', 'bloom'
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

		# maintain the position of punctuation
		if( $words[$#words]=~/[.,'"\?!:;\[\]\(\)]/ ) {
			$punctuation=substr($words[$#words], length($words[$#words])-1, 1);
			$words[$#words]=substr($words[$#words], 0, length($words[$#words])-1);
		}
		
		# grab a random replacement word from the list
		if( !int(rand(20)) ) {
			$words[$#words]=$replacements[int(rand(@replacements))];
		}
	
		# swap two words at random
		if( !int(rand(15)) ) {
			my $i=int(rand(@words));
			my $j=int(rand(@words));
	        @words[$i,$j]=@words[$j,$i];
		}
		
		# induce typos
		if( !int(rand(10)) ) {
			my @chars=split(//, $words[$#words]);
			my $i=int(rand(@chars));
			my $j=int(rand(@chars));
	        @chars[$i,$j]=@chars[$j,$i];
			$words[$#words]=join('', @chars);
		}
		
		# maintain the position of punctuation, part
		# two
		if($punctuation) {
			$words[$#words].=$punctuation;
		}

	}
	
	my $rval=join(' ', @words);
	return $rval;
}
