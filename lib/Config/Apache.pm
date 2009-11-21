package Config::Apache;
use Moose;

extends 'Config::Apache::Node';

use Carp;

use IPC::System::Simple qw(capturex);
use File::Spec::Functions;

our $VERSION = '0.03';

has 'config_file' => (is => 'ro', isa => 'Str');

sub BUILDARGS {
    my ($class, %opts) = @_;

    if (!exists $opts{config_file}) {
        my $compile_settings = capturex('apachectl', '-V');
        my ($hr, $cf) = $compile_settings =~ m/HTTPD_ROOT="(.*?)".*SERVER_CONFIG_FILE="(.*?)"/s;
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
            $ref->append('container', {name => $1, value => $2});
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


package Config::Apache::Node;
use Moose;

has 'children' => (is => 'rw', isa => 'ArrayRef', default => sub {[]} );

sub append {
    my ($self, $type, $args) = @_;

    my @root = @{$self->children};
    if (    $type eq 'comment' 
         && ref $root[-1] eq 'Config::Apache::Comment') {
        $root[-1]->append($args->{value});
    } else {
        no strict 'refs';
        push(@root, "Config::Apache::\u$type"->new($args));
    }
    $self->children( \@root );
}


package Config::Apache::Comment;
use Moose;

has 'value' => (is => 'rw', isa => 'Str', required => 1);

sub append {
    my $self = shift;
    $self->value($self->value().shift);
}
    

package Config::Apache::Directive;
use Moose;

has 'name' => (is => 'ro', isa => 'Str');
has 'value' => (is => 'rw', required => 1);

sub BUILD {
    my ($self) = shift;

    # ripped the double quoted matcher from perlre.
    # I'll be honest, I have no idea where the undefs come from.
    if ($self->value =~ /\s|"/) {
        my @args = grep { $_ } $self->value =~ /"((?>(?:(?>[^"\\]+)|\\.)*))"|(\S+)/g;
        $self->value(@args > 1 ? \@args : $args[0]);
    }
}


package Config::Apache::Container;
use Moose;

extends 'Config::Apache::Directive', 'Config::Apache::Node';


1;

__END__

=head1 NAME

Config::Apache - Parse, query and modify Apache configuration files.

=head1 VERSION

Version 0.03

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
