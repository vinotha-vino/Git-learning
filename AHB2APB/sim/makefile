verb = UVM_HIGH
t = base_test
s = 1
cvg = base_test



allc: clean init compile runc

all: clean init compile run

clean:
	rm -rf transcript vsim.wlf work compile.log

init:
	vlib work;

compile: clean init
	vlog \
	+incdir+/cadtools/questasim/verilog_src/uvm-1.1d/src \
	+incdir+../rtl \
	+incdir+../sv \
	+cover \
	../sv/tb_top.sv ; 

runc: clean init compile
	rm -rf $t
	vsim -lic_noqueue -c -l  $t.log -coverage -sv_seed random -do "coverage save -onexit $t.ucdb; run -all; exit" \
	+TEST_NAME=$t \
	-voptargs="+acc" tb_top ;

run: clean init compile
	vsim -lic_noqueue -l $t.log  -do "run -all; exit" \
	+UVM_VERBOSITY=$(verb) \
	+TEST_NAME=$t \
	-voptargs="+acc" tb_top ;

gen_cvg_vsim: 
	vsim -cvgperinstance -viewcov $(cvg).ucdb -do "coverage report -file report.txt -byfile -detail -noannotate -option -cvg"

gen_cvg_html:
	vcover report -details -html $(cvg).ucdb

