package Cicada::plugin::history;

use strict;
use warnings;

use Cicada::plugin::db;

sub init {
	my ($class) = @_;

	no strict 'refs';
	no warnings 'redefine';

	*Cicada::history = sub {
		my $cicada = shift;
		return $class->_history($cicada, @_);
	};
}

sub _history {
	my $class = shift;
	my $cicada = shift;
	my $url = shift;
	my $data = shift;
	my($stmt, @bind);

	my $db = $cicada->db;

	# create database
	my $table = 'history';
	my $sql = 'create table ' . $table . ' (id varchar(255) not null primary key, url varchar(255) not null, status integer, time integer)';
	$db->tables('', '', $table) || $db->do($sql);

	# select
	my $id = length($url) < 255 ? $url : Digest::MD5::md5_base64($url);
	my $record = $db->selectrow_hashref("select * from $table where id = ?", {}, $id);
	return $record if (not $data);

	# insert or update
	$data = $class->_history_data($data);
	if ($record) {
		($stmt, @bind) = SQL::Abstract->new->update($table, $data, {'id'=>$id}) if ($data && (keys(%$data)));
	} else {
		$data ||= {};
		$data->{'id'} ||= $id;
		$data->{'url'} ||= $url;
		($stmt, @bind) = SQL::Abstract->new->insert($table, $data);
	}
	my $result = $db->prepare($stmt)->execute(@bind) && $db->commit;
	return $result;
}

sub _history_data {
	my $class = shift;
	my $url = shift;
	my $data = shift;
	
	my $result = {};
	if (UNIVERSAL::isa($data, 'HTTP::Response')) {
		my $date = $data->header('Date');
		$result->{'time'} = HTTP::Date::str2time($date);
		$result->{'status'} = $data->code;
	} elsif (UNIVERSAL::isa($data, 'XML::FeedPP::Item')) {
		$result->{'time'} = XML::FeedPP::Util::rfc1123_to_epoch($data->{'pubDate'}) || time();
	} elsif (UNIVERSAL::isa($data, 'HASH')) {
		%$result = %$data;
		$result->{'time'} = time() if (not exists($result->{'time'}));
	}
	return $result;
}

__PACKAGE__->init();

=head1 NAME

Cicada::plugin::history - Provide history method to Cicada!

=head1 VERSION

Version 0.01

=head1 SYNOPSIS

    use Cicada;
    use Cicada::plugin::history;
    
    my $cicada = Cicada->new();
    my $url = 'http://www.example.com';
    if (my $history = $cicada->history($url)) {
        print "$url stored on " . localtime($history->{'time'});
    } else {
        $cicada->history($url, {'time' => time()});
        print "$url stored!";
    }

=head1 DESCRIPTION

Recording url, process status (or result) and time is one of commonly way to avoid reprocessing already processed url.
This plugin provides a simple method to store history into or fetch from database.

=head1 FUNCTIONS

=head2 history

 $feed = $cicada->history($url [, $data]);

1st. argment is url, required.
Returns history data of $url stored before.
This data is hash reference includes id, url, status (integer, meybe http response code) and time (integer, epoch seconds).

2nd. argment is data to be stored, it should be hash reference, HTTP::Response object or XML::FeedPP::Item object.
Hash reference can include id, status and time, although empty hash reference is allowed.
HTTP::Response is acceptable, status and time are set with header values.
XML::FeedPP::Item is acceptable, time are set with pubDate.

=head1 AUTHOR

Makio Tsukamoto, C<< <tsukamoto at gmail.com> >>

=head1 COPYRIGHT & LICENSE

Copyright 2009 Makio Tsukamoto, all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

=cut

1;
