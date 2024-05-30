----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 07.08.2023 20:08:14
-- Design Name: 
-- Module Name: cnn_conv3b - Behavioral
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

entity cnn_conv3b is
Port (  reset : in STD_LOGIC;
        clk : in STD_LOGIC;
        startloop : in std_logic;
        sample_adjusted_aux : in aux_filter3;        
        conv3_Bias : in std_logic_vector (FP_WIDTH-1 downto 0);       
        filter_aux : in aux_filter3;     
        ready_loop : out std_logic;
        ready_soma : out std_logic;
    --    save : out std_logic;
    --    output_loopb : out out_loop;
        output_final : out std_logic_vector (FP_WIDTH-1 downto 0));
        
end cnn_conv3b;

architecture Behavioral of cnn_conv3b is
component cnn_conv3 is
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

signal s_sample_adjusted0, s_sample_adjusted1, s_sample_adjusted2 : std_logic_vector (FP_WIDTH-1 downto 0);
signal s_filter0, s_filter1, s_filter2, sconv3_Bias : std_logic_vector (FP_WIDTH-1 downto 0);
signal s_output : std_logic_vector (FP_WIDTH-1 downto 0):=(others => '0');
signal s_ready, sready_delay : std_logic := '0';
signal done, done_delay, reset_add0 : std_logic := '0';
signal sready_soma : std_logic :='0';
signal s_start, count_saida, ready31_delay : std_logic;
signal soutput_final : std_logic_vector (FP_WIDTH-1 downto 0):=(others => '0');

signal s_add_out0 : std_logic_vector (FP_WIDTH-1 downto 0); 
--s_add_out1, s_add_out2, s_add_out3, s_add_out4, s_add_out5, s_add_out6, s_add_out7, s_add_out8, s_add_out9, s_add_out10, s_add_out11, s_add_out12, s_add_out13, s_add_out14, s_add_out15: std_logic_vector (FP_WIDTH-1 downto 0);
signal ready_add0 : std_logic;
--ready_add1, ready_add2, ready_add3, ready_add4, ready_add5, ready_add6, ready_add7,ready_add8, ready_add9, ready_add10, ready_add11, ready_add12, ready_add13, ready_add14, ready_add15 : std_logic;

--signal s_add_out16, s_add_out17, s_add_out18, s_add_out19, s_add_out20, s_add_out21, s_add_out22, s_add_out23 : std_logic_vector (FP_WIDTH-1 downto 0);
--signal ready_add16, ready_add17, ready_add18, ready_add19, ready_add20, ready_add21, ready_add22, ready_add23 : std_logic;

--signal s_add_out24, s_add_out25, s_add_out26, s_add_out27 : std_logic_vector (FP_WIDTH-1 downto 0);
--signal ready_add24, ready_add25, ready_add26, ready_add27 : std_logic;

--signal s_add_out28, s_add_out29 : std_logic_vector (FP_WIDTH-1 downto 0);
--signal ready_add28, ready_add29 : std_logic;

--signal s_add_out30 : std_logic_vector (FP_WIDTH-1 downto 0);
--signal ready_add30 : std_logic;

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

conv3samples:   cnn_conv3 port map (
                reset => reset,
                clk => clk,
                start => s_start,
                sample_adjusted0 => s_sample_adjusted0,
                sample_adjusted1 => s_sample_adjusted1,
                sample_adjusted2 => s_sample_adjusted2,                             
                filter0 => s_filter0,
                filter1 => s_filter1,
                filter2 => s_filter2,               
                ready => s_ready,
                output => s_output);

add0:   addsubfsm_v6 port map(
                reset => reset_add0,
                clk => clk,
                op => '0',
                op_a => s_output_loopA,
                op_b => s_output_add0,
                start_i => count_saida,
                addsub_out => s_add_out0,
                ready_as => ready_add0);

--add1:   addsubfsm_v6 port map(
--                reset => reset,
--                clk => clk,
--                op => '0',
--                op_a => s_output_loopb(29),
--                op_b => s_output_loopb(28),
--                start_i => done,
--                addsub_out => s_add_out1,
--                ready_as => ready_add1);

--add2:   addsubfsm_v6 port map(
--                reset => reset,
--                clk => clk,
--                op => '0',
--                op_a => s_output_loopb(27),
--                op_b => s_output_loopb(26),
--                start_i => done,
--                addsub_out => s_add_out2,
--                ready_as => ready_add2);

--add3:   addsubfsm_v6 port map(
--                reset => reset,
--                clk => clk,
--                op => '0',
--                op_a => s_output_loopb(25),
--                op_b => s_output_loopb(24),
--                start_i => done,
--                addsub_out => s_add_out3,
--                ready_as => ready_add3);
                
--add4:   addsubfsm_v6 port map(
--                reset => reset,
--                clk => clk,
--                op => '0',
--                op_a => s_output_loopb(23),
--                op_b => s_output_loopb(22),
--                start_i => done,
--                addsub_out => s_add_out4,
--                ready_as => ready_add4);

--add5:   addsubfsm_v6 port map(
--                reset => reset,
--                clk => clk,
--                op => '0',
--                op_a => s_output_loopb(21),
--                op_b => s_output_loopb(20),
--                start_i => done,
--                addsub_out => s_add_out5,
--                ready_as => ready_add5);

--add6:   addsubfsm_v6 port map(
--                reset => reset,
--                clk => clk,
--                op => '0',
--                op_a => s_output_loopb(19),
--                op_b => s_output_loopb(18),
--                start_i => done,
--                addsub_out => s_add_out6,
--                ready_as => ready_add6);

--add7:   addsubfsm_v6 port map(
--                reset => reset,
--                clk => clk,
--                op => '0',
--                op_a => s_output_loopb(17),
--                op_b => s_output_loopb(16),
--                start_i => done,
--                addsub_out => s_add_out7,
--                ready_as => ready_add7);
                
--add8:   addsubfsm_v6 port map(
--                reset => reset,
--                clk => clk,
--                op => '0',
--                op_a => s_output_loopb(15),
--                op_b => s_output_loopb(14),
--                start_i => done,
--                addsub_out => s_add_out8,
--                ready_as => ready_add8);

--add9:   addsubfsm_v6 port map(
--                reset => reset,
--                clk => clk,
--                op => '0',
--                op_a => s_output_loopb(13),
--                op_b => s_output_loopb(12),
--                start_i => done,
--                addsub_out => s_add_out9,
--                ready_as => ready_add9);

--add10:   addsubfsm_v6 port map(
--                reset => reset,
--                clk => clk,
--                op => '0',
--                op_a => s_output_loopb(11),
--                op_b => s_output_loopb(10),
--                start_i => done,
--                addsub_out => s_add_out10,
--                ready_as => ready_add10);

--add11:   addsubfsm_v6 port map(
--                reset => reset,
--                clk => clk,
--                op => '0',
--                op_a => s_output_loopb(9),
--                op_b => s_output_loopb(8),
--                start_i => done,
--                addsub_out => s_add_out11,
--                ready_as => ready_add11);
                
--add12:   addsubfsm_v6 port map(
--                reset => reset,
--                clk => clk,
--                op => '0',
--                op_a => s_output_loopb(7),
--                op_b => s_output_loopb(6),
--                start_i => done,
--                addsub_out => s_add_out12,
--                ready_as => ready_add12);

--add13:   addsubfsm_v6 port map(
--                reset => reset,
--                clk => clk,
--                op => '0',
--                op_a => s_output_loopb(5),
--                op_b => s_output_loopb(4),
--                start_i => done,
--                addsub_out => s_add_out13,
--                ready_as => ready_add13);

--add14:   addsubfsm_v6 port map(
--                reset => reset,
--                clk => clk,
--                op => '0',
--                op_a => s_output_loopb(3),
--                op_b => s_output_loopb(2),
--                start_i => done,
--                addsub_out => s_add_out14,
--                ready_as => ready_add14);

--add15:   addsubfsm_v6 port map(
--                reset => reset,
--                clk => clk,
--                op => '0',
--                op_a => s_output_loopb(1),
--                op_b => s_output_loopb(0),
--                start_i => done,
--                addsub_out => s_add_out15,
--                ready_as => ready_add15);
-- --Segunda               
                
--add16:   addsubfsm_v6 port map(
--                reset => reset,
--                clk => clk,
--                op => '0',
--                op_a => s_add_out0,
--                op_b => s_add_out1,
--                start_i => ready_add0,
--                addsub_out => s_add_out16,
--                ready_as => ready_add16);
                
--add17:   addsubfsm_v6 port map(
--                reset => reset,
--                clk => clk,
--                op => '0',
--                op_a => s_add_out2,
--                op_b => s_add_out3,
--                start_i => ready_add2,
--                addsub_out => s_add_out17,
--                ready_as => ready_add17);

--add18:   addsubfsm_v6 port map(
--                reset => reset,
--                clk => clk,
--                op => '0',
--                op_a => s_add_out4,
--                op_b => s_add_out5,
--                start_i => ready_add4,
--                addsub_out => s_add_out18,
--                ready_as => ready_add18);
                
--add19:   addsubfsm_v6 port map(
--                reset => reset,
--                clk => clk,
--                op => '0',
--                op_a => s_add_out6,
--                op_b => s_add_out7,
--                start_i => ready_add6,
--                addsub_out => s_add_out19,
--                ready_as => ready_add19);

--add20:   addsubfsm_v6 port map(
--                reset => reset,
--                clk => clk,
--                op => '0',
--                op_a => s_add_out8,
--                op_b => s_add_out9,
--                start_i => ready_add8,
--                addsub_out => s_add_out20,
--                ready_as => ready_add20);
                
--add21:   addsubfsm_v6 port map(
--                reset => reset,
--                clk => clk,
--                op => '0',
--                op_a => s_add_out10,
--                op_b => s_add_out11,
--                start_i => ready_add10,
--                addsub_out => s_add_out21,
--                ready_as => ready_add21);

--add22:   addsubfsm_v6 port map(
--                reset => reset,
--                clk => clk,
--                op => '0',
--                op_a => s_add_out12,
--                op_b => s_add_out13,
--                start_i => ready_add12,
--                addsub_out => s_add_out22,
--                ready_as => ready_add22);

--add23:   addsubfsm_v6 port map(
--                reset => reset,
--                clk => clk,
--                op => '0',
--                op_a => s_add_out14,
--                op_b => s_add_out15,
--                start_i => ready_add14,
--                addsub_out => s_add_out23,
--                ready_as => ready_add23);
----Terceira

--add24:   addsubfsm_v6 port map(
--                reset => reset,
--                clk => clk,
--                op => '0',
--                op_a => s_add_out16,
--                op_b => s_add_out17,
--                start_i => ready_add16,
--                addsub_out => s_add_out24,
--                ready_as => ready_add24);
                
--add25:   addsubfsm_v6 port map(
--                reset => reset,
--                clk => clk,
--                op => '0',
--                op_a => s_add_out18,
--                op_b => s_add_out19,
--                start_i => ready_add18,
--                addsub_out => s_add_out25,
--                ready_as => ready_add25); 
                
--add26:   addsubfsm_v6 port map(
--                reset => reset,
--                clk => clk,
--                op => '0',
--                op_a => s_add_out20,
--                op_b => s_add_out21,
--                start_i => ready_add20,
--                addsub_out => s_add_out26,
--                ready_as => ready_add26);
                
--add27:   addsubfsm_v6 port map(
--                reset => reset,
--                clk => clk,
--                op => '0',
--                op_a => s_add_out22,
--                op_b => s_add_out23,
--                start_i => ready_add22,
--                addsub_out => s_add_out27,
--                ready_as => ready_add27);              
                
----Quarta
--add28:   addsubfsm_v6 port map(
--                reset => reset,
--                clk => clk,
--                op => '0',
--                op_a => s_add_out24,
--                op_b => s_add_out25,
--                start_i => ready_add24,
--                addsub_out => s_add_out28,
--                ready_as => ready_add28);
                
--add29:   addsubfsm_v6 port map(
--                reset => reset,
--                clk => clk,
--                op => '0',
--                op_a => s_add_out26,
--                op_b => s_add_out27,
--                start_i => ready_add24,
--                addsub_out => s_add_out29,
--                ready_as => ready_add29); 

----Quinta
--add30:   addsubfsm_v6 port map(
--                reset => reset,
--                clk => clk,
--                op => '0',
--                op_a => s_add_out28,
--                op_b => s_add_out29,
--                start_i => ready_add28,
--                addsub_out => s_add_out30,
--                ready_as => ready_add30);
                
--BIAS
add31:   addsubfsm_v6 port map(
                reset => reset,
                clk => clk,
                op => '0',
                op_a => s_add_out0,
                op_b => sconv3_Bias,
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
                sconv3_Bias  <= (others => '0');
                i <= 31;                          
                done <= '0';
                count_saida <= '0';
                reset_add0 <= '1';
                
            when atualiza_entradas => -- ESTADO QUE ATUALIZA AS ENTRADAS DA CONVOLUÇÃO
                s_sample_adjusted2 <= sample_adjusted_aux(i,2);
                s_sample_adjusted1 <= sample_adjusted_aux(i,1);
                s_sample_adjusted0 <= sample_adjusted_aux(i,0);                
                s_filter2 <= filter_aux(i,2);
                s_filter1 <= filter_aux(i,1);
                s_filter0 <= filter_aux(i,0); 
--                s_filter0 <= thirdConvfilter(31,i,2);
--                s_filter1 <= thirdConvfilter(31,i,1);
--                s_filter2 <= thirdConvfilter(31,i,0); 
                sconv3_Bias <= conv3_Bias;
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



