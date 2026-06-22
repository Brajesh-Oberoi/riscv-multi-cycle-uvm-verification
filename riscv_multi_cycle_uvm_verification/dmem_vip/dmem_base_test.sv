class dmem_base_test extends uvm_test;

  `uvm_component_utils(dmem_base_test)

  dmem_env dm_env;

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction


  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    dm_env = dmem_env::type_id::create("dm_env", this);
  endfunction


  task run_phase(uvm_phase phase);
    super.run_phase(phase);
    phase.raise_objection(this);
    `uvm_info(get_type_name(), $sformatf("Executing dmem_base_test"), UVM_DEBUG)
    #2ms;
    phase.drop_objection(this);
  endtask

endclass
