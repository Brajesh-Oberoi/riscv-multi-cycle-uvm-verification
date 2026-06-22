class dmem_env extends uvm_env;

  `uvm_component_utils(dmem_env)

  dmem_agent dm_agent;

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction


  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    dm_agent = dmem_agent::type_id::create("dm_agent", this);
  endfunction

endclass
