package MySQL::Benchmark::IPC::Server;

use 5.006;
use strict;
use warnings FATAL => 'all';

use IO::Socket;
use File::Temp ();

=head1 NAME

MySQL::Benchmark::IPC::Server – a UDP listener for Benchmark results IPC.

=head1 VERSION

=head1 SYNOPSYS

=head1 DESCRIPTION

=head1 METHODS

=head2 new

Constructor.

Takes an optional "port" argument. If unset, port defaults to 2020.
Takes an optional "max_lenght" argument. If unset, defaults to 4096.

=cut

sub new {
    my ( $class, %self ) = @_;

    # Defaults
    $self{max_length} = 4096;

    my $self = bless \%self, $class;

    $self->initialise_socket;
    return $self;
}

=head2 initialise_socket

Opens a socket to listen on.

=cut

sub initialise_socket {
    my ($self) = @_;
    $$self{socket_file} ||= File::Temp::mktemp( '/tmp/mysql-benchmark-socket.XXXXXX' );
    unlink $$self{socket_file} if -e $$self{socket_file};
    my $sock = IO::Socket::UNIX->new(
        Local => $$self{socket_file},
        Type  => SOCK_DGRAM,
    );
    die qq{Cannot create socket: $!.} unless $sock;
    $$self{SOCKET} = $sock;
}

=head2 socket_file

Returns the filename used as socket for this server.

=cut

sub socket_file { my ($self) = @_; return $$self{socket_file}; }

=head2 receive

Attempts to receive a message.

=cut

sub receive {
    my ($self) = @_;
    my $message;
    $$self{SOCKET}->recv( $message, $$self{max_length} );
    return $message;
}

1;    # End of MySQL::Benchmark::IPC::Server
