package Plagger::Plugin::Filter::HatenaBookmarkRelatedEntry;
use strict;
use base qw( Plagger::Plugin );
use Web::Scraper;
use URI;

sub register {
    my($self, $context) = @_;
    $context->register_hook(
        $self,
        'update.entry.fixup' => \&update,
    );
}

sub update {
    my($self, $context, $args) = @_;

    # xxx need cache & interval
    my $url  = 'http://b.hatena.ne.jp/entry/' . $args->{entry}->permalink;
    my $uri = URI->new($url);
    my $scraper = scraper {
    process '/html/body/div/div[5]/div/div[2]/div[2]/div[12]/ul', 'body' => 'HTML'; ;
};

    my $result = $scraper->scrape($uri);
    if(!$result){
                $context->log( error => "Can't scrap or no contens in related this entry" );
                last;
        }
    my $body = $args->{entry}->body;
       $result = "<ul>".$result->{body}."</ul>";
       $body .= $result;
#    foreach my $list ( @{ $result->{list} }){;
#       $body .= "<p>".$list."</p>";
#    }
    $args->{entry}->body($body);
}

1;

__END__