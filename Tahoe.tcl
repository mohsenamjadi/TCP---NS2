#——-Setting Parameters——–#
set run_time 1000

#——-Event scheduler object creation——–#
set ns [new Simulator]

#———-creating trace objects—————-#
# set tracefile_upper_flow [open upper_flow.tr w]
# $ns trace-all $tracefile_upper_flow

# set tracefile_lower_flow [open lower_flow.tr w]
# $ns trace-all $tracefile_lower_flow

#———-creating nam objects—————-#
set namfile [open Tahoe.nam w]
$ns namtrace-all $namfile

#———- Creating Network—————-#
set totalNodes 6

for {set i 1} {$i <= $totalNodes} {incr i} {
set node_($i) [$ns node]
}

#———- Creating Random Variables—————-#
proc randomGenerator {min max} {
    return [expr {int(rand()*[expr $max - $min + 1] ) + $min}]
}

#———- Creating Duplex Link—————-#
set randomDelay0 [randomGenerator 5 25]
set randomDelay1 [randomGenerator 5 25]

$ns duplex-link $node_(1) $node_(3) 100Mb 5ms DropTail
$ns duplex-link $node_(2) $node_(3) 100Mb [expr $randomDelay0]ms DropTail

$ns duplex-link $node_(3) $node_(4) 100Kb 1ms DropTail

$ns duplex-link $node_(4) $node_(5) 100Mb 5ms DropTail
$ns duplex-link $node_(4) $node_(6) 100Mb [expr $randomDelay1]ms DropTail

# some hints for nam
$ns duplex-link-op $node_(1) $node_(3) orient right-down 
$ns duplex-link-op $node_(2) $node_(3) orient right-up

$ns duplex-link-op $node_(3) $node_(4) orient right

$ns duplex-link-op $node_(4) $node_(5) orient right-up
$ns duplex-link-op $node_(4) $node_(6) orient right-down

$ns duplex-link-op $node_(3) $node_(4) queuePos 0.5
#————Queue Size—————-#
$ns queue-limit $node_(1) $node_(3) 10
$ns queue-limit $node_(2) $node_(3) 10
$ns queue-limit $node_(3) $node_(4) 10
$ns queue-limit $node_(4) $node_(5) 10
$ns queue-limit $node_(4) $node_(6) 10

# Create TCP sending agent and attach it
set tcp0 [new Agent/TCP]
$tcp0 set class_ 0
$tcp0 set ttl_ 64
$ns attach-agent $node_(1) $tcp0
# color packets of flow 0 red
$ns color 0 Red


set tcp1 [new Agent/TCP]
$tcp1 set class_ 1
$tcp1 set ttl_ 64
$ns attach-agent $node_(2) $tcp1
# color packets of flow 1 blue
$ns color 1 Blue

# Let's trace some variables
# $tcp0 attach $tracefile_upper_flow
# $tcp0 tracevar cwnd_
# $tcp0 tracevar ssthresh_
# $tcp0 tracevar ack_
# $tcp0 tracevar maxseq_

# $tcp1 attach $tracefile_lower_flow
# $tcp1 tracevar cwnd_
# $tcp1 tracevar ssthresh_
# $tcp1 tracevar ack_
# $tcp1 tracevar maxseq_

#Create TCP receive agent (traffic sink) and attach it
set end0 [new Agent/TCPSink]
$ns attach-agent $node_(5) $end0


set end1 [new Agent/TCPSink]
$ns attach-agent $node_(6) $end1

#Connect the traffic source with the traffic sink
$ns connect $tcp0 $end0


$ns connect $tcp1 $end1

# procedure to plot the congestion window
proc plotWindow {tcpSource outfile} {
	global ns
	set now [$ns now]
	set cwnd [$tcpSource set cwnd_]

	# the data is recorded in a file called congestion.xg (this can be plotted # using xgraph or gnuplot. this example uses xgraph to plot the cwnd_
	puts  $outfile  "$now $cwnd"
	$ns at [expr $now+0.1] "plotWindow $tcpSource  $outfile"
}

proc plotThroughput {tcpSink outfile} {
  global ns

  set now [$ns now]				;# Read current time

  set nbytes [$tcpSink set bytes_]		;# Read number of bytes

  $tcpSink set bytes_ 0			;# Reset for next epoch
  set time_incr 1.0

### Prints "TIME throughput" in Mb/sec units to output file
  set throughput [expr ($nbytes * 8.0 / 1000000) / $time_incr]
  puts  $outfile  "$now $throughput"

### Schedule yourself:
  $ns at [expr $now+$time_incr] "plotThroughput $tcpSink  $outfile"
}

proc bandwidthRecorder {tcpSink outfile} {
global ns

#Set the time after which the procedure should be called again
set time 0.5
#How many bytes have been received by the traffic sinks?
set bw1 [$tcpSink set bytes_]
#Get the current time
set now [$ns now]
#Calculate the bandwidth (in MBit/s) and write it to the files
puts $outfile "$now [expr $bw1/$time*8/1000000]"
#Reset the bytes_ values on the traffic sinks
$tcpSink set bytes_ 0
#Re-schedule the procedure
$ns at [expr $now+$time] "bandwidthRecorder $tcpSink 	$outfile"
}

proc rttRecorder {tcpSource outfile} {
global ns

set time 0.5

set rtt [$tcpSource set cwnd_]

set now [$ns now]

puts $outfile "$now $rtt]"

$ns at [expr $now+$time] "rttRecorder $tcpSource 	$outfile"
}

#Schedule the connection data flow; start sending data at T=0, stop at T=$run_time
set myftp0 [new Application/FTP]
set myftp1 [new Application/FTP]
set outfile_cwnd_upper_flow [open  "outputs/Tahoe_cwnd_upper_flow.xg"  w]
set outfile_cwnd_lower_flow [open  "outputs/Tahoe_cwnd_lower_flow.xg"  w]
set outfile_goodput_upper_flow [open  "outputs/Tahoe_goodput_upper_flow.xg"  w]
set outfile_goodput_lower_flow [open  "outputs/Tahoe_goodput_lower_flow.xg"  w]
set outfile_packetLoss_upper_flow [open  "outputs/Tahoe_packetLoss_upper_flow.xg"  w]
set outfile_packetLoss_lower_flow [open  "outputs/Tahoe_packetLoss_lower_flow.xg"  w]
set outfile_rtt_upper_flow [open  "outputs/Tahoe_rtt_upper_flow.xg"  w]
set outfile_rtt_lower_flow [open  "outputs/Tahoe_rtt_lower_flow.xg"  w]

$myftp0 attach-agent $tcp0
$myftp1 attach-agent $tcp1
$ns at 0.0 "$myftp0 start"
$ns at 0.0 "$myftp1 start"
$ns  at  0.0  "plotWindow $tcp0  $outfile_cwnd_upper_flow"
$ns  at  0.0  "plotWindow $tcp1  $outfile_cwnd_lower_flow"
$ns  at  0.0  "plotThroughput $end0	$outfile_goodput_upper_flow"
$ns  at  0.0  "plotThroughput $end1	$outfile_goodput_lower_flow"
$ns  at  0.0  "bandwidthRecorder $end0	$outfile_packetLoss_upper_flow"
$ns  at  0.0  "bandwidthRecorder $end1	$outfile_packetLoss_lower_flow"
$ns  at  0.0  "rttRecorder $tcp0	$outfile_rtt_upper_flow"
$ns  at  0.0  "rttRecorder $tcp1	$outfile_rtt_lower_flow"

$ns at $run_time "$myftp0 stop"
$ns at $run_time "$myftp1 stop"
$ns at [expr $run_time + 0.5] "finish"

#———finish procedure——–#
proc finish {} {
# global ns namfile tracefile_upper_flow tracefile_lower_flow
global ns namfile outfile_cwnd_upper_flow outfile_cwnd_lower_flow outfile_goodput_upper_flow outfile_goodput_lower_flow outfile_packetLoss_upper_flow outfile_packetLoss_lower_flow outfile_rtt_upper_flow outfile_rtt_lower_flow 
$ns flush-trace
close $namfile
close $outfile_cwnd_upper_flow
close $outfile_cwnd_lower_flow
close $outfile_goodput_upper_flow
close $outfile_goodput_lower_flow
close $outfile_packetLoss_upper_flow
close $outfile_packetLoss_lower_flow
close $outfile_rtt_upper_flow
close $outfile_rtt_lower_flow
# close $tracefile_upper_flow
# close $tracefile_lower_flow
exec nam Tahoe.nam &
# exec xgraph congestion.xg -geometry 300x300 &
exit 0
}

#——— Execution ——–#
$ns run
