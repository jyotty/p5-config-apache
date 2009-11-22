package Config::Apache::Node;
use Moose;

use Config::Apache::Comment;
use Config::Apache::Container;
use Config::Apache::Directive;

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

1;
