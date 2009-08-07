#!/usr/bin/perl

use strict;
use warnings;
use Test::More 'no_plan';

use Config::Apache;
use Data::Dump;

my $c = Config::Apache->new(config_file => 't/confs/simple.conf');
is_deeply($c->children, 
        [{
            name   => 'Directory',
            value  => '/var/www',
            children => [
                { name => "Options", value => ['Indexes FollowSymLinks MultiViews'] },
                { name => "AllowOverride", value => 'None' },
                {
                    name    => 'LimitExcept',
                    value   => [qw(GET HEAD POST)],
                    children => [
                        { name  => 'Order',
                          value => 'deny,allow' },
                        { name  => 'Deny',
                          value => ['from', 'all'] },
                    ],
                },
            ]
        }],
        'simple nested conf'
);
