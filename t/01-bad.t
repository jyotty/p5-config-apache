#!/usr/bin/perl

use strict;
use warnings;
use Test::More 'no_plan';
use Test::Exception;

use Config::Apache;

throws_ok { Config::Apache->new(config_file => 't/confs/unopened.conf') }  qr/has no open tag/, 'unopened container';
throws_ok { Config::Apache->new(config_file => 't/confs/unclosed.conf') }  qr/not closed by eof/, 'container tag unclosed';
throws_ok { Config::Apache->new(config_file => 't/confs/swapped.conf') }  qr/does not match start tag/, 'unopened container';
