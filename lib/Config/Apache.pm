package Config::Apache;
use Moose;

extends 'Config::Apache::Node';

use Carp;

use IPC::System::Simple qw(capturex);
use File::Spec::Functions;

our $VERSION = '0.04';

has 'config_file' => (is => 'ro', isa => 'Str');
has 'compiled_with' => (is => 'ro', isa => 'HashRef[Str]');

sub BUILDARGS {
    my ($class, %opts) = @_;

    my @compile_settings = capturex('apachectl', '-V');
    my %compiled_with;
    for (@compile_settings) {
        next unless /^\s-D/x;

        if (/^\s-D\s([_A-Z]+)="?(.*?)"?$/x) {
            $compiled_with{$1} = $2;
        } elsif (/^\s-D\s([_A-Z]+)/x) {
            $compiled_with{$1} = 1;
        }
    }
    $opts{compiled_with} = \%compiled_with;
    if (!exists $opts{config_file}) {
        my ($hr, $cf) = ($compiled_with{HTTPD_ROOT}, $compiled_with{SERVER_CONFIG_FILE});
        $opts{config_file} = $cf =~ m{^/} ? $cf : catfile($hr, $cf);
    }
    return \%opts;
}

sub BUILD {
    my ($self) = shift;
    open my $cf, '<', $self->config_file or croak "Can't open config file: $!";

    my @ancestors;
    my $acc = '';

    while (<$cf>) {
        if (m/\\$/) { # backslash at end of line
            chomp; chop; # first time I've ever used this
            $acc .= $_;
            next;
        } elsif ($acc) {
            $_ = $acc.$_;
            $acc = '';
        }

        # if we're inside a container, add to that node
        my $ref = scalar @ancestors ? $ancestors[-1]->{'ref'} : $self;

        if (m/^\s*\#/x || m/^\s*$/x) { # comment or blank line
            $ref->append('comment', {value => $_});
        } elsif (m/^ \s* < (.*?) \s+ (.*) > /x) { # apache directive container
            $ref->append('container', {name => $1, value => $2, parent => $ref});
            # add it to the stack so contained directives go… in the container
            push @ancestors, {'ref' => $ref->children->[-1], start => $1}; 
        } elsif (m{^ \s* </ (.*?) > \s* $}x) { # container end
            my $node = pop @ancestors;
            if (!$node) {
                croak "Container end tag </$1> on line $. has no open tag";
            } elsif ($node->{start} ne $1) {
                croak "Container end tag </$1> on line $. does not match start tag <$node->{start}>";
            }
        } elsif (m/ \s* (\S+) \s* (.*)/x) { # directive
            $ref->append('directive', {name => $1, value => $2});
        } else {
            croak "Error on line $.: $_";
        }
    }

    if (scalar @ancestors) {
        croak "Open container tag $ancestors[-1]->{start} was not closed by eof";
    }
}

1;

__END__

=head1 NAME

Config::Apache - Parse, query and modify Apache configuration files.

=head1 VERSION

Version 0.04

=head1 SYNOPSIS

    use Config::Apache;

    my $conf = Config::Apache->new(); # uses the apachectl from $ENV{PATH}
    my $conf = Config::Apache->new(ServerRoot => '/usr/local/apache');

    my $vhost = $conf->query(...);
    $vhost->munge->horribly;

    ...

    $conf->commit;
    
=head1 BUGS

Plenty

=head1 COPYRIGHT & LICENSE

Copyright 2009 Josh Yotty, all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

=cut
