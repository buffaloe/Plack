use strict;
use Test::More;
use Test::Requires { 'CGI::Emulate::PSGI' => 0, 'CGI::Compile' => 0.03 };
use Plack::Test;
use HTTP::Request::Common;
use Plack::App::CGIBin;

my $app = Plack::App::CGIBin->new(root => "t/Plack-Middleware/cgi-bin")->to_app;

test_psgi app => $app, client => sub {
    my $cb = shift;

    my $res = $cb->(GET "http://localhost/hello.cgi?name=foo");
    is $res->code, 200;
    is $res->content, "Hello foo counter=1";

    $res = $cb->(GET "http://localhost/hello.cgi?name=bar");
    is $res->code, 200;
    is $res->content, "Hello bar counter=2";

    $res = $cb->(GET "http://localhost/hello2.cgi?name=foo");
    is $res->code, 200;
    is $res->content, "Hello foo counter=1";

    $res = $cb->(GET "http://localhost/hello3.cgi");
    my $env = eval $res->content;
    is $env->{SCRIPT_NAME}, '/hello3.cgi';
    is $env->{REQUEST_URI}, '/hello3.cgi';

    $res = $cb->(GET "http://localhost/hello3.cgi/foo%20bar/baz");
    is $res->code, 200;
    $env = eval $res->content || {};
    is $env->{SCRIPT_NAME}, '/hello3.cgi';
    is $env->{PATH_INFO}, '/foo bar/baz';
    is $env->{REQUEST_URI}, '/hello3.cgi/foo%20bar/baz';

    $res = $cb->(GET "http://localhost/hello4.cgi");
    is $res->code, 404;
};

done_testing;
