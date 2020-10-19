gnuplot -persist <<-EOFMarker
plot "outputs/Newreno_cwnd_upper_flow.xg", \
	"outputs/Newreno_cwnd_lower_flow.xg", \
	"outputs/Tahoe_cwnd_upper_flow.xg", \
	"outputs/Tahoe_cwnd_lower_flow.xg", \
	"outputs/Vegas_cwnd_upper_flow.xg", \
	"outputs/Vegas_cwnd_lower_flow.xg"
EOFMarker

gnuplot -persist <<-EOFMarker
plot "outputs/Newreno_goodput_upper_flow.xg", \
	"outputs/Newreno_goodput_lower_flow.xg", \
	"outputs/Tahoe_goodput_upper_flow.xg", \
	"outputs/Tahoe_goodput_lower_flow.xg", \
	"outputs/Vegas_goodput_upper_flow.xg", \
	"outputs/Vegas_goodput_lower_flow.xg"
EOFMarker

gnuplot -persist <<-EOFMarker
plot "outputs/Newreno_packetLoss_upper_flow.xg", \
	"outputs/Newreno_packetLoss_lower_flow.xg", \
	"outputs/Tahoe_packetLoss_upper_flow.xg", \
	"outputs/Tahoe_packetLoss_lower_flow.xg", \
	"outputs/Vegas_packetLoss_upper_flow.xg", \
	"outputs/Vegas_packetLoss_lower_flow.xg"
EOFMarker

gnuplot -persist <<-EOFMarker
plot "outputs/Newreno_rtt_upper_flow.xg", \
"outputs/Newreno_rtt_lower_flow.xg", \
"outputs/Tahoe_rtt_upper_flow.xg", \
"outputs/Tahoe_rtt_lower_flow.xg", \
"outputs/Vegas_rtt_upper_flow.xg", \
"outputs/Vegas_rtt_lower_flow.xg"
EOFMarker