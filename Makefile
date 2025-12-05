# SIMULATOR = Questa for Mentor's QuestaSim
# SIMULATOR = VCS for Synopsys's VCS

SIMULATOR = Questa

RTL        = ../rtl/*
INC        = +incdir+../master +incdir+../test +incdir+../packages +incdir+../env
work       = work   # library name
SVTB1      = ../env/top.sv
SVTB2      = ../test/APB_Pkg.sv
COVOP      = -coverage +cover=bcft
VSIMOPT    = -vopt -voptargs=+acc
VSIMCOV    = $(COVOP)
VSIMBATCH  = -c -do "log -r /* ; coverage save -onexit apb_base_test_cov0; run -all; exit"

help:
	@echo "================================================================================="
	@echo "! USAGE      --  make target                                                    !"
	@echo "! clean      =>  clean the earlier log and intermediate files.                  !"
	@echo "! sv_cmp     =>  Create library and compile the code.                           !"
	@echo "! run_test1  =>  Clean, compile & run the apb_base_test in batch mode.      !"
	@echo "! view_wave1 =>  View waveform                                !"
	@echo "! cov        =>  open Coverage report                                !"
	@echo "================================================================================="

clean       : clean_$(SIMULATOR)
sv_cmp      : sv_cmp_$(SIMULATOR)
run_test1   : run_test1_$(SIMULATOR)
view_wave1  : view_wave1_$(SIMULATOR)
regress_12  : regress_12_$(SIMULATOR)
cov         : cov_$(SIMULATOR)

# ====================================================
# QuestaSim specific commands
# ====================================================

sv_cmp_Questa:
	vlib $(work)
	vmap work $(work)
	vlog -work $(work) $(RTL) $(INC) $(SVTB2) $(SVTB1)

run_test1_Questa: sv_cmp
	vsim $(VSIMOPT) $(VSIMCOV) $(VSIMBATCH) -wlf wave_file1.wlf -l test1.log -sv_seed random work.top +UVM_TESTNAME=apb_base_test
	vcover report -cvg -details -nocompactcrossbins -codeAll -assert -directive -html apb_base_test_cov0

view_wave1_Questa:
	vsim -view wave_file1.wlf

report_12_Questa:
	vcover merge -out axi_cov apb_base_test_cov0
	vcover report -cvg -details -nocompactcrossbins -codeAll -assert -directive -html apb_base_test_cov

regress_12_Questa: clean_Questa sv_cmp_Questa run_test1_Questa report_12_Questa

cov_Questa:
	firefox covhtmlreport/index.html &

clean_Questa:
	rm -rf transcript* .log vsim.wlf fcover covhtml* cov *.wlf modelsim.ini work