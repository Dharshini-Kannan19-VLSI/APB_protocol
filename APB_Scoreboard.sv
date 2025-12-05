class apb_scoreboard extends uvm_scoreboard;

  `uvm_component_utils(apb_scoreboard)

  // Analysis export to receive transactions from monitor
  uvm_analysis_imp#(apb_transaction, apb_scoreboard) mon_export;

  // Queue to hold incoming transactions
  apb_transaction exp_queue[$];

  // Reference memory for checking DUT
  bit [31:0] sc_mem [0:256];

  // Coverage variables
  bit [31:0] addr;
  bit [31:0] data;

  // Covergroup integrated in scoreboard
  covergroup cover_bus;
    coverpoint addr {
      bins a[16] = {[0:255]};
    }
    coverpoint data {
      bins d[16] = {[0:255]};
    }
  endgroup

  // Constructor
  function new(string name, uvm_component parent);
    super.new(name,parent);
    mon_export = new("mon_export", this);
    cover_bus = new;
  endfunction

  // Build phase: initialize reference memory
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    foreach(sc_mem[i]) sc_mem[i] = i;
  endfunction

  // Write task: called when transaction arrives
  function void write(apb_transaction tr);
    exp_queue.push_back(tr);
  endfunction

  // Run phase: check correctness and sample coverage
  virtual task run_phase(uvm_phase phase);
    apb_transaction expdata;
    forever begin
      wait(exp_queue.size() > 0);
      expdata = exp_queue.pop_front();

      // Update coverage
      addr = expdata.addr;
      data = expdata.data;
      cover_bus.sample();

      // Functional checking
      if(expdata.pwrite == apb_transaction::WRITE) begin
        sc_mem[expdata.addr] = expdata.data;
        `uvm_info("APB_SCOREBOARD", $sformatf("WRITE: Addr=%0h Data=%0h", expdata.addr, expdata.data), UVM_LOW)
      end
      else if(expdata.pwrite == apb_transaction::READ) begin
        if(sc_mem[expdata.addr] == expdata.data) begin
          `uvm_info("APB_SCOREBOARD", $sformatf("READ MATCH: Addr=%0h Data=%0h", expdata.addr, expdata.data), UVM_LOW)
        end
        else begin
          `uvm_error("APB_SCOREBOARD", $sformatf("READ MISMATCH: Addr=%0h Expected=%0h Actual=%0h",
                          expdata.addr, sc_mem[expdata.addr], expdata.data))
        end
      end
    end
  endtask

endclass
