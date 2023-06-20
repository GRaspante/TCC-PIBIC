----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 12.04.2023 11:39:50
-- Design Name: 
-- Module Name: cnn_conv1 - Behavioral
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
use work.fpupack.all;

entity cnn_conv1 is
Port (  reset : in STD_LOGIC;
        clk : in STD_LOGIC;
        start : in std_logic;
        sample_adjusted0 : in std_logic_vector (FP_WIDTH-1 downto 0);
        sample_adjusted1 : in std_logic_vector (FP_WIDTH-1 downto 0);
        sample_adjusted2 : in std_logic_vector (FP_WIDTH-1 downto 0);
        sample_adjusted3 : in std_logic_vector (FP_WIDTH-1 downto 0);
        sample_adjusted4 : in std_logic_vector (FP_WIDTH-1 downto 0);
        sample_adjusted5 : in std_logic_vector (FP_WIDTH-1 downto 0);  
        sample_adjusted6 : in std_logic_vector (FP_WIDTH-1 downto 0); 
        filter0 : in std_logic_vector (FP_WIDTH-1 downto 0);
        filter1 : in std_logic_vector (FP_WIDTH-1 downto 0);
        filter2 : in std_logic_vector (FP_WIDTH-1 downto 0);
        filter3 : in std_logic_vector (FP_WIDTH-1 downto 0);
        filter4 : in std_logic_vector (FP_WIDTH-1 downto 0);
        filter5 : in std_logic_vector (FP_WIDTH-1 downto 0);     
        filter6 : in std_logic_vector (FP_WIDTH-1 downto 0);
        bias : in std_logic_vector (FP_WIDTH-1 downto 0);
        ready : out std_logic;
        output : out std_logic_vector (FP_WIDTH-1 downto 0));

end cnn_conv1;

architecture Behavioral of cnn_conv1 is

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

signal s_mul_out0, s_mul_out1, s_mul_out2, s_mul_out3, s_mul_out4, s_mul_out5, s_mul_out6 : std_logic_vector (FP_WIDTH-1 downto 0);
signal ready_mul0, ready_mul1, ready_mul2, ready_mul3, ready_mul4, ready_mul5, ready_mul6 : std_logic;
signal s_add_out0, s_add_out1, s_add_out2, s_add_out3, s_add_out4, s_add_out5, s_add_out6 : std_logic_vector (FP_WIDTH-1 downto 0);
signal ready_add0, ready_add1, ready_add2, ready_add3, ready_add4, ready_add5, ready_add6 : std_logic;
signal s_RELU : std_logic_vector (FP_WIDTH-1 downto 0);
signal ready_RELU : std_logic;


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
                
        mult3:  multiplierfsm_v2 port map(
                reset => reset,
                clk => clk,
                op_a => sample_adjusted3,
                op_b => filter3,
                start_i => start,
                mul_out => s_mul_out3,
                ready_mul => ready_mul3);
                
        add1:   addsubfsm_v6 port map(
                reset => reset,
                clk => clk,
                op => '0',
                op_a => s_mul_out2,
                op_b => s_mul_out3,
                start_i => ready_mul2,
                addsub_out => s_add_out1,
                ready_as => ready_add1);
                
        mult4:  multiplierfsm_v2 port map(
                reset => reset,
                clk => clk,
                op_a => sample_adjusted4,
                op_b => filter4,
                start_i => start,
                mul_out => s_mul_out4,
                ready_mul => ready_mul4);

        mult5:  multiplierfsm_v2 port map(
                reset => reset,
                clk => clk,
                op_a => sample_adjusted5,
                op_b => filter5,
                start_i => start,
                mul_out => s_mul_out5,
                ready_mul => ready_mul5);
                
        mult6:  multiplierfsm_v2 port map(
                reset => reset,
                clk => clk,
                op_a => sample_adjusted6,
                op_b => filter6,
                start_i => start,
                mul_out => s_mul_out6,
                ready_mul => ready_mul6);

        add2:   addsubfsm_v6 port map(
                reset => reset,
                clk => clk,
                op => '0',
                op_a => s_mul_out4,
                op_b => s_mul_out5,
                start_i => ready_mul4,
                addsub_out => s_add_out2,
                ready_as => ready_add2);

        add3:   addsubfsm_v6 port map(
                reset => reset,
                clk => clk,
                op => '0',
                op_a => s_add_out0,
                op_b => s_add_out1,
                start_i => ready_add0,
                addsub_out => s_add_out3,
                ready_as => ready_add3);

        add4:   addsubfsm_v6 port map(
                reset => reset,
                clk => clk,
                op => '0',
                op_a => s_add_out2,
                op_b => s_mul_out6,
                start_i => ready_add2,
                addsub_out => s_add_out4,
                ready_as => ready_add4);

        add5:   addsubfsm_v6 port map(
                reset => reset,
                clk => clk,
                op => '0',
                op_a => s_add_out3,
                op_b => s_add_out4,
                start_i => ready_add3,
                addsub_out => s_add_out5,
                ready_as => ready_add5);
                
        add6:   addsubfsm_v6 port map(
                reset => reset,
                clk => clk,          
                op => '0',
                op_a => s_add_out5,
                op_b => bias,
                start_i => ready_add5,
                addsub_out => s_add_out6,
                ready_as => ready_add6);
                
-- processo para resetar o bloco e tornar finalizar a função RELU
process (clk, reset, ready_add6, s_add_out6)
    begin
    if reset='1' then
        s_RELU <= (others => '0');
        ready_RELU <= '0';
    elsif rising_edge (clk) then
        if (ready_add6 = '1') then
            ready_RELU <= '1';
        if (s_add_out6(FP_WIDTH-1 downto 0) /= "000000000000000000000000000") then
            s_RELU <= s_add_out6;
        else
            s_RELU <= (others => '0');
        end if;
    else
        ready_RELU <= '0';
        end if;
    end if;
end process;

ready <= ready_RELU;
output <= s_RELU;

end Behavioral;
