package Cicada::plugin::decoded_content;
use Compress::Zlib ();
use Encode;
use Encode::Guess qw/euc-jp shiftjis 7bit-jis/;

my $decoder = undef;

sub init {
	my ($class) = @_;

	no strict 'refs';
	no warnings 'redefine';

	*{'Cicada::decoded_content'} = sub {
		my $cicada = shift;
		my $source = shift;
		my $content = $class->_decoded_content($cicada, $source);
		return $content;
	};
}

sub _decoded_content {
	my ($class, $cicada, $source) = @_;
	my $response = UNIVERSAL::isa($source, 'HTTP::Response') ? $source : undef;

	# extract content
	my $content = $response ? $response->content : $source;
	if ($response && $response->headers->header('content-encoding') && $response->headers->header('content-encoding') eq 'gzip') {
		$content = Compress::Zlib::memGunzip(\($response->{_content}));
	}

	#decode content
	unless (Encode::is_utf8($content)) {
		my $decoder = $class->_decoder($cicada);
		if (UNIVERSAL::isa($decoder, 'Data::Decode')) {
			my @args = ($content);
			push(@args, {response => $response}) if ($response);
			$content = $decoder->decode(@args);
		} else {
			$content = decode('Guess', $content);
		}
	}
	$content =~ s/\x0D\x0A?|\x0A/\n/gs;

	return $content;
}

sub _decoder {
	my($class, $cicada) = @_;
	my $decoder = $class . '::decoder';
	return ${$decoder} if (${$decoder});

	# use Data::Decode if can
	eval {
		my @mods = qw(Data/Decode.pm Data/Decode/Chain.pm Data/Decode/Encode/Guess/JP.pm Data/Decode/Encode/HTTP/Response.pm);
		$cicada->require_once($_) for (@mods);
	};

	if ($INC{'Data/Decode/Encode/HTTP/Response.pm'}) {
		${$decoder} = Data::Decode->new(
			strategy => Data::Decode::Chain->new(
				 decoders => [
					Data::Decode::Encode::HTTP::Response->new(),
					Data::Decode::Encode::Guess::JP->new(),
				 ]
			)
		);
	} else {
		${$decoder} = 'Encode';
	};
	return ${$decoder};
}

__PACKAGE__->init();

=head1 NAME

Cicada::plugin::decoded_content - Provide decoded_content method to Cicada!

=head1 VERSION

Version 0.01

=head1 SYNOPSIS

    use Cicada;
    use Cicada::plugin::decoded_content;
    
    my $cicada = Cicada->new;
    my $res = ...(Some staff to get HTTP::Response object)...;
    my $html = $cicada->decoded_content($res);
    print $html;

=head1 FUNCTIONS

=head2 decoded_content

 $content = $cicada->decoded_content($source);

Returns uncompressed and decoded content.
$source shoud be html text or HTTP::Response object.

=cut

=head1 AUTHOR

Makio Tsukamoto, C<< <tsukamoto at gmail.com> >>

=head1 COPYRIGHT & LICENSE

Copyright 2009 Makio Tsukamoto, all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

=cut

1;
