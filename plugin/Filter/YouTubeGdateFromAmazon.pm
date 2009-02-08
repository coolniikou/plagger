package Plagger::Plugin::Filter::YouTubeGdateFromAmazon;

use strict;
use base qw( Plagger::Plugin );
use Encode;
use HTML::Entities;
use utf8;
use URI::Escape;
use XML::Atom::Feed;
use URI;

sub register {
    my($self, $context) = @_;
    $context->register_hook(
        $self,
        'update.entry.fixup' => \&filter,
    );
}

sub filter {
    my($self, $context, $args) = @_;
    my $e = $args->{entry};
		my ($keywords, $title, $artist ,$video_id);

		$title = $e->title;
		$title = encode('UTF-8',$title);
		$artist = $e->body;
		$artist = encode('UTF-8',$artist);
		#Amazonmp3
		$artist =~ s/<[^>]*>//g;
		$artist = decode('UTF-8',$artist);
		$title = decode('UTF-8',$title);
		$keywords = $artist . "+" . $title;

		$video_id = search_youtube($self,$context,$keywords);
		unless($video_id eq ''){
				$e->title( $title . " by " . $artist );
				$e->tags($artist);
		}
#else{
#				$video_id = search_youtube($self,$context,$artist);
#				$e->title($artist);
#		}
		
		unless($video_id eq ''){
				$e->link("http://www.youtube.com/watch?v=$video_id");
				$e->body(embed($video_id));
				$e->summary($title);
				$e->tags($artist);
				$e->rate($artist);
		}
}

sub embed{
		my ($video_id) = @_;
		my $html = '<object width="425" height="350"><param name="movie" value="http://www.youtube.com/v/%s"></param><param name="wmode" value="transparent"></param><embed src="http://www.youtube.com/v/%s" type="application/x-shockwave-flash" wmode="transparent" width="425" height="350"></embed></object>';
		$html = sprintf($html, $video_id, $video_id);
		return $html;
}

sub search_youtube{
        my ($self,$context,$query) = @_;
        my $url = "http://gdata.youtube.com/feeds/api/videos?vq=" .
           URI::Escape::uri_escape_utf8($query);
        my $feed = XML::Atom::Feed->new(URI->new($url));

           $query = encode('UTF-8', $query) unless $context->conf->{no_decode_utf8};
#   $query =~s/([^\w\/\.\?:=&#])/sprintf("%%%02X", unpack("C", $1))/eg;
           $query =~ tr/\'/+/;
           $query =~ tr/ /+/;
           $context->log( info => 'Getting YouTube search results for ' . $query );

        my @entries = $feed->entries;
	my $video_id;
	if(exists $entries[0]){
        foreach my $link ( $entries[0]->link ) {
            my $href = $link->href;
            if($href =~ m!www.youtube.com/watch\?v=(.*)$!){
                $video_id = $1;
                $context->log(info => "$video_id get!");
                 }
              }
        	return $video_id;
	}else{
	return;
	}
}
1;
