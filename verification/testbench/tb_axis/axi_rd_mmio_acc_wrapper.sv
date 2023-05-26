// Copyright 2021 Intel Corporation
// SPDX-License-Identifier: MIT

// Description : AXI MMIO Access Wrapper

`ifndef  AXI_MMIO_ACCESS_WRAPPER
`define  AXI_MMIO_ACCESS_WRAPPER

`uvm_analysis_imp_decl(_wr_rd)

class axi_mmio_access_wrapper extends uvm_component;
 
string msgid;
 uvm_analysis_imp_wr_rd #(`AXI_TRANSACTION_CLASS ,axi_mmio_access_wrapper) axi_mmio_wr_rd;
 virtual axi_wrapper_if axi_wrapper_if;
`AXI_TRANSACTION_CLASS  wr_que[$],rd_que[$];
bit [7:0] cfg_ram[bit [17:0]];
bit [2047:0] mmio_read_q[int];
bit [9:0] mmio_length_q[int];
bit [15:0] req_id;
int send_response;
int sop;
bit [9:0] cfg_len;
bit [15:0] cfg_addr;
bit cfg_wr_rd;
int eop;
int valid1;
int valid2;
int count;
bit [2047:0] datao;
`uvm_component_utils(axi_mmio_access_wrapper)



function new(string name, uvm_component parent);
super.new(name,parent);
msgid = get_type_name();
endfunction:new


function void build_phase(uvm_phase phase);
super.build_phase(phase);
axi_mmio_wr_rd = new("axi_mmio_wr_rd",this);
if(!uvm_config_db#(virtual axi_wrapper_if)::get(this,"","axi_wrapper_if",axi_wrapper_if)) begin
`uvm_error(msgid,"Unable to get virtual interface in wrapper module");
end
endfunction:build_phase


virtual task reset_phase(uvm_phase phase);
phase.raise_objection(this);

     axi_wrapper_if.axi_wrapper_mport.tvalid <= 1'b0;
     axi_wrapper_if.axi_wrapper_mport.tdata <= '0;
     axi_wrapper_if.axi_wrapper_mport.tstrb <= '0;
     axi_wrapper_if.axi_wrapper_mport.tdest <= '0;
     axi_wrapper_if.axi_wrapper_mport.tkeep <= '0;
     axi_wrapper_if.axi_wrapper_mport.tlast <= '0;
     axi_wrapper_if.axi_wrapper_mport.tid   <= '0;
     axi_wrapper_if.axi_wrapper_mport.tuser <= '0;

phase.drop_objection(this);

endtask: reset_phase



virtual function void write_wr_rd(`AXI_TRANSACTION_CLASS trans);
trans.print();
if((trans.tdata[0][1] == 1) || (count != 0)) begin
if(trans.tdata[0][1] == 1) cfg_wr_rd = trans.tdata[0][134];
if(trans.tdata[0][1] == 1) cfg_addr = trans.tdata[0][55:40];
if (trans.tdata[0][1] == 1) cfg_len = trans.tdata[0][113:104];
if(cfg_wr_rd == 1) begin  //Write
 wr_que.push_back(trans);
 sop = 1;
 case(cfg_len) 
 'h1,'h2,'h4,'h8: begin
                  update_cfg_ram(cfg_addr,cfg_len,trans.tdata[0][391:136]); // addr,length,data
                  eop = 2;
                  valid1 = 0;
                  end
 'h10: begin
          update_cfg_ram(cfg_addr,cfg_len,{trans.tdata[0][783:528],trans.tdata[0][391:136]}); // addr,length,data
                  eop = 394;
                  valid1 = 0;
                  valid2 = 392;
       
       end
 'h20: begin
          if(trans.tdata[0][394] == 0) count++;
          else count = 0;
          update_cfg_ram(cfg_addr,cfg_len,{trans.tdata[0][783:528],trans.tdata[0][391:136]}); // addr,length,data
                  eop = 394;
                  valid1 = 0;
                  valid2 = 392;
       
       end
  'h40: begin
          if(trans.tdata[0][394] == 0) count++;
          else count = 0;
          update_cfg_ram(cfg_addr,cfg_len,{trans.tdata[0][783:528],trans.tdata[0][391:136]}); // addr,length,data
                  eop = 394;
                  valid1 = 0;
                  valid2 = 392;
       
       end
 

 endcase

end
else if(cfg_wr_rd == 0) begin  //Read
 rd_que.push_back(trans);
 if(mmio_read_q.exists(trans.tdata[0][87:80])) begin
   `uvm_error(msgid,$sformatf("TID Mismatch with pending MMIO READ: ADDR: %x READ_LENGTH: %x TID: %x",trans.tdata[0][55:40],trans.tdata[0][113:104],trans.tdata[0][87:80]));
 end
   req_id = trans.tdata[0][103:88]; 
   mmio_read_q[trans.tdata[0][87:80]]=get_cfg_data(trans.tdata[0][55:40],trans.tdata[0][113:104]);
   mmio_length_q[trans.tdata[0][87:80]]=trans.tdata[0][113:104];
end
end // sop
else if((trans.tdata[0][393] == 1) || (count != 0)) begin
if(trans.tdata[0][393] == 1) cfg_wr_rd = trans.tdata[0][526];
if(trans.tdata[0][393] == 1) cfg_addr = trans.tdata[0][447:432];
if (trans.tdata[0][393] == 1) cfg_len = trans.tdata[0][563:504];
if(cfg_wr_rd == 1) begin  //Write
 wr_que.push_back(trans);
 sop = 393;
  case(trans.tdata[0][563:504]) 
 'h1,'h2,'h4,'h8: begin
                  update_cfg_ram(cfg_addr,cfg_len,trans.tdata[0][783:528]); // addr,length,data
                  eop = 394;
                  valid1 = 392;
                  end
 'h10: begin
          update_cfg_ram(cfg_addr,cfg_len,{trans.tdata[0][391:136],trans.tdata[0][783:528]}); // addr,length,data
                  eop = 2;
                  valid1 = 0;
                  valid2 = 392;
       
       end
  'h20: begin
         if(trans.tdata[0][2] == 0) count++;
          else count = 0;
          update_cfg_ram(cfg_addr,cfg_len,{trans.tdata[0][391:136],trans.tdata[0][783:528]}); // addr,length,data
                  eop = 2;
                  valid1 = 0;
                  valid2 = 392;
       
       end
  'h40: begin
          if(trans.tdata[0][2] == 0) count++;
          else count = 0;
          update_cfg_ram(cfg_addr,cfg_len,{trans.tdata[0][391:136],trans.tdata[0][783:528]}); // addr,length,data
                  eop = 2;
                  valid1 = 0;
                  valid2 = 392;
       
       end


 endcase

end
else if(cfg_wr_rd == 0) begin  //Read
 rd_que.push_back(trans);
 if(mmio_read_q.exists(trans.tdata[0][479:472])) begin
   `uvm_error(msgid,$sformatf("TID Mismatch with pending MMIO READ: ADDR: %x READ_LENGTH: %x TID: %x",trans.tdata[0][447:432],trans.tdata[0][563:504],trans.tdata[0][479:472]));
 end
   req_id = trans.tdata[0][495:480]; 
   mmio_read_q[trans.tdata[0][479:472]]=get_cfg_data(trans.tdata[0][447:432],trans.tdata[0][563:504]);
   mmio_length_q[trans.tdata[0][479:472]]=trans.tdata[0][563:504];
end


end //sop
endfunction


virtual task run();

   fork
      mmio_thread();
   join

endtask : run

virtual task mmio_thread();
      
    fork
         begin
            forever mmio_read_rsp_thread();
         end

        begin
            forever mmio_reset_thread();
        end

    join

endtask: mmio_thread

virtual task mmio_read_rsp_thread();
int index;
int limit;
bit [127:0] header;
bit [2047:0] payload;

        @(posedge axi_wrapper_if.clk);
  

    if(mmio_read_q.size) begin 
      axi_wrapper_if.axi_wrapper_mport.tvalid <= 1'b1;
      send_response = 1;
    end
    else  begin
      axi_wrapper_if.axi_wrapper_mport.tvalid <= 1'b0;
      send_response = 0;
    end

      if((axi_wrapper_if.axi_wrapper_mport.tready == 1) && (send_response == 1)) begin

            if(mmio_read_q.size>2) 
                index=pick_rand(mmio_read_q);
            else 
                mmio_read_q.first(index);

   if(sop == 1) begin    
      
           
          header = 128'h0;
            payload = mmio_read_q[index];
            header[47:40] = index[7:0];
          //  header[75:64] =  12'h4;
            header[75:64] =  mmio_length_q[index] << 2;
          //  header[105:96] = 10'h1;
            header[105:96] = mmio_length_q[index];
            header[63:48] = req_id;
            header[95:80] = 16'h0100;         
            header[126:120] = 7'b100_1010;// FMT - Cpl with 32 Bit Data

 
    case(mmio_length_q[index])
   
     'h1,'h2,'h4,'h8: begin
            
 
          //  axi_wrapper_if.axi_wrapper_mport.tvalid <= 1'b1;
            axi_wrapper_if.axi_wrapper_mport.tdata  <= {payload[255:0],header,5'h0,1'b1,1'b1,1'b1};
            axi_wrapper_if.axi_wrapper_mport.tstrb <= '1;
            axi_wrapper_if.axi_wrapper_mport.tkeep <= '1;
            axi_wrapper_if.axi_wrapper_mport.tlast <= '1;
            @(posedge axi_wrapper_if.clk);
            axi_wrapper_if.axi_wrapper_mport.tvalid <= 1'b0;
            axi_wrapper_if.axi_wrapper_mport.tdata[valid1] <= 1'b0;  //valid
            axi_wrapper_if.axi_wrapper_mport.tdata[eop] <= 1'b0;  //eop
            mmio_read_q.delete(index);
            send_response = 0;
       end //1,2,4,8
      'h10: begin
 
          //  axi_wrapper_if.axi_wrapper_mport.tvalid <= 1'b1;
            axi_wrapper_if.axi_wrapper_mport.tdata  <= {payload[511:256],header,5'h0,1'b1,1'b0,1'b1,payload[255:0],header,5'b0,1'b0,1'b1,1'b1};
            axi_wrapper_if.axi_wrapper_mport.tstrb <= '1;
            axi_wrapper_if.axi_wrapper_mport.tkeep <= '1;
            axi_wrapper_if.axi_wrapper_mport.tlast <= '1;
            @(posedge axi_wrapper_if.clk);
            axi_wrapper_if.axi_wrapper_mport.tvalid <= 1'b0;
            axi_wrapper_if.axi_wrapper_mport.tdata[valid1] <= 1'b0;  //valid
            axi_wrapper_if.axi_wrapper_mport.tdata[valid2] <= 1'b0;  //valid
            axi_wrapper_if.axi_wrapper_mport.tdata[eop] <= 1'b0;  //eop
            mmio_read_q.delete(index);
            send_response = 0;
    
       end // 10
       'h20: begin
 
          //  axi_wrapper_if.axi_wrapper_mport.tvalid <= 1'b1;
            axi_wrapper_if.axi_wrapper_mport.tdata  <= {payload[511:256],header,5'h0,1'b0,1'b0,1'b1,payload[255:0],header,5'b0,1'b0,1'b1,1'b1};
            axi_wrapper_if.axi_wrapper_mport.tstrb <= '1;
            axi_wrapper_if.axi_wrapper_mport.tkeep <= '1;
            axi_wrapper_if.axi_wrapper_mport.tlast <= '1;
            @(posedge axi_wrapper_if.clk);
            axi_wrapper_if.axi_wrapper_mport.tdata  <= {payload[1023:768],header,5'h0,1'b1,1'b0,1'b1,payload[767:512],header,5'b0,1'b0,1'b0,1'b1};
            @(posedge axi_wrapper_if.clk);
            axi_wrapper_if.axi_wrapper_mport.tvalid <= 1'b0;
            axi_wrapper_if.axi_wrapper_mport.tdata[valid1] <= 1'b0;  //valid
            axi_wrapper_if.axi_wrapper_mport.tdata[valid2] <= 1'b0;  //valid
            axi_wrapper_if.axi_wrapper_mport.tdata[eop] <= 1'b0;  //eop
            mmio_read_q.delete(index);
            send_response = 0;
    
       end // 20
       'h40: begin
 
          //  axi_wrapper_if.axi_wrapper_mport.tvalid <= 1'b1;
            axi_wrapper_if.axi_wrapper_mport.tdata  <= {payload[511:256],header,5'h0,1'b0,1'b0,1'b1,payload[255:0],header,5'b0,1'b0,1'b1,1'b1};
            axi_wrapper_if.axi_wrapper_mport.tstrb <= '1;
            axi_wrapper_if.axi_wrapper_mport.tkeep <= '1;
            axi_wrapper_if.axi_wrapper_mport.tlast <= '1;
            @(posedge axi_wrapper_if.clk);
            axi_wrapper_if.axi_wrapper_mport.tdata  <= {payload[1023:768],header,5'h0,1'b0,1'b0,1'b1,payload[767:512],header,5'b0,1'b0,1'b0,1'b1};
            @(posedge axi_wrapper_if.clk);
             axi_wrapper_if.axi_wrapper_mport.tdata  <= {payload[1535:1280],header,5'h0,1'b0,1'b0,1'b1,payload[1279:1024],header,5'b0,1'b0,1'b0,1'b1};
            @(posedge axi_wrapper_if.clk); 
             axi_wrapper_if.axi_wrapper_mport.tdata  <= {payload[2047:1792],header,5'h0,1'b1,1'b0,1'b1,payload[1791:1536],header,5'b0,1'b0,1'b0,1'b1};
            @(posedge axi_wrapper_if.clk);
            axi_wrapper_if.axi_wrapper_mport.tvalid <= 1'b0;
            axi_wrapper_if.axi_wrapper_mport.tdata[valid1] <= 1'b0;  //valid
            axi_wrapper_if.axi_wrapper_mport.tdata[valid2] <= 1'b0;  //valid
            axi_wrapper_if.axi_wrapper_mport.tdata[eop] <= 1'b0;  //eop
            mmio_read_q.delete(index);
            send_response = 0;
    
       end // 40


     endcase
    end // sop
    else if (sop == 393) begin

         header = 128'h0;
            payload = mmio_read_q[index];
            header[439:432] = index[7:0];
          //  header[75:64] =  12'h4;
            header[467:456] =  mmio_length_q[index] << 2;
          //  header[105:96] = 10'h1;
            header[497:488] = mmio_length_q[index];
            header[455:440] = req_id;
            header[487:472] = 16'h0100;         
            header[518:512] = 7'b100_1010;// FMT - Cpl with 32 Bit Data


     case(mmio_length_q[index])
   
     'h1,'h2,'h4,'h8: begin
            
 
          //  axi_wrapper_if.axi_wrapper_mport.tvalid <= 1'b1;
            axi_wrapper_if.axi_wrapper_mport.tdata[783:392]  <= {payload[255:0],header,5'h0,1'b1,1'b1,1'b1};
            axi_wrapper_if.axi_wrapper_mport.tstrb <= '1;
            axi_wrapper_if.axi_wrapper_mport.tkeep <= '1;
            axi_wrapper_if.axi_wrapper_mport.tlast <= '1;
            @(posedge axi_wrapper_if.clk);
            axi_wrapper_if.axi_wrapper_mport.tvalid <= 1'b0;
            axi_wrapper_if.axi_wrapper_mport.tdata[valid1] <= 1'b0;  //valid
            axi_wrapper_if.axi_wrapper_mport.tdata[eop] <= 1'b0;  //eop
            mmio_read_q.delete(index);
            send_response = 0;
       end //1,2,4,8
      'h10: begin

 
          //  axi_wrapper_if.axi_wrapper_mport.tvalid <= 1'b1;
            axi_wrapper_if.axi_wrapper_mport.tdata  <= {payload[511:256],header,5'h0,1'b0,1'b1,1'b1,payload[255:0],header,5'h0,1'b1,1'b0,1'b1};
            axi_wrapper_if.axi_wrapper_mport.tstrb <= '1;
            axi_wrapper_if.axi_wrapper_mport.tkeep <= '1;
            axi_wrapper_if.axi_wrapper_mport.tlast <= '1;
            @(posedge axi_wrapper_if.clk);
            axi_wrapper_if.axi_wrapper_mport.tvalid <= 1'b0;
            axi_wrapper_if.axi_wrapper_mport.tdata[valid1] <= 1'b0;  //valid
            axi_wrapper_if.axi_wrapper_mport.tdata[valid2] <= 1'b0;  //valid
            axi_wrapper_if.axi_wrapper_mport.tdata[eop] <= 1'b0;  //eop
            mmio_read_q.delete(index);
            send_response = 0;
    
       end // 10
      'h20: begin
 
          //  axi_wrapper_if.axi_wrapper_mport.tvalid <= 1'b1;
            axi_wrapper_if.axi_wrapper_mport.tdata  <= {payload[511:256],header,5'h0,1'b0,1'b0,1'b1,payload[255:0],header,5'b0,1'b0,1'b1,1'b1};
            axi_wrapper_if.axi_wrapper_mport.tstrb <= '1;
            axi_wrapper_if.axi_wrapper_mport.tkeep <= '1;
            axi_wrapper_if.axi_wrapper_mport.tlast <= '1;
            @(posedge axi_wrapper_if.clk);
            axi_wrapper_if.axi_wrapper_mport.tdata  <= {payload[1023:768],header,5'h0,1'b1,1'b0,1'b1,payload[767:512],header,5'b0,1'b0,1'b0,1'b1};
            @(posedge axi_wrapper_if.clk);
            axi_wrapper_if.axi_wrapper_mport.tvalid <= 1'b0;
            axi_wrapper_if.axi_wrapper_mport.tdata[valid1] <= 1'b0;  //valid
            axi_wrapper_if.axi_wrapper_mport.tdata[valid2] <= 1'b0;  //valid
            axi_wrapper_if.axi_wrapper_mport.tdata[eop] <= 1'b0;  //eop
            mmio_read_q.delete(index);
            send_response = 0;
    
       end // 20
       'h40: begin
 
          //  axi_wrapper_if.axi_wrapper_mport.tvalid <= 1'b1;
            axi_wrapper_if.axi_wrapper_mport.tdata  <= {payload[511:256],header,5'h0,1'b1,1'b0,1'b1,payload[255:0],header,5'b0,1'b0,1'b1,1'b1};
            axi_wrapper_if.axi_wrapper_mport.tstrb <= '1;
            axi_wrapper_if.axi_wrapper_mport.tkeep <= '1;
            axi_wrapper_if.axi_wrapper_mport.tlast <= '1;
            @(posedge axi_wrapper_if.clk);
            axi_wrapper_if.axi_wrapper_mport.tdata  <= {payload[1023:768],header,5'h0,1'b0,1'b0,1'b1,payload[767:512],header,5'b0,1'b0,1'b0,1'b1};
            @(posedge axi_wrapper_if.clk);
             axi_wrapper_if.axi_wrapper_mport.tdata  <= {payload[1535:1280],header,5'h0,1'b0,1'b0,1'b1,payload[1279:1024],header,5'b0,1'b0,1'b0,1'b1};
            @(posedge axi_wrapper_if.clk); 
             axi_wrapper_if.axi_wrapper_mport.tdata  <= {payload[2047:1792],header,5'h0,1'b1,1'b0,1'b1,payload[1791:1536],header,5'b0,1'b0,1'b0,1'b1};
            @(posedge axi_wrapper_if.clk);
            axi_wrapper_if.axi_wrapper_mport.tvalid <= 1'b0;
            axi_wrapper_if.axi_wrapper_mport.tdata[valid1] <= 1'b0;  //valid
            axi_wrapper_if.axi_wrapper_mport.tdata[valid2] <= 1'b0;  //valid
            axi_wrapper_if.axi_wrapper_mport.tdata[eop] <= 1'b0;  //eop
            mmio_read_q.delete(index);
            send_response = 0;
    
       end // 40


     endcase

    end  //sop

      end        //send_response 

endtask: mmio_read_rsp_thread





virtual task mmio_reset_thread();
    @(posedge axi_wrapper_if.clk);    
    @(negedge axi_wrapper_if.resetn); 
    `uvm_info(msgid,"Observed AFU reset.. Clearing MMIO",UVM_LOW);
    cfg_ram.delete();
endtask: mmio_reset_thread


function update_cfg_ram(bit [15:0] csr_addr,bit [9:0] cfg_length,bit [2047:0] data);  //Make data 512 later
    int limit;
    bit [17:0] addr={csr_addr,2'b0};
    int fill=0;
            case(cfg_length)
            'h1: begin limit = 4; datao=data; fill = 1; end
            'h2: begin limit = 8; datao=data; fill = 1; end
            'h4: begin limit = 16; datao=data; fill = 1; end
            'h8: begin limit = 32; datao=data; fill = 1; end
            'h10: begin limit = 64; datao=data; fill =1; end
            'h20: begin limit = 128; 
                        if(count == 1) datao=data;
                        else if(count == 0) begin datao[1023:512] = data; fill = 1; count = 0; end
                  end
            'h40: begin limit = 256;
                        if(count == 1) datao=data;
                        else if(count == 2) datao[1023:512] =data;
                        else if(count == 3) datao[1535:1024] =data;
                        else if(count == 0) begin datao[2047:1536] = data; fill = 1;count = 0; end
                  end

        endcase
       if (fill == 1) begin
        for(int i=0;i<limit;i++) begin
            cfg_ram[addr] = datao[(i*8)+:8];
            addr++;
        end
        datao = 'h0;
       end
endfunction: update_cfg_ram

function bit [2047:0] get_cfg_data(bit [15:0] csr_addr,bit [9:0] cfg_length);
    int limit;
    bit [17:0] addr={csr_addr,2'b0};
    bit [2047:0] data;

        case(cfg_length)
            'h1:  limit = 4;
            'h2:  limit = 8;
            'h4:  limit = 16;
            'h8:  limit = 32;
            'h10: limit = 64;
            'h20: limit = 128;
            'h40: limit = 256;
        endcase
        for(int i=0;i<limit;i++) begin
            if(cfg_ram.exists(addr)) begin
                data[(i*8)+:8] = cfg_ram[addr];
            end
            else begin
                data[(i*8)+:8] = 8'hff;
                `uvm_warning(msgid,$sformatf("Cfg_Read to Un-Initialized Register location ADDR: %x READ_LENGTH: %x cfg_ram: %p",addr,cfg_length,cfg_ram));
            end
            addr++;
        end
        return data;
endfunction: get_cfg_data

function int pick_rand(ref bit [2047:0] data_q[int]);
    int count;
    int index=$urandom_range(data_q.size()-1);
    
        foreach(data_q[i])  begin
            if(count++ == index)
                return i;
        end
endfunction: pick_rand



endclass


`endif
