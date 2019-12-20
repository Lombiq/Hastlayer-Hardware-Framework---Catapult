#
# SDC
#

create_clock -period 150.000MHz [get_ports Clock]

derive_pll_clocks
derive_clock_uncertainty
