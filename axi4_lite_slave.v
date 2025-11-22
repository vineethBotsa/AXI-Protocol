module axi4_lite_slave (
    // Global signals
    input  wire        ACLK,
    input  wire        ARESETN,
    
    // Write Address Channel
    input  wire [31:0] AWADDR,
    input  wire        AWVALID,
    output reg         AWREADY,
    
    // Write Data Channel
    input  wire [31:0] WDATA,
    input  wire [3:0]  WSTRB,
    input  wire        WVALID,
    output reg         WREADY,
    
    // Write Response Channel
    output reg  [1:0]  BRESP,
    output reg         BVALID,
    input  wire        BREADY,
    
    // Read Address Channel
    input  wire [31:0] ARADDR,
    input  wire        ARVALID,
    output reg         ARREADY,
    
    // Read Data Channel
    output reg  [31:0] RDATA,
    output reg  [1:0]  RRESP,
    output reg         RVALID,
    input  wire        RREADY
);

// ============================================================================
// FSM State Definitions
// ============================================================================

// Write FSM States
localparam [2:0] WR_IDLE      = 3'b000;
localparam [2:0] WR_ADDR      = 3'b001;
localparam [2:0] WR_DATA      = 3'b010;
localparam [2:0] WR_RESPONSE  = 3'b011;

// Read FSM States
localparam [1:0] RD_IDLE      = 2'b00;
localparam [1:0] RD_ADDR      = 2'b01;
localparam [1:0] RD_DATA      = 2'b10;

// ============================================================================
// Internal Registers
// ============================================================================

// Register Bank - 8 x 32-bit registers
reg [31:0] registers [0:7];

// FSM State Registers
reg [2:0] write_current_state, write_next_state;
reg [1:0] read_current_state, read_next_state;

// Internal control registers
reg [2:0]  write_reg_addr;
reg [2:0]  read_reg_addr;
reg        write_addr_valid;
reg        read_addr_valid;

// ============================================================================
// Write FSM - State Register
// ============================================================================

always @(posedge ACLK or negedge ARESETN) begin
    if (!ARESETN) begin
        write_current_state <= WR_IDLE;
    end else begin
        write_current_state <= write_next_state;
    end
end

// ============================================================================
// Write FSM - Next State Logic
// ============================================================================

always @(*) begin
    write_next_state = write_current_state;
    
    case (write_current_state)
        WR_IDLE: begin
            if (AWVALID && WVALID) begin
                write_next_state = WR_ADDR;
            end else if (AWVALID) begin
                write_next_state = WR_ADDR;
            end else if (WVALID) begin
                write_next_state = WR_DATA;
            end
        end
        
        WR_ADDR: begin
            if (WVALID) begin
                write_next_state = WR_RESPONSE;
            end else begin
                write_next_state = WR_DATA;
            end
        end
        
        WR_DATA: begin
            if (WVALID) begin
                write_next_state = WR_RESPONSE;
            end
        end
        
        WR_RESPONSE: begin
            if (BREADY) begin
                write_next_state = WR_IDLE;
            end
        end
        
        default: begin
            write_next_state = WR_IDLE;
        end
    endcase
end

// ============================================================================
// Write FSM - Output Logic
// ============================================================================

always @(posedge ACLK or negedge ARESETN) begin
    if (!ARESETN) begin
        AWREADY <= 1'b0;
        WREADY <= 1'b0;
        BVALID <= 1'b0;
        BRESP <= 2'b00;
        write_reg_addr <= 3'b0;
        write_addr_valid <= 1'b0;
    end else begin
        case (write_next_state)
            WR_IDLE: begin
                AWREADY <= 1'b1;
                WREADY <= 1'b1;
                BVALID <= 1'b0;
            end
            
            WR_ADDR: begin
                if (AWVALID) begin
                    AWREADY <= 1'b0;
                    write_reg_addr <= AWADDR[4:2]; // Register index
                    write_addr_valid <= (AWADDR[31:5] == 27'b0); // Address validation
                end
            end
            
            WR_DATA: begin
                if (WVALID) begin
                    WREADY <= 1'b0;
                end
            end
            
            WR_RESPONSE: begin
                AWREADY <= 1'b0;
                WREADY <= 1'b0;
                BVALID <= 1'b1;
                
                // Update register if address was valid
                if (write_addr_valid && WVALID) begin
                    if (WSTRB[0]) registers[write_reg_addr][7:0]   <= WDATA[7:0];
                    if (WSTRB[1]) registers[write_reg_addr][15:8]  <= WDATA[15:8];
                    if (WSTRB[2]) registers[write_reg_addr][23:16] <= WDATA[23:16];
                    if (WSTRB[3]) registers[write_reg_addr][31:24] <= WDATA[31:24];
                    BRESP <= 2'b00; // OKAY
                end else begin
                    BRESP <= 2'b10; // SLVERR
                end
            end
        endcase
    end
end

// ============================================================================
// Read FSM - State Register
// ============================================================================

always @(posedge ACLK or negedge ARESETN) begin
    if (!ARESETN) begin
        read_current_state <= RD_IDLE;
    end else begin
        read_current_state <= read_next_state;
    end
end

// ============================================================================
// Read FSM - Next State Logic
// ============================================================================

always @(*) begin
    read_next_state = read_current_state;
    
    case (read_current_state)
        RD_IDLE: begin
            if (ARVALID) begin
                read_next_state = RD_ADDR;
            end
        end
        
        RD_ADDR: begin
            read_next_state = RD_DATA;
        end
        
        RD_DATA: begin
            if (RREADY) begin
                read_next_state = RD_IDLE;
            end
        end
        
        default: begin
            read_next_state = RD_IDLE;
        end
    endcase
end

// ============================================================================
// Read FSM - Output Logic
// ============================================================================

always @(posedge ACLK or negedge ARESETN) begin
    if (!ARESETN) begin
        ARREADY <= 1'b0;
        RVALID <= 1'b0;
        RDATA <= 32'b0;
        RRESP <= 2'b00;
        read_reg_addr <= 3'b0;
        read_addr_valid <= 1'b0;
    end else begin
        case (read_next_state)
            RD_IDLE: begin
                ARREADY <= 1'b1;
                RVALID <= 1'b0;
            end
            
            RD_ADDR: begin
                ARREADY <= 1'b0;
                read_reg_addr <= ARADDR[4:2]; // Register index
                read_addr_valid <= (ARADDR[31:5] == 27'b0); // Address validation
            end
            
            RD_DATA: begin
                RVALID <= 1'b1;
                
                if (read_addr_valid) begin
                    RDATA <= registers[read_reg_addr];
                    RRESP <= 2'b00; // OKAY
                end else begin
                    RDATA <= 32'b0;
                    RRESP <= 2'b10; // SLVERR
                end
            end
        endcase
    end
end

// ============================================================================
// Register Initialization
// ============================================================================

integer i;
always @(posedge ACLK or negedge ARESETN) begin
    if (!ARESETN) begin
        for (i = 0; i < 8; i = i + 1) begin
            registers[i] <= 32'b0;
        end
    end
end

endmodule
