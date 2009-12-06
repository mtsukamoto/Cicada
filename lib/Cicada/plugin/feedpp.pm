package Cicada::plugin::feedpp;
use XML::FeedPP;

sub init {
	my ($class) = @_;

	no strict 'refs';
	no warnings 'redefine';

	*{'Cicada::feedpp'} = sub {
		my $cicada = shift;
		$cicada->{'_feedpp'} = shift if (@_ && UNIVERSAL::isa($_[0], 'XML::FeedPP'));
		$cicada->{'_feedpp'} ||= (@_) ? XML::FeedPP->new(@_) : XML::FeedPP::RSS->new();
		return $cicada->{'_feedpp'};
	};

	# generate new feed item from HTTP::Response object
	*{'Cicada::feedpp_add_item'} = sub {
		my $cicada = shift;
		my $res  = shift;
		my $feed = shift || $cicada->feedpp;
		my $item = shift if (@_);
		
		return unless (UNIVERSAL::isa($res, 'HTTP::Response'));
		
		my $url = $res->request->uri->as_string;
		$item ||= $feed->add_item($url);

		my $date = $res->header('Date');
		my $time = HTTP::Date::str2time($date) if ($date);
		$time = time() if (not $time && not $item->pubDate);
		$item->pubDate($time) if ($time); 

		if ($res->header('Content-Type') =~ /^text\//i) {
			my $content = $cicada->can('decoded_content') ? $cicada->decoded_content($res) : $res->content;
			my $title = $1 if ($res->header('Content-Type') =~ /^text\/html/i && $content && $content =~ /<title>(.*?)<\/title>/is);
			if (not $title && not $item->title) {
				$title = $url;
				$title =~ s/\?.*$//;
				$title =~ s/^.*\///;
			}
			$content = $1 if ($res->header('Content-Type') =~ /^text\/html/i && $content && $content =~ /<body\b.*?>(.*?)<\/body>/is);
			$item->description($content) if ($content);
			$item->title($title) if ($title);
		}

		return $item;
	};
}

__PACKAGE__->init();

=head1 NAME

Cicada::plugin::feedpp - Provide feedpp method to Cicada!

=head1 VERSION

Version 0.01

=head1 SYNOPSIS

    use Cicada;
    use Cicada::plugin::feedpp;
    use LWP::UserAgent;
    
    my $cicada = Cicada->new;
    my $feed = $cicada->feedpp;
    
    my $ua = 
    my $res = ...(Some staff to get HTTP::Response object)...;
    my $item = $cicada->feedpp_add_item($res, $feed);
    print $item->title . " - " . $item->link;

=head1 DESCRIPTION

Deciding internal data structure is commonly matter, I think XML::FeedPP object is enough suitable.
This plugin provide method for get a XML::FeedPP object. 
This create XML::FeedPP object with argments at first time, returns same objcet at second time or later.

Additionally this provide adding XML::FeedPP::Item with default value extracted from HTTP::Response object.

=head1 FUNCTIONS

=head2 feedpp

 $feed = $cicada->feedpp();

Returns XML::FeedPP object.
This object is stored in $cicada->{'_feedpp'} and reused in second time or later.

=head2 feedpp_add_item

 $item = $cicada->feedpp_add_item($res [,$feed [,$item]]);

Returns XML::FeedPP::Item object which has set title (extracted from content title), decription (from content body), pubDate (from Date header).
1st. argment is HTTP::Resonse object, required.
2nd. is XML::FeedPP obeject, $cicada->feed is used as default.
3rd. is XML::FeedPP::Item obeject, new item created with $feed->add_item is used as default.

=head1 AUTHOR

Makio Tsukamoto, C<< <tsukamoto at gmail.com> >>

=head1 COPYRIGHT & LICENSE

Copyright 2009 Makio Tsukamoto, all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

=cut

1;
