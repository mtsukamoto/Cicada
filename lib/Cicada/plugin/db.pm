package Cicada::plugin::db;
use strict;
use warnings;

use Cicada::plugin::db;

use DBI;
use SQL::Abstract;
use Digest::MD5;

our $VERSION = '0.01';

sub init {
	my ($class) = @_;

	no strict 'refs';
	no warnings 'redefine';

	*Cicada::db = sub {
		my $cicada = shift;
		my $name = shift || 'default_database';
		if (not $cicada->{_db}->{$name}) {
			my $uri  = $name;
			if ($uri !~ /:/) {
				mkdir $cicada->data_dir() unless (-d $cicada->data_dir());
				$uri = sprintf('dbi:SQLite:%s/%s.db', $cicada->data_dir(), $uri);
			}
			$cicada->{_db}->{$name} = DBI->connect($uri);
			$cicada->{_db}->{$name}->{unicode} = 1 if ($uri =~ /^dbi:sqlite:/i);
		}
		return $cicada->{_db}->{$name};
	};
}

__PACKAGE__->init();

=head1 NAME

Cicada::plugin::db - Provide db method to Cicada!

=head1 VERSION

Version 0.01

=head1 SYNOPSIS

    use Cicada;
    use Cicada::plugin::db;
    
    my $cicada = Cicada->new();
    my $db = $cicada->db;
    my $data = $db->selectrow_hashref("select * from my_table where id = ?", {}, 1);_

=head1 DESCRIPTION

Using database is commonly needs to make data permanent, save memory and so on.
This plugin provides a simple method to get dbi object with sqlite3 database as default.

=head1 FUNCTIONS

=head2 db

 $dbi = $cicada->db([$name]);

Returns dbi object.
First argment $name is dsn or sqlite db file base name, default is 'default_db'.
When $name is not dsn, sqlite3 dsn is created with directory $cicada->data_dir and base name $name.

=head1 AUTHOR

Makio Tsukamoto, C<< <tsukamoto at gmail.com> >>

=head1 COPYRIGHT & LICENSE

Copyright 2009 Makio Tsukamoto, all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

=cut

1;
