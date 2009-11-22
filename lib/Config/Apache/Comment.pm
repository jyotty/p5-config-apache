package Config::Apache::Comment;
use Moose;

has 'value' => (is => 'rw', isa => 'Str', required => 1);

sub append {
    my $self = shift;
    $self->value($self->value().shift);
}

1;
