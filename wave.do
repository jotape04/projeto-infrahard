onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -radix unsigned /cpu_add/PC_/Saida
add wave -noupdate -radix decimal /cpu_add/Regs_/Cluster(15)
add wave -noupdate -radix decimal /cpu_add/Regs_/Cluster(20)
add wave -noupdate -radix decimal /cpu_add/Regs_/Cluster(25)
add wave -noupdate -radix unsigned /cpu_add/Ctrl_/OPCODE
add wave -noupdate -radix unsigned /cpu_add/Ctrl_/STATE
add wave -noupdate -radix unsigned /cpu_add/Ctrl_/COUNTER
add wave -noupdate /cpu_add/clk
add wave -noupdate /cpu_add/reset
add wave -noupdate /cpu_add/Ctrl_/PC_Write
add wave -noupdate /cpu_add/Ctrl_/PCSource
add wave -noupdate -radix decimal /cpu_add/ULA_/S
add wave -noupdate -radix decimal /cpu_add/MuxPC_/PC_in
add wave -noupdate /cpu_add/MuxPC_/RES
add wave -noupdate /cpu_add/MuxPC_/sel
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {4 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 197
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 0
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ps
update
WaveRestoreZoom {0 ps} {909 ps}
view wave 
wave clipboard store
wave create -driver freeze -pattern clock -initialvalue HiZ -period 100ps -dutycycle 50 -starttime 0ps -endtime 10000ps sim:/cpu_add/clk 
wave create -driver freeze -pattern constant -value 0 -starttime 0ps -endtime 10000ps sim:/cpu_add/reset 
wave edit change_value -start 0ps -end 100ps -value 1 Edit:/cpu_add/reset 
WaveCollapseAll -1
wave clipboard restore
