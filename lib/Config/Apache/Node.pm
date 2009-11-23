package Config::Apache::Node;
use Moose;

use Config::Apache::Comment;
use Config::Apache::Container;
use Config::Apache::Directive;

has 'children' => (is => 'rw', isa => 'ArrayRef', default => sub {[]} );
has 'parent' => (
    is => 'ro',
    isa => 'Maybe[Config::Apache::Node]',
    weak_ref => 1,
    required => 1,
    default => sub{undef},
);

sub append {
    my ($self, $type, $args) = @_;

    my @children = @{$self->children};
    if (    $type eq 'comment' 
         && ref $children[-1] eq 'Config::Apache::Comment') {
        $children[-1]->append($args->{value});
    } else {
        no strict 'refs';
        push(@children, "Config::Apache::\u$type"->new($args));
    }
    $self->children( \@children );
}

sub root {
    my ($p) = @_;
    # go up the chain
    $p = $p->parent while $p->parent;
    return $p;
}

1;
