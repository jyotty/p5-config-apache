#!/usr/bin/perl

use strict;
use warnings;
use Test::More 'no_plan';

use Config::Apache;
use Data::Dump;


is_deeply(Config::Apache->new(config_file => 't/confs/simple.conf')->children, 
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
                },
            ]
        }],
        'simple nested conf'
);

is_deeply(Config::Apache->new(config_file => 't/confs/backslash.conf')->children, 
        [{
            name   => 'IfModule',
            value  => 'dir_module',
            children => [
                { name => "DirectoryIndex", value => ['index.html', 'test index.html']},
            ],
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
                },
            ]
        }],
        'backslashes before a newline are a continuation'
);


