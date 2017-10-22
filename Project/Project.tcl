################################################
# Shell
################################################

# POINTER TO SHELL RELEASE
set shell_pointer ../../../Shells/Academic
set target_board "MtGranite"
source $shell_pointer/shell_pre.tcl

# Override default shell parameters
setFpgaUserClock 150

setShellParam use_ddr 1
setShellParam use_sl3 0
setShellParam seed_value 6

source $shell_pointer/shell_post.tcl

# Include application-specific RTL
set app_path     "../RTL"
source $app_path/app.tcl

# Include common
set common_path ../../Common
source $common_path/common.tcl

set_global_assignment -name SYSTEMVERILOG_FILE $common_path/NetworkTypes/NetworkTypes.sv
