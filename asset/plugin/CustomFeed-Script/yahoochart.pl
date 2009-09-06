#!/usr/bin/perl

use strict;
use warnings;
use Web::Scraper;
use URI;
use YAML::Syck;
use utf8;
use Encode;
use WWW::Mechanize;

## scrap aritsts and title from yahoo video chart.


my $uri = 'http://new.music.yahoo.com/chart/?itemtype=video&gname=All+Categories&genreID=0&count=20&pageID=1';

my $mech = new WWW::Mechanize;
   $mech->get($uri);
my @links = $mech->find_all_links( url_regex => qr/pageID\=\d{1}$/) ;


my $s = scraper {
	process '//div[@class="ymusic-charts-metadata"]',
		 'entries[]' => scraper { 
			process '//a[@class="ymusic-link-title ymusic-ellipsis"]',
			 'title' => 'TEXT';
			process '//a[@class="ymusic-link-subtitle ymusic-ellipsis"]',
			 'artist' => 'TEXT';
};
result qw ( entries );
};


my $feed = {
	title => 'yahoochart',
	link => $uri,
	type => 'yahoochart',
};

foreach my $links (@links){
         $mech->get($links);
         my $contents = $s->scrape($mech->content, $mech->uri);

        foreach my $entry ( @{$contents} ) {
                push @{$feed->{entries}}, {
                        title   => $entry->{artist},
                        body    => $entry->{title},
                        };
        }
         
}
use YAML;
binmode STDOUT, ":utf8";
print Dump $feed;






__END__

