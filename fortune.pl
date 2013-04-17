use strict;
use warnings;

weechat::register ("fortune", "shmibs", "0.1", "GPL", "set the topic to a fortune <= 140 chars (/fortune)", "", "");
weechat::hook_command("fortune", "", "", "", "", "settopic", "");

sub settopic{
	my $buffer=$_[1];
	my $tempstr='';
	while($tempstr eq '' || length($tempstr) > 140){
		$tempstr=`fortune`;
		$tempstr=~s/\n/ /g;
		$tempstr=~s/	//g;
	}
	my @tempar=split(//, $tempstr);
	
	my $output="";
	my $bool=1;
	my $i;
	for($i=0; $i<length($tempstr); $i++) {
		
		if($tempar[$i] eq '"') {
			if($bool) {
				$output.="\x{03}03\"";
				$bool=0;
			} else {
				$output.="\"\x{03}";
				$bool=1;
			}
		} else {
			if($i,length($tempstr)-1) {
				if($tempar[$i] eq '-' and $tempar[$i+1] eq '-') {
					$output.="\x{03}14";
				}
			}
			$output.=$tempar[$i];
		}
	}
	
	weechat::command($buffer, "/topic $output");
    return weechat::WEECHAT_RC_OK;
}
