`timescale 1ns/1ps

module tb_axi4_lite_slave();

// ============================================================================
// Clock and Reset
// ============================================================================
reg ACLK;
reg ARESETN;

// Clock generation
initial begin
    ACLK = 1'b0;
    forever #5 ACLK = ~ACLK; // 100MHz clock
end

// ============================================================================
// AXI4-Lite Signals
// ============================================================================
// Write Address Channel
reg [31:0] AWADDR;
reg        AWVALID;
wire       AWREADY;

// Write Data Channel  
reg [31:0] WDATA;
reg [3:0]  WSTRB;
reg        WVALID;
wire       WREADY;

// Write Response Channel
wire [1:0] BRESP;
wire       BVALID;
reg        BREADY;

// Read Address Channel
reg [31:0] ARADDR;
reg        ARVALID;
wire       ARREADY;

// Read Data Channel
wire [31:0] RDATA;
wire [1:0]  RRESP;
wire        RVALID;
reg         RREADY;

// ============================================================================
// Device Under Test
// ============================================================================
axi4_lite_slave dut (
    .ACLK(ACLK),
    .ARESETN(ARESETN),
    
    // Write Address Channel
    .AWADDR(AWADDR),
    .AWVALID(AWVALID),
    .AWREADY(AWREADY),
    
    // Write Data Channel
    .WDATA(WDATA),
    .WSTRB(WSTRB),
    .WVALID(WVALID),
    .WREADY(WREADY),
    
    // Write Response Channel
    .BRESP(BRESP),
    .BVALID(BVALID),
    .BREADY(BREADY),
    
    // Read Address Channel
    .ARADDR(ARADDR),
    .ARVALID(ARVALID),
    .ARREADY(ARREADY),
    
    // Read Data Channel
    .RDATA(RDATA),
    .RRESP(RRESP),
    .RVALID(RVALID),
    .RREADY(RREADY)
);

// ============================================================================
// Test Tasks
// ============================================================================

// Simple write transaction
task write_transaction;
    input [31:0] address;
    input [31:0] data;
    begin
        $display("=== WRITE: Address=0x%h, Data=0x%h", address, data);
        
        // Drive address and data
        @(posedge ACLK);
        AWADDR  <= address;
        AWVALID <= 1'b1;
        WDATA   <= data;
        WVALID  <= 1'b1;
        WSTRB   <= 4'b1111; // All bytes enabled
        BREADY  <= 1'b1;
        
        // Wait for handshake
        wait (AWREADY && WREADY);
        @(posedge ACLK);
        AWVALID <= 1'b0;
        WVALID  <= 1'b0;
        
        // Wait for write response
        wait (BVALID);
        @(posedge ACLK);
        
        // Check response
        if (BRESP == 2'b00) 
            $display("Write SUCCESS");
        else
            $display("Write ERROR: Response=0x%h", BRESP);
            
        #20; // Small delay between transactions
    end
endtask

// Simple read transaction  
task read_transaction;
    input [31:0] address;
    input [31:0] expected_data;
    begin
        $display("=== READ: Address=0x%h, Expected=0x%h", address, expected_data);
        
        // Drive address
        @(posedge ACLK);
        ARADDR  <= address;
        ARVALID <= 1'b1;
        RREADY  <= 1'b1;
        
        // Wait for address acceptance
        wait (ARREADY);
        @(posedge ACLK);
        ARVALID <= 1'b0;
        
        // Wait for read data
        wait (RVALID);
        
        // Check data and response
        if (RDATA === expected_data && RRESP == 2'b00) 
            $display("Read SUCCESS: Data=0x%h", RDATA);
        else
            $display("Read ERROR: Data=0x%h, Response=0x%h", RDATA, RRESP);
            
        @(posedge ACLK);
        #20; // Small delay between transactions
    end
endtask

// ============================================================================
// Main Test Sequence
// ============================================================================
initial begin
    $display("Starting AXI4-Lite Slave Testbench");
    $display("==================================");
    
    // Initialize all signals
    ARESETN = 1'b0;
    AWADDR  = 32'b0;
    AWVALID = 1'b0;
    WDATA   = 32'b0;
    WVALID  = 1'b0;
    WSTRB   = 4'b0000;
    BREADY  = 1'b0;
    ARADDR  = 32'b0;
    ARVALID = 1'b0;
    RREADY  = 1'b0;
    
    // Apply reset
    #100;
    ARESETN = 1'b1;
    $display("Reset released");
    
    // Test 1: Basic write and read
    $display("\n--- Test 1: Basic Write/Read ---");
    write_transaction(32'h00000000, 32'h12345678); // Write to register 0
    write_transaction(32'h00000004, 32'hABCDEF01); // Write to register 1
    read_transaction(32'h00000000, 32'h12345678);  // Read from register 0
    read_transaction(32'h00000004, 32'hABCDEF01);  // Read from register 1
    
    // Test 2: Invalid addresses (should return error)
    $display("\n--- Test 2: Error Conditions ---");
    write_transaction(32'h00000020, 32'hDEADBEEF); // Invalid address
    read_transaction(32'h00000020, 32'h00000000);  // Invalid address
    
    // Test 3: Byte enables (partial writes)
    $display("\n--- Test 3: Byte Enables ---");
    write_transaction(32'h00000008, 32'hAABBCCDD); // Full write to register 2
    
    // Write only lower 2 bytes
    @(posedge ACLK);
    AWADDR  <= 32'h00000008;
    AWVALID <= 1'b1;
    WDATA   <= 32'h00001234;
    WVALID  <= 1'b1;
    WSTRB   <= 4'b0011; // Only enable bytes 0 and 1
    BREADY  <= 1'b1;
    
    wait (AWREADY && WREADY);
    @(posedge ACLK);
    AWVALID <= 1'b0;
    WVALID  <= 1'b0;
    wait (BVALID);
    @(posedge ACLK);
    
    read_transaction(32'h00000008, 32'hAABB1234); // Should have lower 2 bytes updated
    
    // Test 4: Backpressure (delaying ready signals)
    $display("\n--- Test 4: Backpressure ---");
    
    // Delay BREADY
    @(posedge ACLK);
    AWADDR  <= 32'h0000000C;
    AWVALID <= 1'b1;
    WDATA   <= 32'h55555555;
    WVALID  <= 1'b1;
    WSTRB   <= 4'b1111;
    BREADY  <= 1'b0; // Don't accept response immediately
    
    wait (AWREADY && WREADY);
    @(posedge ACLK);
    AWVALID <= 1'b0;
    WVALID  <= 1'b0;
    
    #50; // Wait before accepting response
    BREADY <= 1'b1;
    wait (BVALID);
    @(posedge ACLK);
    BREADY <= 1'b0;
    
    read_transaction(32'h0000000C, 32'h55555555);
    
    // Final read of all registers
    $display("\n--- Final Register Dump ---");
    read_transaction(32'h00000000, 32'h12345678);
    read_transaction(32'h00000004, 32'hABCDEF01); 
    read_transaction(32'h00000008, 32'hAABB1234);
    read_transaction(32'h0000000C, 32'h55555555);
    read_transaction(32'h00000010, 32'h00000000); // Should be 0 (never written)
    
    $display("\n==================================");
    $display("Testbench completed");
    $finish;
end

// ============================================================================
// Monitoring
// ============================================================================
always @(posedge ACLK) begin
    // Monitor write transactions
    if (AWVALID && AWREADY) begin
        $display("[MONITOR] Write Address: 0x%h", AWADDR);
    end
    if (WVALID && WREADY) begin
        $display("[MONITOR] Write Data: 0x%h, Strobes: 4'b%b", WDATA, WSTRB);
    end
    if (BVALID && BREADY) begin
        $display("[MONITOR] Write Response: 0x%h", BRESP);
    end
    
    // Monitor read transactions  
    if (ARVALID && ARREADY) begin
        $display("[MONITOR] Read Address: 0x%h", ARADDR);
    end
    if (RVALID && RREADY) begin
        $display("[MONITOR] Read Data: 0x%h, Response: 0x%h", RDATA, RRESP);
    end
end

endmodule
