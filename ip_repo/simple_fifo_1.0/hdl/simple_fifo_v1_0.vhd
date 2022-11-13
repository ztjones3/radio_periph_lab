library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity simple_fifo_v1_0 is
	generic (
		-- Parameters of Axi Slave Bus Interface S00_AXI
		C_S00_AXI_DATA_WIDTH	: integer	:= 32;
		C_S00_AXI_ADDR_WIDTH	: integer	:= 4
	);
	port (
		s_axis_tvalid   : in  std_logic;
		s_axis_tdata    : in  std_logic_vector(31 downto 0);

		-- Ports of Axi Slave Bus Interface S00_AXI
		s00_axi_aclk    : in std_logic;
		s00_axi_aresetn : in std_logic;
		s00_axi_awaddr  : in std_logic_vector(C_S00_AXI_ADDR_WIDTH-1 downto 0);
		s00_axi_awprot  : in std_logic_vector(2 downto 0);
		s00_axi_awvalid : in std_logic;
		s00_axi_awready : out std_logic;
		s00_axi_wdata   : in std_logic_vector(C_S00_AXI_DATA_WIDTH-1 downto 0);
		s00_axi_wstrb   : in std_logic_vector((C_S00_AXI_DATA_WIDTH/8)-1 downto 0);
		s00_axi_wvalid  : in std_logic;
		s00_axi_wready  : out std_logic;
		s00_axi_bresp   : out std_logic_vector(1 downto 0);
		s00_axi_bvalid  : out std_logic;
		s00_axi_bready  : in std_logic;
		s00_axi_araddr  : in std_logic_vector(C_S00_AXI_ADDR_WIDTH-1 downto 0);
		s00_axi_arprot  : in std_logic_vector(2 downto 0);
		s00_axi_arvalid : in std_logic;
		s00_axi_arready : out std_logic;
		s00_axi_rdata   : out std_logic_vector(C_S00_AXI_DATA_WIDTH-1 downto 0);
		s00_axi_rresp   : out std_logic_vector(1 downto 0);
		s00_axi_rvalid  : out std_logic;
		s00_axi_rready  : in std_logic
	);
end simple_fifo_v1_0;

architecture arch_imp of simple_fifo_v1_0 is

	signal m_axis_tready      : std_logic                     := '0';
	signal m_axis_tdata       : std_logic_vector(31 downto 0) := (others => '0');
	signal axis_wr_data_count : std_logic_vector(31 downto 0) := (others => '0');

	-- component declaration
	component simple_fifo_v1_0_S00_AXI is
		generic (
			C_S_AXI_DATA_WIDTH	: integer	:= 32;
			C_S_AXI_ADDR_WIDTH	: integer	:= 4
		);
		port (
			S_AXI_ACLK         : in  std_logic;
			S_AXI_ARESETN      : in  std_logic;
			S_AXI_AWADDR       : in  std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0);
			S_AXI_AWPROT       : in  std_logic_vector(2 downto 0);
			S_AXI_AWVALID      : in  std_logic;
			S_AXI_AWREADY      : out std_logic;
			S_AXI_WDATA        : in  std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
			S_AXI_WSTRB        : in  std_logic_vector((C_S_AXI_DATA_WIDTH/8)-1 downto 0);
			S_AXI_WVALID       : in  std_logic;
			S_AXI_WREADY       : out std_logic;
			S_AXI_BRESP        : out std_logic_vector(1 downto 0);
			S_AXI_BVALID       : out std_logic;
			S_AXI_BREADY       : in  std_logic;
			S_AXI_ARADDR       : in  std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0);
			S_AXI_ARPROT       : in  std_logic_vector(2 downto 0);
			S_AXI_ARVALID      : in  std_logic;
			S_AXI_ARREADY      : out std_logic;
			S_AXI_RDATA        : out std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
			S_AXI_RRESP        : out std_logic_vector(1 downto 0);
			S_AXI_RVALID       : out std_logic;
			S_AXI_RREADY       : in  std_logic;
			m_axis_tready      : out std_logic;
		  m_axis_tdata       : in  std_logic_vector(31 downto 0);
			axis_wr_data_count : in  std_logic_vector(31 downto 0)
		);
	end component simple_fifo_v1_0_S00_AXI;

	component axis_data_fifo_0 is
		port(
		  s_axis_aresetn     : in  std_logic;
		  s_axis_aclk        : in  std_logic;
		  s_axis_tvalid      : in  std_logic;
		  s_axis_tready      : out std_logic;
		  s_axis_tdata       : in  std_logic_vector(31 downto 0);
		  m_axis_tvalid      : out std_logic;
		  m_axis_tready      : in  std_logic;
		  m_axis_tdata       : out std_logic_vector(31 downto 0);
		  axis_wr_data_count : out std_logic_vector(31 downto 0)
		);
	end component;

begin

-- Instantiation of Axi Bus Interface S00_AXI
simple_fifo_v1_0_S00_AXI_inst : simple_fifo_v1_0_S00_AXI
	generic map (
		C_S_AXI_DATA_WIDTH => C_S00_AXI_DATA_WIDTH,
		C_S_AXI_ADDR_WIDTH => C_S00_AXI_ADDR_WIDTH
	)
	port map (
		S_AXI_ACLK         => s00_axi_aclk,      -- in  std_logic;
		S_AXI_ARESETN      => s00_axi_aresetn,   -- in  std_logic;
		S_AXI_AWADDR       => s00_axi_awaddr,    -- in  std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0);
		S_AXI_AWPROT       => s00_axi_awprot,    -- in  std_logic_vector(2 downto 0);
		S_AXI_AWVALID      => s00_axi_awvalid,   -- in  std_logic;
		S_AXI_AWREADY      => s00_axi_awready,   -- out std_logic;
		S_AXI_WDATA        => s00_axi_wdata,     -- in  std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
		S_AXI_WSTRB        => s00_axi_wstrb,     -- in  std_logic_vector((C_S_AXI_DATA_WIDTH/8)-1 downto 0);
		S_AXI_WVALID       => s00_axi_wvalid,    -- in  std_logic;
		S_AXI_WREADY       => s00_axi_wready,    -- out std_logic;
		S_AXI_BRESP        => s00_axi_bresp,     -- out std_logic_vector(1 downto 0);
		S_AXI_BVALID       => s00_axi_bvalid,    -- out std_logic;
		S_AXI_BREADY       => s00_axi_bready,    -- in  std_logic;
		S_AXI_ARADDR       => s00_axi_araddr,    -- in  std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0);
		S_AXI_ARPROT       => s00_axi_arprot,    -- in  std_logic_vector(2 downto 0);
		S_AXI_ARVALID      => s00_axi_arvalid,   -- in  std_logic;
		S_AXI_ARREADY      => s00_axi_arready,   -- out std_logic;
		S_AXI_RDATA        => s00_axi_rdata,     -- out std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
		S_AXI_RRESP        => s00_axi_rresp,     -- out std_logic_vector(1 downto 0);
		S_AXI_RVALID       => s00_axi_rvalid,    -- out std_logic;
		S_AXI_RREADY       => s00_axi_rready,    -- in  std_logic;
		m_axis_tready      => m_axis_tready,     -- out std_logic;
		m_axis_tdata       => m_axis_tdata,      -- in  std_logic_vector(31 downto 0);
		axis_wr_data_count => axis_wr_data_count -- in  std_logic_vector(31 downto 0)
	);

	u_fifo : axis_data_fifo_0
		port map(
		  s_axis_aresetn     => s00_axi_aresetn,    -- in  std_logic;
		  s_axis_aclk        => s00_axi_aclk,       -- in  std_logic;
		  s_axis_tvalid      => s_axis_tvalid,      -- in  std_logic;
		  s_axis_tready      => open,               -- out std_logic;
		  s_axis_tdata       => s_axis_tdata,       -- in  std_logic_vector(31 downto 0);
		  m_axis_tvalid      => open,               -- out std_logic;
		  m_axis_tready      => m_axis_tready,      -- in  std_logic;
		  m_axis_tdata       => m_axis_tdata,       -- out std_logic_vector(31 downto 0);
		  axis_wr_data_count => axis_wr_data_count  -- out std_logic_vector(31 downto 0)
		);

end arch_imp;
