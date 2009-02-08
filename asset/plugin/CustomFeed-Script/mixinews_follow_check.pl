#!/usr/bin/perl

use strict;
use warnings;
use URI;
use YAML;
use utf8;
use File::Basename;
use WWW::Mechanize;
use Web::Scraper;

my $uri = URI->new( 'http://mixi.jp/' );
#my $url = 'http://news.mixi.jp/list_news.pl';
my $username = 'example@example.com';
my $password = "password";
my $mech = new WWW::Mechanize;
   $mech->get($uri);
   $mech->submit_form(
                 fields => {
                    email     => $username,
                    password => $password,
                 }
   );

my $filename = basename(__FILE__);
my $url = $ARGV[0]
    or die "Usage: $filename url\n";

   $mech->get($url);

my @links = $mech->find_all_links( url_regex => qr/view_news\.pl\?id\=\d{6}\&media_id\=\d{2}$/ );

my $s = scraper {
              process '//div[@id="bodyMainArea"]',
                      'entries[]' => scraper {
                                   process '//div[@class="newsArticle"]//h2',title => 'TEXT';
					process '//p[@class="date"]', date => 'TEXT'; 
					process '//div[@class="article"]', body => 'HTML';
					process '//div[@id="viewNewsCategoryNews"]//h2', category => [ 'TEXT',  sub { @_= /(.*?)\s.*?/gm;$1} ];
                                   };
			result qw( entries );
             };
my $src = $s->scrape($mech->content, $mech->uri);
my $feed = {
	title => 'mixi NEWS',
	link  => $url,
	type => 'mixinews',
}; 

foreach my $links (@links){
	 $mech->get($links);
	 my $contents = $s->scrape($mech->content, $mech->uri);

	foreach my $entry ( @{$contents} ) {
		push @{$feed->{entries}}, {
			title   => $entry->{category}. "/" .$entry->{title},
			link => $mech->uri,
			summary => $entry->{date},
			body    => $entry->{body},
			};
	}
	 
}
binmode STDOUT, ":utf8";
print Dump($feed);
