class dmem_agent extends uvm_agent;

  `uvm_component_utils(dmem_agent)

  dmem_driver dm_driver;

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction


  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    dm_driver = dmem_driver::type_id::create("dm_driver", this);
  endfunction

endclass
