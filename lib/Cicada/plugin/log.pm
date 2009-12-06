package Cicada::plugin::log;

sub init {
	my ($class) = @_;

	no strict 'refs';
	no warnings 'redefine';

	*{'Cicada::log'} = sub {
		my $cicada = shift;
		my %log = @_;
		if (my $logger = $cicada->log_dispatch) {
			$logger->log(%log);
		} else {
			my $messsage = sprintf("[%s] %s", $log{'level'}, $log{'message'});
			$messsage =~ s/\s*$/\n/s;
		}
	};

	*{'Cicada::log_dispatch'} = sub {
		my $cicada = shift;
		
		if (@_ && UNIVERSAL::isa($_[0], 'Log::Dispatch')) {
			$cicada->{'_log'} = shift;
			@_ = ();
		}
		
		if (not $cicada->{'_log'} || @_) {
			eval { $cicada->require_once('Log/Dispatch.pm'); };
			if ($INC{'Log/Dispatch.pm'} && Log::Dispatch->VERSION >= 2.24) { # Simplified constructor is avalilable
				my %args = @_;
				$args{'outputs'} ||= [['Screen', min_level => 'info']];
				$cicada->{'_log'} = Log::Dispatch->new(%args);
			}
		}
		
		return $cicada->{'_log'};
	};

	foreach my $level (qw(debug info notice warning err error crit critical alert emerg emergency)) {
		*{"Cicada::$level"} = sub {
			my $cicada = shift;
			$cicada->log( level => $level, message => "@_" );
		};
	}
}

__PACKAGE__->init();

=head1 NAME

Cicada::plugin::log - Provide logging methods to Cicada!

=head1 VERSION

Version 0.01

=head1 SYNOPSIS

    use Cicada;
    use Cicada::plugin::log;
    
    my $cicada = Cicada->new;
    $cicada->log('level' => 'debug', 'message' => "'debug' is supressed with Log::Dispatch.\n");
    $cicada->log('level' => 'info', 'message' => "'info' is printed.\n");
    $cicada->warning("'warning' method printing this.\n");
    print "Logger is " . ref($cicada->log_dispatch) . "\n";

=head1 DESCRIPTION

Logging is commonly matter.
This provides log, info, warn, and other some methods like Log::Dispatch.
When Log::Dispatch 2.24 or higher is available, logs are processed with Log::Dispatch, otherwise logs are just printed to STDOUT.

=head1 FUNCTIONS

=head2 log

    $cicada->log('level' => $level, 'message' => $message);

Logs.

=head2 debug, info, notice, warning, err, error, crit, critical, alert, emerg, emergency

    $cicada->info($message);

Logs as "method name" level.

=head2 log_dispatch

    $dispatcher = $cicada->log_dispatch([%opt|$dispatcher]);

Returns Log::Dispatcher object.
When Log::Dispatch is unavailable, returns undef.

When %opt is passed, Log::Dispatcher object is (re)construted with %opts.
When $dispatcher is passed, $dispather is set as current dispatcher.

=head1 AUTHOR

Makio Tsukamoto, C<< <tsukamoto at gmail.com> >>

=head1 COPYRIGHT & LICENSE

Copyright 2009 Makio Tsukamoto, all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

=cut

1;
