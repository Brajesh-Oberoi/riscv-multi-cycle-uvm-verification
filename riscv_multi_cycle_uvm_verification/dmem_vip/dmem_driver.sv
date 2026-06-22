class dmem_driver extends uvm_driver #(dmem_sequence_item);

  `uvm_component_utils(dmem_driver)

  virtual dmem_if dmem_vif;

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction


  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if(!uvm_config_db #(virtual dmem_if)::get(this, "*", "dmem_vif", dmem_vif))
      `uvm_fatal(get_type_name(), "dmem_vif not found")
  endfunction



  task run_phase(uvm_phase phase);
    super.run_phase(phase);
    //seq_item_port.get_next_item(req);
    `uvm_info(get_type_name(), $sformatf("Executing driver run_phase"), UVM_DEBUG)
    forever begin
      dmem_vif.mem_access();
    end

  endtask


endclass
