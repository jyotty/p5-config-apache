package Config::Apache;
use Any::Moose;

use Config::Apache::Comment;
use Config::Apache::Directive;

use IPC::System::Simple qw(capturex);

our $VERSION = '0.01';

has 'config_file' => (is => 'ro', isa => 'Str');
has 'parsed_config' => (is => 'rw', isa => 'HashRef', default => {});

sub BUILDARGS {
    my ($class, %opts) = @_;

    if (!exists $opts{config_file}) {
        my $compile_settings = capturex('apachectl', '-V');
        ($opts{config_file}) = $compile_settings =~ m/SERVER_CONFIG_FILE="(.*?)"/;
    }
    return \%opts;
}

sub BUILD {
	
}



1;

__END__

=head1 NAME

Config::Apache - Parse, query and modify Apache configuration files.

=head1 VERSION

Version 0.01

=head1 SYNOPSIS

    use Config::Apache;

    my $conf = Config::Apache->new(); # uses the apachectl from $ENV{PATH}
    my $conf = Config::Apache->new(ServerRoot => '/usr/local/apache');

    my $vhost = $conf->query(...);
    $vhost->munge->horribly;

    ...

    $conf->commit;
    

=head1 FUNCTIONS

=head2 function1

=cut

=head2 function2

=cut

=head1 AUTHOR

Josh Yotty, C<< <asdf at asdf dot adsf> >>

=head1 BUGS

Frot



=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc Config::Apache


You can also look for information at:

=head1 ACKNOWLEDGEMENTS


=head1 COPYRIGHT & LICENSE

Copyright 2009 Josh Yotty, all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.


=cut
