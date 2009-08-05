#!/usr/bin/perl

use strict;
use warnings;
use Test::More 'no_plan';

use Config::Apache;

eval { Config::Apache->new(config_file => 't/confs/unopened.conf'); };
like($@, qr/has no open tag/, 'closed nonexisting container');

eval { Config::Apache->new(config_file => 't/confs/unclosed.conf') };
like($@, qr/not closed by eof/, 'container tag unclosed');

eval { Config::Apache->new(config_file => 't/confs/swapped.conf') };
like($@, qr/does not match start tag/, 'wrong container closing tag');
