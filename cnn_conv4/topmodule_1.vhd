----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 16.08.2023 15:57:02
-- Design Name: 
-- Module Name: top_module1 - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.std_logic_unsigned.all;
use IEEE.NUMERIC_STD.ALL;
use work.fpupack.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity top_module1 is
    Port (  clk     : in std_logic;
 --           reset   : in std_logic;
 --           first_start   : in std_logic;
            rd_out  : out std_logic);
end top_module1;

architecture Behavioral of top_module1 is

component cnn_conv4b is
    Port (  reset_conv4 : in STD_LOGIC;
            clk : in STD_LOGIC;
            start_conv4 : in STD_LOGIC;
            samples_conv4 : in in_Conv4;
--            filter_conv4 : in filter4;
--            bias_conv4 : in biasConv;
            ready_conv4: out STD_LOGIC;            
--            output_conv4: out out_Conv2
            out_conv4: out std_logic_vector (FP_WIDTH-1 downto 0));--ILA
end component;

COMPONENT ila_0

PORT (
	clk : IN STD_LOGIC;



	probe0 : IN STD_LOGIC_VECTOR(0 DOWNTO 0); 
	probe1 : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
	probe2 : IN STD_LOGIC_VECTOR(26 DOWNTO 0)
);
END COMPONENT  ;

COMPONENT blk_mem_gen_0
  PORT (
    clka : IN STD_LOGIC;
    ena : IN STD_LOGIC;
    addra : IN STD_LOGIC_VECTOR(9 DOWNTO 0);
    douta : OUT STD_LOGIC_VECTOR(26 DOWNTO 0)
  );
END COMPONENT;

COMPONENT vio_0
  PORT (
    clk : IN STD_LOGIC;
    probe_in0 : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
    probe_out0 : OUT STD_LOGIC_VECTOR(0 DOWNTO 0);
    probe_out1 : OUT STD_LOGIC_VECTOR(0 DOWNTO 0)
  );
END COMPONENT;

signal addr : std_logic_vector(9 downto 0);
signal s_sample, s_out : std_logic_vector(FP_WIDTH-1 downto 0);
signal s_start_conv4, sready_conv4 : std_logic;
signal s_samples_conv4 : in_Conv4;
signal proc_sig,ready_ROM, ff1: std_logic;
signal reset,first_start: std_logic;

signal i : integer range 0 to 31 := 31;
signal j : integer range 0 to 29 := 29;

begin
uut : cnn_conv4b port map (     reset_conv4       => reset,
                                clk               => clk,
                                start_conv4       => s_start_conv4,
                                ready_conv4       => sready_conv4,
                                samples_conv4     => s_samples_conv4,                                    
                             --   filter_conv4      => sfilter_conv4,                                
                            --    bias_conv4        => sbias_conv4,                                
                                out_conv4      => s_out);

ILA : ila_0
PORT MAP (
	clk => clk,
	probe0(0) => s_start_conv4, 
	probe1(0) => sready_conv4, 
	probe2 => s_out
	);
	
ROM : blk_mem_gen_0
  PORT MAP (
    clka => clk,
    ena => '1',
    addra => addr,
    douta => s_sample
  );	

VIO : vio_0
  PORT MAP (
    clk => clk,
    probe_in0(0) => sready_conv4,   
    probe_out0(0) => reset,
    probe_out1(0) => first_start
  );
	
process(clk, reset)
--variable cnt : integer range 65 downto 0;
variable first_start_press : std_logic := '0';
begin
if reset='1' then  
    proc_sig <= '0';
    addr <= (others => '0');
    s_samples_conv4 <= (others => (others =>(others=>'0')));
    s_start_conv4 <= '0';
    first_start_press :='0';
elsif rising_edge(clk) then
    proc_sig <= '0';
    if first_start='1' and first_start_press='0'then
        addr <= (others => '0');
        proc_sig <= '1';
        first_start_press := '1';
    elsif ready_ROM='1' then
        addr <= std_logic_vector(unsigned(addr) + 1);
        s_samples_conv4(i, j) <= s_sample;
        proc_sig <= '1';        
        if j=0 and i>0 then
            j <= 29;
            i <= i-1;            
        elsif j=0 and i=0 then
            j <= 29;
            i <= 31;
            s_start_conv4 <= '1';
            addr <= (others=>'0');
        else
            i <= i;            
            j <= j-1;  
        end if;
    end if;
end if;
end process;

process(clk, reset)
begin
if reset='1' then
    ff1 <= '0';
    ready_ROM <= '0';
elsif rising_edge(clk) then
    if s_start_conv4 = '0' then
        ff1 <= proc_sig;
        if ff1='1' then
            ready_ROM <= '1';
        else
            ready_ROM <= '0';
        end if;
    else
        ready_ROM <= '0';
        ff1 <= '0';
    end if;
end if;
end process;

rd_out  <= sready_conv4;


end Behavioral;
