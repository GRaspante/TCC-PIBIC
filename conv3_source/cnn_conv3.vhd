----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 17.07.2023 19:17:05
-- Design Name: 
-- Module Name: cnn_conv2 - Behavioral
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


entity cnn_conv3 is
Port (  reset : in STD_LOGIC;
        clk : in STD_LOGIC;
        start : in std_logic;
        sample_adjusted0 : in std_logic_vector (FP_WIDTH-1 downto 0);
        sample_adjusted1 : in std_logic_vector (FP_WIDTH-1 downto 0);
        sample_adjusted2 : in std_logic_vector (FP_WIDTH-1 downto 0);        
        filter0 : in std_logic_vector (FP_WIDTH-1 downto 0);
        filter1 : in std_logic_vector (FP_WIDTH-1 downto 0);
        filter2 : in std_logic_vector (FP_WIDTH-1 downto 0);       
        ready : out std_logic;
        output : out std_logic_vector (FP_WIDTH-1 downto 0));
end cnn_conv3;

architecture Behavioral of cnn_conv3 is

component multiplierfsm_v2 is
    port (  reset : in std_logic;
            clk : in std_logic;
            op_a : in std_logic_vector(FP_WIDTH-1 downto 0);
            op_b : in std_logic_vector(FP_WIDTH-1 downto 0);
            start_i : in std_logic;
            mul_out : out std_logic_vector(FP_WIDTH-1 downto 0);
            ready_mul : out std_logic);
    end component;
    
component addsubfsm_v6 is
    port (  reset : in std_logic;
            clk : in std_logic;
            op : in std_logic;
            op_a : in std_logic_vector(FP_WIDTH-1 downto 0);
            op_b : in std_logic_vector(FP_WIDTH-1 downto 0);
            start_i : in std_logic;
            addsub_out : out std_logic_vector(FP_WIDTH-1 downto 0);
            ready_as : out std_logic);
end component;

signal s_mul_out0, s_mul_out1, s_mul_out2 : std_logic_vector (FP_WIDTH-1 downto 0);
signal ready_mul0, ready_mul1, ready_mul2 : std_logic;
signal s_add_out0, s_add_out1 : std_logic_vector (FP_WIDTH-1 downto 0);
signal ready_add0, ready_add1 : std_logic;
signal s_out : std_logic_vector (FP_WIDTH-1 downto 0);
signal s_ready : std_logic;


begin
        mult0:  multiplierfsm_v2 port map(
                reset => reset,
                clk => clk,
                op_a => sample_adjusted0,
                op_b => filter0,
                start_i => start,
                mul_out => s_mul_out0,
                ready_mul => ready_mul0);
        
        mult1:  multiplierfsm_v2 port map(
                reset => reset,
                clk => clk,
                op_a => sample_adjusted1,
                op_b => filter1,
                start_i => start,
                mul_out => s_mul_out1,
                ready_mul => ready_mul1);

        add0:   addsubfsm_v6 port map(
                reset => reset,
                clk => clk,
                op => '0',
                op_a => s_mul_out0,
                op_b => s_mul_out1,
                start_i => ready_mul1,
                addsub_out => s_add_out0,
                ready_as => ready_add0);
                
        mult2:  multiplierfsm_v2 port map(
                reset => reset,
                clk => clk,
                op_a => sample_adjusted2,
                op_b => filter2,
                start_i => start,
                mul_out => s_mul_out2,
                ready_mul => ready_mul2);
        
        add1:   addsubfsm_v6 port map(
                reset => reset,
                clk => clk,
                op => '0',
                op_a => s_mul_out2,
                op_b => s_add_out0,
                start_i => ready_add0,
                addsub_out => s_add_out1,
                ready_as => ready_add1);
                
-- Processo para resetar o bloco e finalizar o loop mais interno

process (clk, reset)
    begin
    if reset='1' then
        s_out <= (others => '0');
        s_ready <= '0';
    elsif rising_edge (clk) then
        if (ready_add1 = '1') then
            s_ready <= '1';            
            s_out <= s_add_out1;
        else
            s_ready <= '0';
        end if;
    end if;
end process;

-- Atribuicao das I/O
ready <= s_ready;
output <= s_out;

end Behavioral;
