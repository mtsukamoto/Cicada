package Cicada;

use warnings;
use strict;

use File::Path;

=head1 NAME

Cicada - Web Crawler creating toolkit 

=head1 VERSION

Version 0.01

=cut

our $VERSION = '0.01';

my %REQUIRED;
my %LOADED;

BEGIN {
	%REQUIRED = ();
	%LOADED = ();
};

=head1 SYNOPSIS

    package MyCrawler;
    
    use base qw(Cicada);
    use Cicada::plugin::feedpp;
    use Cicada::plugin::decoded_content;
    use Cicada::plugin::extract_content;
    use Cicada::plugin::history;
    use Cicada::plugin::log;
    use Cicada::plugin::mechanize;
    
    my $crawler = MyCrawler->new;
    my $url = 'http://news.google.com/news?hl=ja&ned=us&ie=UTF-8&oe=UTF-8&output=rss&topic=h';
    
    $crawler->info("[feed] $url\n");           # act as Log::Dispatch::log
    my $res = $crawler->mechanize->get($url);  # doing WWW::Mechanize::get
    my $rss = $crawler->decoded_content($res); # decode with Data::Decode and Compress::Zlib
    $crawler->feedpp($rss);                    # return and store XML::FeedPP(::RSS) object
    
    my @reads = ();
    my @items = $crawler->feedpp->get_item;
    for (my $i = 0; $i < @items; $i++) {
        my $url = $items[$i]->link;
        # skip and record (to remove later) already-read item
        if ($crawler->history($url)) {         # check history data stored in sqlite3 database
            $crawler->info("[item] $url (skip)\n");
            push(@reads, $i);
            next;
        }
        # update description (as Plagger's EntryFullText does)
        $crawler->info("[item] $url\n");
        $crawler->mechanize->get($url);
        if (not $crawler->mechanize->res->is_success) {
            $crawler->warning($crawler->mechanize->res->status_line . "\n");
            next;
        }
        my $html = $crawler->decoded_content($crawler->mechanize->res);
        my $body = $crawler->extract_content($html); # parse with HTML::ExtractContent
        $items[$i]->description($body);
        $crawler->history($url => $res);       # store history data into sqlite3 database
    }
    # remove already-read items
    $crawler->feedpp->remove_item($_) for (reverse(@reads));
    
    my $path = $crawler->data_dir . '/result.rss'; # provides default data directory
    $crawler->info("[result] $path\n");
    $crawler->feedpp->to_file($path);

=head1 DESCRIPTION

Cicada is toolkit for creating Web Crawler.
This is not a framework to create web crawler for persistent use, such as Plagger or Gungho.
This is frequency used methods collection to create ephemeral crawler for temporary use.

Cicada provides trim, data_dir, require_once, load_once by itself.
With its plugins, Cicada can provide additional methods like db, hisotry, timestamp extract_content and so on.

It's still alpha. use it at your own risk!

=head1 FUNCTIONS

=head2 new

Constructor.

=cut

sub new {
	my ($class, %args) = @_;
	my $self = {};
	$self->{$_} = $args{$_} for (keys(%args)); # 必要に応じてkeyを制限する
	$self = bless ($self, $class);
	return $self;
}

=head2 trim

Delete blanks on top and bottom of string.
If argument is array or hash reference, this method trims its values recursively.

=cut

sub trim {
	my $self = shift;
	return unless (@_);
	my $data = shift;
	if (defined($data)) {
		if (not ref($data)) {
			$data =~ s/^\s+|\s+$//gs;
		} elsif (ref($data) eq 'ARRAY') {
			$data->[$_] = $self->trim($data->[$_]) for (0..$#$data);
		} elsif (ref($data) eq 'HASH') {
			$data->{$_} = $self->trim($data->{$_}) for (keys(%$data));
		}
	}
	return $data;
}

=head2 var_dir

Returns directory for variavles.
It becomes "_var" value specified to new(), default is './var'.

=cut

sub var_dir {
	my $self = shift;
	my $dir  = $self->{'_var'} || './var';
	mkpath($dir, 0, 0711) unless (-d $dir);
	return $dir;
}

=head2 data_dir

Returns directory for your datas.
It becomes "<var_dir>/<Cicada subclass name>".

=cut

sub data_dir {
	my $self = shift;
	my $package = ref($self) || $self;
	$package =~ s|::|/|g;
	my $dir  = $self->var_dir . '/' . $package;
	mkpath($dir, 0, 0711) unless (-d $dir);
	return $dir;
}

=head2 require_once

Require specified path.
This execute requiring only one time for each path.
Nothing done on second or later time.

=cut

sub require_once {
	my $self = shift;
	my $path = shift;
	return if $REQUIRED{$path};
	require $path;
	$REQUIRED{$path} = 1;
}

=head2 load_once

Load (means "do" function) specified path.
This execute loading only one time for each path.
Nothing done on second or later time.

=cut

sub load_once {
	my $self = shift;
	my ($path, $mark_path) = @_;
	$mark_path ||= $path;
	return $LOADED{$mark_path} if exists $LOADED{$mark_path};
	local $@;
	if (do $path) {
		$LOADED{$mark_path} = 1;
		return 1;
	}
	die $@ if $@;
	$LOADED{$mark_path} = undef;
}

=head2 loaded

Return specified path is already loaded or not.

=cut

sub loaded {
	my $self = shift;
	my $path = shift;
	$LOADED{$path} = shift if @_;
	$LOADED{$path};
}

=head1 AUTHOR

Makio Tsukamoto, C<< <tsukamoto at gmail.com> >>

=head1 COPYRIGHT & LICENSE

Copyright 2009 Makio Tsukamoto, all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

=cut

1; # End of Cicada
