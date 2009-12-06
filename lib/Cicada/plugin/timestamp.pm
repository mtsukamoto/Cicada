package Cicada::plugin::timestamp;

use strict;
use warnings;

use Cicada::plugin::db;

sub init {
	my ($class) = @_;

	no strict 'refs';
	no warnings 'redefine';

	*Cicada::timestamp = sub {
		my $cicada = shift;
		return $class->_timestamp($cicada, @_);
	};
}

sub _timestamp {
	my $class = shift;
	my $db = shift;

	# create database
	my $table = 'timestamp';
	my $sql = 'create table ' . $table . ' (id integer not null primary key autoincrement, timestamp integer not null)';
	$db->tables('', '', $table) || $db->do($sql);

	# select
	my $id = 1;
	my $record = $db->selectrow_hashref('select * from ' . $table, {'id'=>$id});
	return $record ? $record->{'timestamp'} : () unless (@_);

	# define timestamp
	my $timestamp = shift;
	if (UNIVERSAL::isa($timestamp, 'HTTP::Response')) {
		my $date = $timestamp->header('Date');
		$timestamp = HTTP::Date::str2time($date);
	} elsif (UNIVERSAL::isa($timestamp, 'XML::FeedPP')) {
		if ($timestamp->{'pubDate'}) {
			$timestamp = XML::FeedPP::Util::rfc1123_to_epoch($timestamp->{'pubDate'});
		} else {
			my @items = $timestamp->get_item;
			my @time = sort { $b <=> $a } map { XML::FeedPP::Util::rfc1123_to_epoch($_->{'pubDate'}) } grep { $_->{'pubDate'} } @items;
			$timestamp = @time ? $time[0] : time();
		}
	} elsif (UNIVERSAL::isa($timestamp, 'XML::FeedPP::Item')) {
		$timestamp = XML::FeedPP::Util::rfc1123_to_epoch($timestamp->{'pubDate'}) || time();
	}

	# insert or update
	my $data = { 'id' => $id, 'timestamp' => shift };
	my($stmt, @bind);

	if ($record) {
		($stmt, @bind) = SQL::Abstract->new->update($table, $data, {'id'=>$id}) if ($data && (keys(%$data)));
	} else {
		($stmt, @bind) = SQL::Abstract->new->insert($table, $data);
	}
	my $result = $db->prepare($stmt)->execute(@bind) && $db->commit;
	return $result;
}

__PACKAGE__->init();

=head1 NAME

Cicada::plugin::timestamp - Provide timestamp method to Cicada!

=head1 VERSION

Version 0.01

=head1 SYNOPSIS

    use Cicada;
    use Cicada::plugin::timestamp;
    
    my $cicada = Cicada->new();
    if (my $timestamp = $cicada->timestamp) {
        print "Current timestamp is $timestamp";
    } else {
        $cicada->timestamp(time());
        print "Timestamp stored!";
    }

=head1 DESCRIPTION

Recording timstamp is one of commonly way to avoid reprocessing already processed url.
This plugin provides a simple method to store timestamp into or fetch from database.

=head1 FUNCTIONS

=head2 timestamp

 $feed = $cicada->timestamp([$timestamp]);

Returns timestamp (integer, eposh seconds) stored before.

1st. argment is data to be stored, it should be epoch seconds, HTTP::Response object, XML::FeedPP::Item object or XML::FeedPP object.
HTTP::Response is acceptable, Date header is stored.
XML::FeedPP::Item is acceptable, pubDate is stored.
Although XML::FeedPP (includes Atom, RSS, RDF and others) is acceptable, pubDate of itself or latest item is stored.

=head1 AUTHOR

Makio Tsukamoto, C<< <tsukamoto at gmail.com> >>

=head1 COPYRIGHT & LICENSE

Copyright 2009 Makio Tsukamoto, all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

=cut

1;
