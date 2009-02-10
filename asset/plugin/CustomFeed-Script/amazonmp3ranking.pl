#!/usr/bin/perl

use strict;
use Web::Scraper;
use URI;
use YAML::Syck;
use utf8;
use Encode;

my $uri = URI->new('http://www.amazon.com/gp/bestsellers/dmusic/digital-music-track/ref=pd_ts_dmusic_nav');


my $scraper = scraper {
	process '//div[2]//div//td[3]', 'lists[]' => scraper { 
		process '//strong/a',
			 'artist' => 'TEXT';
		process '//a[last()-1]',
			 'title' => 'TEXT';
		}
};
my $res = $scraper->scrape($uri);
my $feed = {
	title => 'amazonmp3',
	link => $uri->as_string,
	type => 'amazon',
};

for my $entry (@{ $res->{lists} }){
	push @{$feed->{entries}},{
		title => $entry->{artist},
		body  => $entry->{title},
};
}
use YAML;
binmode STDOUT, ":utf8";
print Dump $feed;






__END__

