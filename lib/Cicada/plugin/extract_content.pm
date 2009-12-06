package Cicada::plugin::extract_content;
use HTML::ExtractContent;

sub init {
	my ($class) = @_;

	no strict 'refs';
	no warnings 'redefine';

	*{'Cicada::extract_content'} = sub {
		my $cicada = shift;
		my $source = shift;
		my $extractor = HTML::ExtractContent->new;
		$extractor->extract($source);
		return $extractor->as_text;
	};
}

__PACKAGE__->init();

=head1 NAME

Cicada::plugin::extract_content - Provide extract_content method to Cicada!

=head1 VERSION

Version 0.01

=head1 SYNOPSIS

    use Cicada;
    use Cicada::plugin::extract_content;
    
    my $cicada = Cicada->new;
    my $res = ...(Some staff to get HTTP::Response object)...;
    my $content = $cicada->extract_content($res->decoded_content);
    print $content;

=head1 FUNCTIONS

=head2 extract_content

 $content = $cicada->extract_content($source);

Returns extracted content by HTML::ExtractContent.

=cut

=head1 AUTHOR

Makio Tsukamoto, C<< <tsukamoto at gmail.com> >>

=head1 COPYRIGHT & LICENSE

Copyright 2009 Makio Tsukamoto, all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

=cut

1;
