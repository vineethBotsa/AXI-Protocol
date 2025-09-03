`timescale 1ns / 1ps

module s_axi_stream( output reg valid,
            output reg [31:0] data,
            
            input ready,
            input reset,
            input clk,
            input [31:0] in_data,
            input send 
    );
    reg [31:0] storein_data;
    always@(posedge clk)
    begin
       if(reset)
       storein_data <= 0;
       else
       storein_data <= in_data;
    end
   
    wire handshake;
    assign handshake = valid & ready;
    
    always@(posedge clk)
    begin
       if(reset)
       data <= 0;
       else if(handshake)
             data <= 0;
            else if(send)
                 data <= storein_data;
                 else
                 data <= data;
    end
    
    always@(posedge clk)
    begin
    if(reset)
    valid <= 1'b0;
    else if(handshake)
            valid <= 1'b0;
         else
             if(send)
               valid <= 1'b1;
             else
               valid <= valid;
    end
    
    
endmodule


module d_axi_stream( output reg ready,
                     output reg data_,
                     input valid,
                     input [31:0] data,
                     input clk,
                     input reset,
                     input ready_in
                     );
                     
    reg [31:0] storein_data;
    wire handshake;
    assign handshake = valid & ready;                 
    always@(posedge clk)
    begin
       if(reset)
       storein_data <= 1'b0;
       else
           begin
              if(handshake)
              data_ <= data;
              else
              data_ <= data_;
           end
    end          
    
    always@(posedge clk)
    begin
       if(reset)
       ready <= 1'b0;
       else
           begin
              if(ready == 1'b0 && ready_in == 1'b1)
                 ready <= 1'b1;
                 else if(handshake)
                      ready <= 1'b0;
                      else if(ready == 1'b1 && ready_in == 1'b0)
                           ready <= 1'b1;
                           else
                           ready <= ready;
           end
    end
    
    
     
endmodule

module m_axi(output AW_valid,
             output AW_address,
             output W_valid,
             output W_address,
             output AR_valid,
             output AR_address,
             output B_ready,
             output R_ready,
             
             input AW_ready,
             input W_ready,
             input AR_ready,
             input B_valid,
             input B_response,
             input R_valid,
             input R_data
              );
               
endmodule              