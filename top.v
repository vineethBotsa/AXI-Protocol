// ===============================================
// Write Address Channel Module
// ===============================================
module axi_channel_aw #(
    parameter ADDR_WIDTH = 32,
    parameter ID_WIDTH   = 4
) (
    input wire clk,
    input wire resetn,
    
    // Input side (from master)
    input  wire [ID_WIDTH-1:0]   s_awid,
    input  wire [ADDR_WIDTH-1:0] s_awaddr,
    input  wire [7:0]            s_awlen,
    input  wire [2:0]            s_awsize,
    input  wire [1:0]            s_awburst,
    input  wire                  s_awvalid,
    output wire                  s_awready,
    
    // Output side (to slave)
    output wire [ID_WIDTH-1:0]   m_awid,
    output wire [ADDR_WIDTH-1:0] m_awaddr,
    output wire [7:0]            m_awlen,
    output wire [2:0]            m_awsize,
    output wire [1:0]            m_awburst,
    output wire                  m_awvalid,
    input  wire                  m_awready
);

    // Internal registers
    reg [ID_WIDTH-1:0]   awid_reg;
    reg [ADDR_WIDTH-1:0] awaddr_reg;
    reg [7:0]            awlen_reg;
    reg [2:0]            awsize_reg;
    reg [1:0]            awburst_reg;
    reg                  awvalid_reg;
    
    // Handshake logic
    assign s_awready = ~awvalid_reg | m_awready;
    assign m_awvalid = awvalid_reg;
    assign m_awid    = awid_reg;
    assign m_awaddr  = awaddr_reg;
    assign m_awlen   = awlen_reg;
    assign m_awsize  = awsize_reg;
    assign m_awburst = awburst_reg;
    
    always @(posedge clk or negedge resetn) begin
        if (!resetn) begin
            awvalid_reg <= 1'b0;
            awid_reg    <= {ID_WIDTH{1'b0}};
            awaddr_reg  <= {ADDR_WIDTH{1'b0}};
            awlen_reg   <= 8'b0;
            awsize_reg  <= 3'b0;
            awburst_reg <= 2'b0;
        end else begin
            if (s_awready) begin
                awvalid_reg <= s_awvalid;
                if (s_awvalid) begin
                    awid_reg    <= s_awid;
                    awaddr_reg  <= s_awaddr;
                    awlen_reg   <= s_awlen;
                    awsize_reg  <= s_awsize;
                    awburst_reg <= s_awburst;
                end
            end
        end
    end

endmodule

// ===============================================
// Write Data Channel Module
// ===============================================
module axi_channel_w #(
    parameter DATA_WIDTH = 32
) (
    input wire clk,
    input wire resetn,
    
    // Input side (from master)
    input  wire [DATA_WIDTH-1:0] s_wdata,
    input  wire [DATA_WIDTH/8-1:0] s_wstrb,
    input  wire                  s_wlast,
    input  wire                  s_wvalid,
    output wire                  s_wready,
    
    // Output side (to slave)
    output wire [DATA_WIDTH-1:0] m_wdata,
    output wire [DATA_WIDTH/8-1:0] m_wstrb,
    output wire                  m_wlast,
    output wire                  m_wvalid,
    input  wire                  m_wready
);

    // Internal registers
    reg [DATA_WIDTH-1:0] wdata_reg;
    reg [DATA_WIDTH/8-1:0] wstrb_reg;
    reg                  wlast_reg;
    reg                  wvalid_reg;
    
    // Handshake logic
    assign s_wready = ~wvalid_reg | m_wready;
    assign m_wvalid = wvalid_reg;
    assign m_wdata  = wdata_reg;
    assign m_wstrb  = wstrb_reg;
    assign m_wlast  = wlast_reg;
    
    always @(posedge clk or negedge resetn) begin
        if (!resetn) begin
            wvalid_reg <= 1'b0;
            wdata_reg  <= {DATA_WIDTH{1'b0}};
            wstrb_reg  <= {(DATA_WIDTH/8){1'b0}};
            wlast_reg  <= 1'b0;
        end else begin
            if (s_wready) begin
                wvalid_reg <= s_wvalid;
                if (s_wvalid) begin
                    wdata_reg <= s_wdata;
                    wstrb_reg <= s_wstrb;
                    wlast_reg <= s_wlast;
                end
            end
        end
    end

endmodule

// ===============================================
// Write Response Channel Module
// ===============================================
module axi_channel_b #(
    parameter ID_WIDTH = 4
) (
    input wire clk,
    input wire resetn,
    
    // Input side (from slave)  
    input  wire [ID_WIDTH-1:0]   s_bid,
    input  wire [1:0]            s_bresp,
    input  wire                  s_bvalid,
    output wire                  s_bready,
    
    // Output side (to master)
    output wire [ID_WIDTH-1:0]   m_bid,
    output wire [1:0]            m_bresp,
    output wire                  m_bvalid,
    input  wire                  m_bready
);

    // Internal registers
    reg [ID_WIDTH-1:0] bid_reg;
    reg [1:0]          bresp_reg;
    reg                bvalid_reg;
    
    // Handshake logic
    assign s_bready = ~bvalid_reg | m_bready;
    assign m_bvalid = bvalid_reg;
    assign m_bid    = bid_reg;
    assign m_bresp  = bresp_reg;
    
    always @(posedge clk or negedge resetn) begin
        if (!resetn) begin
            bvalid_reg <= 1'b0;
            bid_reg    <= {ID_WIDTH{1'b0}};
            bresp_reg  <= 2'b0;
        end else begin
            if (s_bready) begin
                bvalid_reg <= s_bvalid;
                if (s_bvalid) begin
                    bid_reg   <= s_bid;
                    bresp_reg <= s_bresp;
                end
            end
        end
    end

endmodule

// ===============================================
// Read Address Channel Module
// ===============================================
module axi_channel_ar #(
    parameter ADDR_WIDTH = 32,
    parameter ID_WIDTH   = 4
) (
    input wire clk,
    input wire resetn,
    
    // Input side (from master)
    input  wire [ID_WIDTH-1:0]   s_arid,
    input  wire [ADDR_WIDTH-1:0] s_araddr,
    input  wire [7:0]            s_arlen,
    input  wire [2:0]            s_arsize,
    input  wire [1:0]            s_arburst,
    input  wire                  s_arvalid,
    output wire                  s_arready,
    
    // Output side (to slave)
    output wire [ID_WIDTH-1:0]   m_arid,
    output wire [ADDR_WIDTH-1:0] m_araddr,
    output wire [7:0]            m_arlen,
    output wire [2:0]            m_arsize,
    output wire [1:0]            m_arburst,
    output wire                  m_arvalid,
    input  wire                  m_arready
);

    // Internal registers
    reg [ID_WIDTH-1:0]   arid_reg;
    reg [ADDR_WIDTH-1:0] araddr_reg;
    reg [7:0]            arlen_reg;
    reg [2:0]            arsize_reg;
    reg [1:0]            arburst_reg;
    reg                  arvalid_reg;
    
    // Handshake logic
    assign s_arready = ~arvalid_reg | m_arready;
    assign m_arvalid = arvalid_reg;
    assign m_arid    = arid_reg;
    assign m_araddr  = araddr_reg;
    assign m_arlen   = arlen_reg;
    assign m_arsize  = arsize_reg;
    assign m_arburst = arburst_reg;
    
    always @(posedge clk or negedge resetn) begin
        if (!resetn) begin
            arvalid_reg <= 1'b0;
            arid_reg    <= {ID_WIDTH{1'b0}};
            araddr_reg  <= {ADDR_WIDTH{1'b0}};
            arlen_reg   <= 8'b0;
            arsize_reg  <= 3'b0;
            arburst_reg <= 2'b0;
        end else begin
            if (s_arready) begin
                arvalid_reg <= s_arvalid;
                if (s_arvalid) begin
                    arid_reg    <= s_arid;
                    araddr_reg  <= s_araddr;
                    arlen_reg   <= s_arlen;
                    arsize_reg  <= s_arsize;
                    arburst_reg <= s_arburst;
                end
            end
        end
    end

endmodule

// ===============================================
// Read Data Channel Module
// ===============================================
module axi_channel_r #(
    parameter DATA_WIDTH = 32,
    parameter ID_WIDTH   = 4
) (
    input wire clk,
    input wire resetn,
    
    // Input side (from slave)
    input  wire [ID_WIDTH-1:0]   s_rid,
    input  wire [DATA_WIDTH-1:0] s_rdata,
    input  wire [1:0]            s_rresp,
    input  wire                  s_rlast,
    input  wire                  s_rvalid,
    output wire                  s_rready,
    
    // Output side (to master)
    output wire [ID_WIDTH-1:0]   m_rid,
    output wire [DATA_WIDTH-1:0] m_rdata,
    output wire [1:0]            m_rresp,
    output wire                  m_rlast,
    output wire                  m_rvalid,
    input  wire                  m_rready
);

    // Internal registers
    reg [ID_WIDTH-1:0]   rid_reg;
    reg [DATA_WIDTH-1:0] rdata_reg;
    reg [1:0]            rresp_reg;
    reg                  rlast_reg;
    reg                  rvalid_reg;
    
    // Handshake logic
    assign s_rready = ~rvalid_reg | m_rready;
    assign m_rvalid = rvalid_reg;
    assign m_rid    = rid_reg;
    assign m_rdata  = rdata_reg;
    assign m_rresp  = rresp_reg;
    assign m_rlast  = rlast_reg;
    
    always @(posedge clk or negedge resetn) begin
        if (!resetn) begin
            rvalid_reg <= 1'b0;
            rid_reg    <= {ID_WIDTH{1'b0}};
            rdata_reg  <= {DATA_WIDTH{1'b0}};
            rresp_reg  <= 2'b0;
            rlast_reg  <= 1'b0;
        end else begin
            if (s_rready) begin
                rvalid_reg <= s_rvalid;
                if (s_rvalid) begin
                    rid_reg   <= s_rid;
                    rdata_reg <= s_rdata;
                    rresp_reg <= s_rresp;
                    rlast_reg <= s_rlast;
                end
            end
        end
    end

endmodule

// ===============================================
// Top-level AXI Interconnect (1 Master, 1 Slave)
// ===============================================
module axi_interconnect_1x1 #(
    parameter DATA_WIDTH = 32,
    parameter ADDR_WIDTH = 32,
    parameter ID_WIDTH   = 4
) (
    input wire clk,
    input wire resetn,
    
    // Master Interface
    // Write Address Channel
    input  wire [ID_WIDTH-1:0]   m_axi_awid,
    input  wire [ADDR_WIDTH-1:0] m_axi_awaddr,
    input  wire [7:0]            m_axi_awlen,
    input  wire [2:0]            m_axi_awsize,
    input  wire [1:0]            m_axi_awburst,
    input  wire                  m_axi_awvalid,
    output wire                  m_axi_awready,
    
    // Write Data Channel
    input  wire [DATA_WIDTH-1:0] m_axi_wdata,
    input  wire [DATA_WIDTH/8-1:0] m_axi_wstrb,
    input  wire                  m_axi_wlast,
    input  wire                  m_axi_wvalid,
    output wire                  m_axi_wready,
    
    // Write Response Channel
    output wire [ID_WIDTH-1:0]   m_axi_bid,
    output wire [1:0]            m_axi_bresp,
    output wire                  m_axi_bvalid,
    input  wire                  m_axi_bready,
    
    // Read Address Channel
    input  wire [ID_WIDTH-1:0]   m_axi_arid,
    input  wire [ADDR_WIDTH-1:0] m_axi_araddr,
    input  wire [7:0]            m_axi_arlen,
    input  wire [2:0]            m_axi_arsize,
    input  wire [1:0]            m_axi_arburst,
    input  wire                  m_axi_arvalid,
    output wire                  m_axi_arready,
    
    // Read Data Channel
    output wire [ID_WIDTH-1:0]   m_axi_rid,
    output wire [DATA_WIDTH-1:0] m_axi_rdata,
    output wire [1:0]            m_axi_rresp,
    output wire                  m_axi_rlast,
    output wire                  m_axi_rvalid,
    input  wire                  m_axi_rready,
    
    // Slave Interface
    // Write Address Channel
    output wire [ID_WIDTH-1:0]   s_axi_awid,
    output wire [ADDR_WIDTH-1:0] s_axi_awaddr,
    output wire [7:0]            s_axi_awlen,
    output wire [2:0]            s_axi_awsize,
    output wire [1:0]            s_axi_awburst,
    output wire                  s_axi_awvalid,
    input  wire                  s_axi_awready,
    
    // Write Data Channel
    output wire [DATA_WIDTH-1:0] s_axi_wdata,
    output wire [DATA_WIDTH/8-1:0] s_axi_wstrb,
    output wire                  s_axi_wlast,
    output wire                  s_axi_wvalid,
    input  wire                  s_axi_wready,
    
    // Write Response Channel
    input  wire [ID_WIDTH-1:0]   s_axi_bid,
    input  wire [1:0]            s_axi_bresp,
    input  wire                  s_axi_bvalid,
    output wire                  s_axi_bready,
    
    // Read Address Channel
    output wire [ID_WIDTH-1:0]   s_axi_arid,
    output wire [ADDR_WIDTH-1:0] s_axi_araddr,
    output wire [7:0]            s_axi_arlen,
    output wire [2:0]            s_axi_arsize,
    output wire [1:0]            s_axi_arburst,
    output wire                  s_axi_arvalid,
    input  wire                  s_axi_arready,
    
    // Read Data Channel
    input  wire [ID_WIDTH-1:0]   s_axi_rid,
    input  wire [DATA_WIDTH-1:0] s_axi_rdata,
    input  wire [1:0]            s_axi_rresp,
    input  wire                  s_axi_rlast,
    input  wire                  s_axi_rvalid,
    output wire                  s_axi_rready
);

    // ===============================================
    // Instantiate all 5 channel modules
    // ===============================================
    
    // Write Address Channel
    axi_channel_aw #(
        .ADDR_WIDTH(ADDR_WIDTH),
        .ID_WIDTH(ID_WIDTH)
    ) channel_aw (
        .clk(clk),
        .resetn(resetn),
        
        // From Master
        .s_awid(m_axi_awid),
        .s_awaddr(m_axi_awaddr),
        .s_awlen(m_axi_awlen),
        .s_awsize(m_axi_awsize),
        .s_awburst(m_axi_awburst),
        .s_awvalid(m_axi_awvalid),
        .s_awready(m_axi_awready),
        
        // To Slave
        .m_awid(s_axi_awid),
        .m_awaddr(s_axi_awaddr),
        .m_awlen(s_axi_awlen),
        .m_awsize(s_axi_awsize),
        .m_awburst(s_axi_awburst),
        .m_awvalid(s_axi_awvalid),
        .m_awready(s_axi_awready)
    );
    
    // Write Data Channel
    axi_channel_w #(
        .DATA_WIDTH(DATA_WIDTH)
    ) channel_w (
        .clk(clk),
        .resetn(resetn),
        
        // From Master
        .s_wdata(m_axi_wdata),
        .s_wstrb(m_axi_wstrb),
        .s_wlast(m_axi_wlast),
        .s_wvalid(m_axi_wvalid),
        .s_wready(m_axi_wready),
        
        // To Slave
        .m_wdata(s_axi_wdata),
        .m_wstrb(s_axi_wstrb),
        .m_wlast(s_axi_wlast),
        .m_wvalid(s_axi_wvalid),
        .m_wready(s_axi_wready)
    );
    
    // Write Response Channel
    axi_channel_b #(
        .ID_WIDTH(ID_WIDTH)
    ) channel_b (
        .clk(clk),
        .resetn(resetn),
        
        // From Slave
        .s_bid(s_axi_bid),
        .s_bresp(s_axi_bresp),
        .s_bvalid(s_axi_bvalid),
        .s_bready(s_axi_bready),
        
        // To Master
        .m_bid(m_axi_bid),
        .m_bresp(m_axi_bresp),
        .m_bvalid(m_axi_bvalid),
        .m_bready(m_axi_bready)
    );
    
    // Read Address Channel
    axi_channel_ar #(
        .ADDR_WIDTH(ADDR_WIDTH),
        .ID_WIDTH(ID_WIDTH)
    ) channel_ar (
        .clk(clk),
        .resetn(resetn),
        
        // From Master
        .s_arid(m_axi_arid),
        .s_araddr(m_axi_araddr),
        .s_arlen(m_axi_arlen),
        .s_arsize(m_axi_arsize),
        .s_arburst(m_axi_arburst),
        .s_arvalid(m_axi_arvalid),
        .s_arready(m_axi_arready),
        
        // To Slave
        .m_arid(s_axi_arid),
        .m_araddr(s_axi_araddr),
        .m_arlen(s_axi_arlen),
        .m_arsize(s_axi_arsize),
        .m_arburst(s_axi_arburst),
        .m_arvalid(s_axi_arvalid),
        .m_arready(s_axi_arready)
    );
    
    // Read Data Channel
    axi_channel_r #(
        .DATA_WIDTH(DATA_WIDTH),
        .ID_WIDTH(ID_WIDTH)
    ) channel_r (
        .clk(clk),
        .resetn(resetn),
        
        // From Slave
        .s_rid(s_axi_rid),
        .s_rdata(s_axi_rdata),
        .s_rresp(s_axi_rresp),
        .s_rlast(s_axi_rlast),
        .s_rvalid(s_axi_rvalid),
        .s_rready(s_axi_rready),
        
        // To Master
        .m_rid(m_axi_rid),
        .m_rdata(m_axi_rdata),
        .m_rresp(m_axi_rresp),
        .m_rlast(m_axi_rlast),
        .m_rvalid(m_axi_rvalid),
        .m_rready(m_axi_rready)
    );

endmodule
