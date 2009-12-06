package Cicada::plugin::mechanize;
use WWW::Mechanize;

sub init {
	my ($class) = @_;

	no strict 'refs';
	no warnings 'redefine';

	*{'Cicada::mechanize'} = sub {
		my $cicada = shift;
		$cicada->{'_mechanize'} = shift if (@_);
		if (not $cicada->{'_mechanize'}) {
			my $agent = sprintf("%s %f", ref($cicada), $cicada->VERSION);
			$cicada->{'_mechanize'} = WWW::Mechanize->new('agent' => $agent);
			$cicada->{'_mechanize'}->env_proxy();
		}
		return $cicada->{'_mechanize'};
	};
}

__PACKAGE__->init();

=head1 NAME

Cicada::plugin::mechanize - Provide mechanize method to Cicada!

=head1 VERSION

Version 0.01

=head1 SYNOPSIS

    use Cicada;
    use Cicada::plugin::mechanize;
    
    my $cicada = Cicada->new;
    my $mech = $cicada->mechanize;
    my $res = $mech->get('http://www.example.com');
    print $res->decoded_content;

=head1 FUNCTIONS

=head2 mechanize

 $feed = $cicada->mechanize();

Returns WWW::Mechanize object.
This object is stored in $cicada->{'_mechanize'} and reused in second time or later.

=head1 AUTHOR

Makio Tsukamoto, C<< <tsukamoto at gmail.com> >>

=head1 COPYRIGHT & LICENSE

Copyright 2009 Makio Tsukamoto, all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

=cut

1;
