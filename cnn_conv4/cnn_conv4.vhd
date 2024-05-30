----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 08.08.2023 11:35:06
-- Design Name: 
-- Module Name: cnn_conv4 - Behavioral
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

entity cnn_conv4 is
Port (  reset : in STD_LOGIC;
        clk : in STD_LOGIC;
        startloop : in std_logic;
        sample_adjusted_aux : in aux_filter4;        
        conv4_Bias : in std_logic_vector (FP_WIDTH-1 downto 0);       
        filter_aux : in aux_filter4;     
        ready_loop : out std_logic;
        ready_soma : out std_logic;
--      save : out std_logic;
        --output_loopb : out out_loop;
        output_final : out std_logic_vector (FP_WIDTH-1 downto 0));
end cnn_conv4;

architecture Behavioral of cnn_conv4 is
component multiplierfsm_v2 is
    port ( reset 	 :  in std_logic; 
	       clk	 	 :  in std_logic;          
	 	   op_a	 	 :  in std_logic_vector(FP_WIDTH-1 downto 0);
           op_b	 	 :  in std_logic_vector(FP_WIDTH-1 downto 0);
		   start_i	 :  in std_logic;
           mul_out   : out std_logic_vector(FP_WIDTH-1 downto 0);
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

--signal s_output_loopb : out_loop;

signal s_output_loopA : std_logic_vector (FP_WIDTH-1 downto 0);
signal s_output_add0 : std_logic_vector (FP_WIDTH-1 downto 0) := (others => '0');

signal s_sample_adjusted0, sconv4_Bias : std_logic_vector (FP_WIDTH-1 downto 0);
signal s_filter0 : std_logic_vector (FP_WIDTH-1 downto 0);
signal s_output : std_logic_vector (FP_WIDTH-1 downto 0):=(others => '0');
signal s_ready, sready_delay: std_logic := '0';
signal done, done_delay, reset_add0 : std_logic := '0';
signal sready_soma : std_logic := '0';
signal s_start, ready31_delay, count_saida : std_logic;
signal soutput_final : std_logic_vector (FP_WIDTH-1 downto 0):=(others => '0');

signal s_add_out0 : std_logic_vector (FP_WIDTH-1 downto 0);
signal ready_add0 : std_logic;

signal s_add_out31 : std_logic_vector (FP_WIDTH-1 downto 0);
signal ready_add31 : std_logic;

signal i : integer range 0 to (numberOfFilters-1):= numberOfFilters-1;

TYPE estados is (inicio, atualiza_entradas, espera_resultado, reg_saida, soma, fim);
signal estado_atual, proximo_estado : estados;

begin

ready_loop <= done and count_saida;
ready_soma <= ready31_delay;
--output_loopb <= s_output_loopb;
output_final <= soutput_final;

conv1samples:   multiplierfsm_v2 port map (
                reset => reset,
                clk => clk,
                start_i => s_start,
                op_a => s_sample_adjusted0,
                op_b => s_filter0,
                ready_mul => s_ready,
                mul_out => s_output);

add0:   addsubfsm_v6 port map(
                reset => reset_add0,
                clk => clk,
                op => '0',
                op_a => s_output_loopA,
                op_b => s_output_add0,
                start_i => count_saida,
                addsub_out => s_add_out0,
                ready_as => ready_add0);
--BIAS
add31:   addsubfsm_v6 port map(
                reset => reset,
                clk => clk,
                op => '0',
                op_a => s_add_out0,
                op_b => sconv4_Bias,
                start_i => done_delay,
                addsub_out => s_add_out31,
                ready_as => ready_add31);   
                                               
state_reg: process(clk, reset)
begin
    if reset = '1' then
        estado_atual <= inicio;
    elsif rising_edge (clk) then
        estado_atual <= proximo_estado;
    end if;
end process;

ready_delay: process(clk)
begin
    if rising_edge(clk) then
        ready31_delay <= ready_add31;
    end if;
end process;

next_state_logic: process(clk)
begin
    if rising_edge(clk) then
        case estado_atual is
        when inicio =>
            if startloop = '1' then            
                proximo_estado <= atualiza_entradas;
            else
                proximo_estado <= inicio;
            end if;
            
        when atualiza_entradas =>
            if done = '1' then
                proximo_estado <= soma;
            else
                proximo_estado <= espera_resultado;
            end if;
            
        when espera_resultado =>
            if (s_ready or sready_delay) = '1' then
                proximo_estado <= reg_saida;
            else
                proximo_estado <= espera_resultado;
            end if;         
           
        when reg_saida =>           
            proximo_estado <= atualiza_entradas;
             
        when soma =>
            if (sready_soma or ready31_delay) = '1' then
                proximo_estado <= fim;
            else
                proximo_estado <= soma;
            end if;
        
        when fim =>
               proximo_estado <= inicio;
               
        when others =>
            proximo_estado <= inicio;
        end case;
    end if;
end process;

sready_soma <= '1' when (estado_atual = soma and ready_add31 = '1') else '0';
s_start <= '1' when (estado_atual = atualiza_entradas and proximo_estado = espera_resultado) else '0';
done_delay <= '1' when (estado_atual = atualiza_entradas and proximo_estado = soma) else '0';

output_logic: process(clk, estado_atual)
    begin
        if rising_edge(clk) then
            case estado_atual is
            when inicio => -- ESTADO INICIAL QUE ZERA OS VALORES DE ENTRADA                
--                s_sample_adjusted0 <= (others => '0'); 
--                s_sample_adjusted1 <= (others => '0');
--                s_sample_adjusted2 <= (others => '0');                
--                s_filter0 <= (others => '0');
--                s_filter1 <= (others => '0');
--                s_filter2 <= (others => '0');              
                s_output_loopA <= (others => '0');
                s_output_add0 <= (others => '0');
               -- output_loopb <=((others =>(others => '0')));
                soutput_final <= (others => '0');                
                sconv4_Bias  <= (others => '0');
                i <= 31;                          
                done <= '0';
                count_saida <= '0';
                reset_add0 <= '1';
                
            when atualiza_entradas => -- ESTADO QUE ATUALIZA AS ENTRADAS DA CONVOLUÇÃO               
                s_sample_adjusted0 <= sample_adjusted_aux(i);
                s_filter0 <= filter_aux(i); 
--                s_filter0 <= thirdConvfilter(31,i);
                sconv4_Bias <= conv4_Bias;
                i <= i;                
                reset_add0 <= '0';
                
            when espera_resultado =>                
                   sready_delay <= s_ready;                  
                
            when reg_saida => -- ESTADO QUE VARIA O i E j E REGISTRAS OS RESULTADOS DA CON
                if count_saida = '0' then 
                    s_output_loopA <= s_output;
                    s_output_add0 <= s_add_out0;
                    if i<=0 then                        
                        i <= i;                       
                        done <= '1';
                    else
                        i <= i-1; 
                    end if;
                end if;
               count_saida <= not count_saida;
                    
            when soma =>
                if (ready_add31 = '1') then
                    if (s_add_out31(FP_WIDTH-1) = '0') then --RELU                        
                        soutput_final <= s_add_out31;
                    else                        
                        soutput_final <= (others => '0');                                               
                    end if;                                  
                end if;            
            
            when fim =>               
               
                
            when others => -- outros estados               
               i <= i;    
    end case;
end if;
end process;


end Behavioral;