#!./perl

$| = 1;
print "1..5\n";

use IO::Socket;

$port = 4002 + int(rand(time) & 0xff);

$pid =  fork();

if($pid) {

    $listen = IO::Socket::INET->new(Listen => 2,
				    Proto => 'tcp',
				    LocalPort => $port
				   ) or die "$!";

    print "ok 1\n";

    # Wake out child
    kill(ALRM => $pid);

    $sock = $listen->accept();
    print "ok 2\n";

    $sock->autoflush(1);
    print $sock->getline();

    print $sock "ok 4\n";

    $sock->close;

    waitpid($pid,0);

    print "ok 5\n";
} elsif(defined $pid) {

    # Wait for a small pause, so that we can ensure the listen socket is setup
    # the parent will awake us with a SIGALRM

    $SIG{ALRM} = sub {};
    sleep(10);

    $sock = IO::Socket::INET->new(PeerPort => $port,
				  Proto => 'tcp',
				  PeerAddr => 'localhost'
				 ) or die "$!";

    $sock->autoflush(1);
    print $sock "ok 3\n";
    print $sock->getline();
    $sock->close;
    exit;
} else {
 die;
}





