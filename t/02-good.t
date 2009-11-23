#!/usr/bin/perl

use strict;
use warnings;
use Test::More 'no_plan';

use Config::Apache;

my $simple_conf = Config::Apache->new(config_file => 't/confs/simple.conf');
is_deeply($simple_conf->children,
        [{
            name   => 'Directory',
            value  => '/var/www',
            children => [
                { name => "Options", value => [qw(Indexes FollowSymLinks MultiViews)] },
                { name => "AllowOverride", value => 'None' },
                { name => "DirectoryIndex", value => ['index.html', 'test index.html']},
                {
                    name    => 'LimitExcept',
                    value   => [qw(GET HEAD POST)],
                    children => [
                        { name  => 'Order',
                          value => 'deny,allow' },
                        { name  => 'Deny',
                          value => ['from', 'all'] },
                    ],
                    parent => $simple_conf->children->[0],
                },
            ],
            parent => $simple_conf,
        },
        {
            value => "\n",
        },
        {
            name => 'MaxRequestsPerChild',
            value => 0,
        }],
        'simple nested conf'
);

my $backslash_conf = Config::Apache->new(config_file => 't/confs/backslash.conf');
is_deeply($backslash_conf->children,
        [{
            name   => 'IfModule',
            value  => 'dir_module',
            children => [
                { name => "DirectoryIndex", value => ['index.html', 'test index.html']},
            ],
            parent => $backslash_conf,
        },
        {
            name   => 'Directory',
            value  => '/var/www',
            children => [
                {
                    name    => 'LimitExcept',
                    value   => [qw(GET HEAD POST)],
                    children => [
                        { name  => 'Order',
                          value => 'deny,allow' },
                        { name  => 'Deny',
                          value => ['from', 'all'] },
                    ],
                    parent => $backslash_conf->children->[1],
                },
            ],
            parent => $backslash_conf,
        }],
        'backslashes before a newline are a continuation'
);
