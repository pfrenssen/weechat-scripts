weechat::register ("banshee-np", "shmibs", "0.3", "GPL", "banshee-weechat current song script (usage: /np)", "", "");
weechat::hook_command("np", "", "", "", "", "banshee", "");

use Encode;

sub banshee {
    my ($data, $buffer, $args) = @_;
    my @colours = (13,11,9,4);
    my ($name, $title, $album);
#	9 green
#	4 red
#	6 pink
#	13 pink
#	11 blue
#	7 yellow
    if(qx/ps -A | grep banshee/ ne ""){
		chomp(($name, $title, $album) = (decode_utf8(substr(`banshee --query-title`,7)), decode_utf8(substr(`banshee --query-artist`,8)), decode_utf8(substr(`banshee --query-album`,7))));
	} else {
		($name, $title, $album) = "";
	}
    
    if($name ne ""){
		weechat::command($buffer, "/me is hearing: \N{U+266B} \x{03}$colours[1]$name\x{0f} by \x{03}$colours[2]$title\x{0f} from \x{03}$colours[3]$album\x{0f} \N{U+266B}");
	} else {
		weechat::command($buffer, "/me has nothing in his ears )=");
	}
    return weechat::WEECHAT_RC_OK;
}
