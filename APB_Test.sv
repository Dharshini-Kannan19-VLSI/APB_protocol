class apb_base_test extends uvm_test;

  `uvm_component_utils(apb_base_test)

  apb_env  env;
  virtual dut_if vif;

  function new(string name="apb_base_test", uvm_component parent=null);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    env = apb_env::type_id::create("env", this);

    if(!uvm_config_db#(virtual dut_if)::get(this, "", "vif", vif)) begin
      `uvm_fatal("build_phase", "No virtual interface specified for this test instance")
    end
    uvm_config_db#(virtual dut_if)::set(this, "env", "vif", vif);
  endfunction

  // 🔹 PRINT UVM TOPOLOGY
  function void end_of_elaboration_phase(uvm_phase phase);
    super.end_of_elaboration_phase(phase);
    uvm_top.print_topology();     // <-- Proper syntax
  endfunction

  task run_phase(uvm_phase phase);
    apb_sequence apb_seq;
    apb_seq = apb_sequence::type_id::create("apb_seq");

    phase.raise_objection(this, "Starting apb_base_seq in main phase");
    $display("%t Starting sequence apb_seq run_phase", $time);

    apb_seq.start(env.agt.sqr);

    #100ns;

    phase.drop_objection(this, "Finished apb_seq in main phase");
  endtask

endclass
