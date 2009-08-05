package Config::Apache;
use Mouse;

use Carp;

use IPC::System::Simple qw(capturex);

our $VERSION = '0.01';

has 'config_file' => (is => 'ro', isa => 'Str');
has 'parsed_config' => (is => 'rw', isa => 'ArrayRef', default => sub {[]});

sub BUILDARGS {
    my ($class, %opts) = @_;

    if (!exists $opts{config_file}) {
        my $compile_settings = capturex('apachectl', '-V');
        ($opts{config_file}) = $compile_settings =~ m/SERVER_CONFIG_FILE="(.*?)"/;
    }
    return \%opts;
}

sub BUILD {
	my ($self) = shift;
	open my $cf, '<', $self->config_file or croak "Can't open config file: $!";
	
    while (<$cf>) {
        if (m/^\s*\#/x || m/^\s*$/x) { # comment or blank line
            $self->append('comment', {value => $_});
        } elsif (m/^ \s* < (.*?) \s+ (.*) > /x) {
            $self->append('container', {name => $1, value => $2});
        } elsif (m{^ \s* </ (.*) > }x) {
            #print "End container: </$1>\n";
        } else {
            m/\s*(\S+)\s*(.*)/x;
            $self->append('directive', {name => $1, value => $2});
        }
    }

    use Data::Dump;
    ddx $self->parsed_config;
}

sub append {
    my ($self, $type, $args) = @_;

    my @root = @{$self->parsed_config};
    if (    $type eq 'comment' 
         && ref $root[-1] eq 'Config::Apache::Comment') {
        $root[-1]->append($args->{value});
    } else {
        no strict 'refs'; # being evil is fun
        push(@root, "Config::Apache::\u$type"->new($args));
    }
    $self->parsed_config( \@root );
}

package Config::Apache::Node;
use Mouse;
has 'value' => (is => 'rw', isa => 'Str', required => 1);
#has 'parent' => (is => 'ro', weak_ref => 1);


package Config::Apache::Comment;
use Mouse;

extends 'Config::Apache::Node';

sub append {
    my $self = shift;
    $self->value($self->value().shift);
}
    

package Config::Apache::Directive;
use Mouse;

extends 'Config::Apache::Node';

has 'name' => (is => 'ro', isa => 'Str');


package Config::Apache::Container;
use Mouse;

extends 'Config::Apache::Directive';

has 'children' => (is => 'rw', isa => 'ArrayRef', default => sub {[]} );

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
    
=head1 BUGS

Plenty

=head1 COPYRIGHT & LICENSE

Copyright 2009 Josh Yotty, all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

=cut
