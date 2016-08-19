#!/usr/bin/perl

use strict;
use warnings;
use IO::Handle;
my $conf = {};

# Read the 'ip addr'
my $device      = "";
my $mac_address = "";
my $file_handle = IO::Handle->new();
my $shell_call  = "ip addr";

open ($file_handle, "$shell_call 2>&1 |") or die "Failed to call: [$shell_call], error: $!\n";
while (<$file_handle>)
{
	chomp;
	my $line = $_;
	if ($line =~ /^\d+: (\S+):/)
	{
		$device = $1;
		next if $device eq "lo";
		$mac_address = "";
		next;
	}
	if ($line =~ /ether (.*?) /)
	{
		$mac_address = $1;
		next if not $device;
		$conf->{$device} = $mac_address;
	}
}

my $i = 0;

foreach my $device (sort {$a cmp $b} keys %{$conf})
{
	# my $say_dev = lc($device);
	my $say_dev = 'eth' . '' . $i;
	my $say_mac = lc($conf->{$device});
	print "\n# Added by 'generate-udev-net' for detected device '$device'.\n";
	print "SUBSYSTEM==\"net\", ACTION==\"add\", DRIVERS==\"?*\", ATTR{address}==\"$say_mac\", NAME=\"$say_dev\"\n";

    my $filename = '/etc/sysconfig/network-scripts/ifcfg-' . '' . $device;

    my $data = read_file($filename);
    $data =~ s/$device/$say_dev/g;
    write_file($filename, $data);

    sub read_file {
        my ($filename) = @_;

        open my $in, '<:encoding(UTF-8)', $filename or die "Could not open '$filename' for reading $!";
        local $/ = undef;
        my $all = <$in>;
        close $in;

        return $all;
    }

    sub write_file {
        my ($filename, $content) = @_;

        open my $out, '>:encoding(UTF-8)', $filename or die "Could not open '$filename' for writing $!";;
        print $out $content;
        close $out;

        return;
    }

	$i += 1

}

exit(0);