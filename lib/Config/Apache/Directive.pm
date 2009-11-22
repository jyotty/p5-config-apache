package Config::Apache::Directive;
use Moose;

has 'name' => (is => 'ro', isa => 'Str');
has 'value' => (is => 'rw', required => 1);

sub BUILD {
    my ($self) = shift;

    # ripped the double quoted matcher from perlre.
    # I'll be honest, I have no idea where the undefs come from.
    if ($self->value =~ /\s|"/) {
        my @args = grep { defined } $self->value =~ /"((?>(?:(?>[^"\\]+)|\\.)*))"|(\S+)/g;
        $self->value(@args > 1 ? \@args : $args[0]);
    }
}

1;
