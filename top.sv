
`include "uvm_macros.svh"
  import uvm_pkg::*;
  import APB_Pkg::*;
module top;

   logic pclk;
   logic rst_n;
   logic [31:0] paddr;
   logic        psel;
   logic        penable;
   logic        pwrite;
   logic [31:0] prdata;
   logic [31:0] pwdata;
  
   dut_if apb_if();
  
   apb_slave dut(.dif(apb_if));

   initial begin
      apb_if.pclk=0;
   end

    //Generate a clock
   always begin
      #10 apb_if.pclk = ~apb_if.pclk;
   end
 
  initial begin
    apb_if.rst_n=0;
    repeat (1) @(posedge apb_if.pclk);
    apb_if.rst_n=1;
  end
 
  initial begin
    //Pass this physical interface to test top (which will further pass it down to env->agent->drv/sqr/mon
    uvm_config_db#(virtual dut_if)::set( null, "uvm_test_top", "vif", apb_if);
    //Call the test - but passing run_test argument as test class name
    //Another option is to not pass any test argument and use +UVM_TEST on command line to sepecify which test to run
    run_test("apb_base_test");
  end
  
  initial begin
    $dumpfile("dump.vcd");
    $dumpvars;
  end
  
endmodule