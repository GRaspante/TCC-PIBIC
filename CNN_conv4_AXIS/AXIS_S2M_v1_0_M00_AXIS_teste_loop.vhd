library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;
use work.fpupack.all;

entity AXIS_S2M_v1_0_M00_AXIS is
	generic (
		-- inicio: parametros do usuario 
        
		-- fim: parametros do usuario 
		
		-- Tamanho dos dados que o slave recebe.
		C_S_AXIS_TDATA_WIDTH	: integer	:= 32;		
		
		-- Largura do barramento de endereço S_AXIS. \\
		-- O escravo aceita os endereços de leitura e escrita com largura C_M_AXIS_TDATA_WIDTH.		
		C_M_AXIS_TDATA_WIDTH	: integer	:= 32;
		
		-- O numero de ciclos de clock que o mestre \\
		-- aguardará antes de iniciar qualquer transacao (opcional).
		C_M_START_COUNT	: integer	:= 32
	);
	port (
		-- inicio: portas do usuario 		
		INTR_CONV4      : out std_logic;
		-- fim: portas do usuario 
		
		-- Global ports
		-- AXI4Stream slave: Clock.
		S_AXIS_ACLK	: in std_logic;
		-- AXI4Stream slave: Reset.
		S_AXIS_ARESETN	: in std_logic;
		-- AXI4Stream slave: Ready -> indicando para o mestre (DMA) que esta apto para receber os dados.
		S_AXIS_TREADY	: out std_logic;
		-- AXI4Stream slave: TDATA -> entrada do slave para dados de tamanho C_S_AXIS_TDATA_WIDTH.
		S_AXIS_TDATA	: in std_logic_vector(C_S_AXIS_TDATA_WIDTH-1 downto 0);
		-- AXI4Stream slave: indica quais bytes sao validos (opcional).
		S_AXIS_TSTRB	: in std_logic_vector((C_S_AXIS_TDATA_WIDTH/8)-1 downto 0);
		-- AXI4Stream slave: indica qual o ultimo valor da transacao.
		S_AXIS_TLAST	: in std_logic;
		-- AXI4Stream slave: indica quando os dados da trasacao sao validos.
		S_AXIS_TVALID	: in std_logic;
		
		-- AXI4Stream mestre: Clock
		M_AXIS_ACLK	: in std_logic;
		-- AXI4Stream mestre: Reset
		M_AXIS_ARESETN	: in std_logic;
		-- AXI4Stream mestre: TVALID indica que o mestre está conduzindo uma transferência válida.\\
		-- Uma transferência ocorre quando tanto TVALID quanto TREADY sao iguais a 1.
		M_AXIS_TVALID	: out std_logic;
		-- AXI4Stream mestre: entrada do mestre para dados de tamanho C_M_AXIS_TDATA_WIDTH.
		M_AXIS_TDATA	: out std_logic_vector(C_M_AXIS_TDATA_WIDTH-1 downto 0);
		-- AXI4Stream mestre: indica quais bytes sao validos (opcional).
		M_AXIS_TSTRB	: out std_logic_vector((C_M_AXIS_TDATA_WIDTH/8)-1 downto 0);
		-- AXI4Stream mestre: ndica qual o ultimo valor da transacao.
		M_AXIS_TLAST	: out std_logic;
		-- AXI4Stream mestre: TREADY indica que o slave (DMA) pode aceitar uma transferência no ciclo atual.
		M_AXIS_TREADY	: in std_logic
	);
end AXIS_S2M_v1_0_M00_AXIS;

architecture implementation of AXIS_S2M_v1_0_M00_AXIS is
component cnn_conv4b is
    Port (  reset_conv4 : in STD_LOGIC;
            clk : in STD_LOGIC;
            start_conv4 : in STD_LOGIC;
            samples_conv4 : in in_Conv4;
--            filter_conv4 : in filter4;
--            bias_conv4 : in biasConv;
            ready_conv4: out STD_LOGIC;            
            output_conv4: out out_Conv2);
--            out_conv4: out std_logic_vector (FP_WIDTH-1 downto 0));--ILA
end component;

	-- Quantidade de dados de saída                                              
	constant NUMBER_OF_OUTPUT_WORDS : integer := 960;                                   

	-- Função chamada clogb2 que retorna um inteiro com o valor do teto do logaritmo na base 2.\\
	-- Essa função é útil para determinar o número de bits necessários para representar um determinado valor em binário.
	function clogb2 (bit_depth : integer) return integer is                  
	 	variable depth  : integer := bit_depth;                               
	 	variable count  : integer := 1;                                       
	 begin                                                                   
	 	 for clogb2 in 1 to bit_depth loop  -- Works for up to 32 bit integers
	      if (bit_depth <= 2) then                                           
	        count := 1;                                                      
	      else                                                               
	        if(depth <= 1) then                                              
	 	       count := count;                                                
	 	     else                                                             
	 	       depth := depth / 2;                                            
	          count := count + 1;                                            
	 	     end if;                                                          
	 	   end if;                                                            
	   end loop;                                                             
	   return(count);        	                                              
	 end;                                                                    

	-- WAIT_COUNT_BITS e o tamanho do contador (opcional).                       
	constant  WAIT_COUNT_BITS  : integer := clogb2(C_M_START_COUNT-1);    
	 
	-- bit_num e o número mínimo de bits necessários para \\
	-- endereçar uma profundidade de um FIFO de tamanho 'depth'.
	constant bit_num : integer := clogb2(NUMBER_OF_OUTPUT_WORDS-1);                                      
	                                                                                  
	-- Estados da FSM do mestre  
	type state is ( IDLE,        -- Estado idle.
	                SEND_STREAM);  -- Neste estado, os dados do fluxo são enviados através de M_AXIS_TDATA.
	signal  mst_exec_state : state; 
	
	-- Ponteiro da matriz de entrada do mestre, usado no exemplo de FIFO.                                               
	signal read_pointer : integer range 0 to bit_num-1;                               

	-- AXI-Stream Master
	-- wait counter. The master waits for the user defined number of clock cycles before initiating a transfer. --(opcional)
    -- signal count	: std_logic_vector(WAIT_COUNT_BITS-1 downto 0); --(opcional)
	
	-- streaming data valid
    signal axis_tvalid	: std_logic;
	-- streaming data valid delayed by one clock cycle
	signal axis_tvalid_delay	: std_logic;
	-- Last of the streaming data 
	signal axis_tlast	: std_logic;
	-- Last of the streaming data delayed by one clock cycle
	signal axis_tlast_delay	: std_logic;
	-- FIFO implementation signals
	signal stream_data_out	: std_logic_vector(C_M_AXIS_TDATA_WIDTH-1 downto 0);
	signal tx_en	: std_logic;
	-- Indica o fim das transacoes do mestre.
	signal tx_done	: std_logic;
    
    -- AXI-Stream Slave
    -- Quantidade de dados de entrada.  
	constant NUMBER_OF_INPUT_WORDS  : integer := 960;
	-- bit_num_slave e o número mínimo de bits necessários para \\
	-- endereçar uma profundidade de um FIFO de tamanho 'depth'.
	constant bit_num_slave  : integer := clogb2(NUMBER_OF_INPUT_WORDS-1);
	
	-- Estados da FSM do slave 
	type state_slave is ( IDLE,  -- Estado idle. 
	                WRITE_FIFO); -- Neste estado, os dados do fluxo são recebidos através de S_AXIS_TDATA. 	
	signal  mst_exec_state_slave : state_slave;
	
	-- TREADY do escravo.
	signal axis_tready	: std_logic;
	-- FIFO implementation signals
	signal  byte_index : integer;    
	-- FIFO write enable
	signal fifo_wren : std_logic;
	-- FIFO full flag
	signal fifo_full_flag : std_logic; --(opcional)
	-- FIFO write pointer
	signal write_pointer : integer range 0 to bit_num_slave-1 ;
	-- sink has accepted all the streaming data and stored in FIFO
	signal writes_done : std_logic;	
    -- type FIFO_TYPE is array (0 to (NUMBER_OF_INPUT_WORDS-1)) of std_logic_vector((C_S_AXIS_TDATA_WIDTH-1)downto 0); -- variavel para o FIFO do slave.
    -- signal stream_data_fifo	:  FIFO_TYPE; -- usado para receber a entrada de dados (opcional).
	
	-- TLAST do escravo com um delay de um ciclo de clock.
    signal S_AXIS_TLAST_DELAY: std_logic;
    
    -- CNN
    signal sreset_conv4, sready_conv4, sready_conv4_delay: std_logic;
    signal s_samples_conv4 : in_Conv4;
    signal soutput_conv4: out_Conv2;
    signal i : integer range 0 to (numberOfFilters-1):= numberOfFilters-1;
    signal j : integer range 0 to (outConvs-1):= outConvs-1;
    
    signal k : integer range 0 to (numberOfFilters-1):= numberOfFilters-1;
    signal l : integer range 0 to (outConvs-1):= outConvs-1;
    
begin

	-- I/O Connections assignments

	M_AXIS_TVALID	<= axis_tvalid_delay;
	M_AXIS_TDATA	<= stream_data_out;
	M_AXIS_TLAST	<= axis_tlast_delay;
	M_AXIS_TSTRB	<= (others => '1');
    INTR_CONV4      <= tx_done;

	-- Control state machine implementation (master)                                               
	process(M_AXIS_ACLK)                                                                        
	begin                                                                                       
	  if (rising_edge (M_AXIS_ACLK)) then                                                       
	    if(M_AXIS_ARESETN = '0') then                                                           
	      -- Synchronous reset (active low)                                                     
	      mst_exec_state      <= IDLE;                                                          
	     -- count <= (others => '0');                                                             
	    else                                                                                    
	      case (mst_exec_state) is                                                              
	        when IDLE     =>                                                                    
	          -- Aguarda o ready da camada conv.                                                           
	          if (sready_conv4_delay = '1')then
	            mst_exec_state <= SEND_STREAM;
	          else
	            mst_exec_state <= IDLE;
	          end if;                                                 
	          --else                                                                              
	          --  mst_exec_state <= IDLE;                                                         
	          --end if;                                            
	                                                                                            
	        when SEND_STREAM  =>                                                                
	          -- Apos o ready, envia a matriz de saida                                       
	          if (tx_done = '1') then                                                           
	            mst_exec_state <= IDLE;                                                         
	          else                                                                              
	            mst_exec_state <= SEND_STREAM;                                                  
	          end if;                                                                           
	                                                                                            
	        when others    =>                                                                   
	          mst_exec_state <= IDLE;                                                           
	                                                                                            
	      end case;                                                                             
	    end if;                                                                                 
	  end if;                                                                                   
	end process;                                                                                
    --tvalid generation
	--axis_tvalid e igual a 1 quando a FSM esta no estado de envio de dados
	axis_tvalid <= '1' when (mst_exec_state = SEND_STREAM) else '0';
	                                                                                               
	-- AXI tlast generation                                                                        
	-- axis_tlast e ativado quando os indices da matriz de saida estao iguais a 0 e o estado atual e send_stream                                                             
	axis_tlast <= '1' when ((l=0 and k=0) and (mst_exec_state = SEND_STREAM)) else '0';                                                                                             
	-- Delay the axis_tvalid and axis_tlast signal by one clock cycle                              
	-- to match the latency of M_AXIS_TDATA                                                        
	process(M_AXIS_ACLK)                                                                           
	begin                                                                                          
	  if (rising_edge (M_AXIS_ACLK)) then                                                          
	    if(M_AXIS_ARESETN = '0') then                                                              
	      axis_tvalid_delay <= '0';                                                                
	      axis_tlast_delay <= '0';     
	      sready_conv4_delay <= '0';                                                            
	    else  
          axis_tvalid_delay <= axis_tvalid;                                                                
	      axis_tlast_delay <= axis_tlast;       
	      sready_conv4_delay <= sready_conv4;	         
	    end if;                                                                                    
	  end if;                                                                                      
	end process;                                                                                   

	-- processo de envio da matriz de saida.
	process(M_AXIS_ACLK)                                                       
	begin                                                                            
	  if (rising_edge (M_AXIS_ACLK)) then                                            
	    if(M_AXIS_ARESETN = '0') then                                                
	      read_pointer <= 0;                                                         
	      tx_done  <= '0';          
	    else                                                                         
	      if (read_pointer <= NUMBER_OF_OUTPUT_WORDS-1) then                         
	        if (tx_en = '1') then 
                if l=0 and k>0 then
                    l <= 29;
                    k <= k-1; 
                elsif l=1 and k=0 then
                    l <= 0;
                    k <= 0;
                    tx_done <= '1';
                elsif l=0 and k=0 then
                    l <= 29;
                    k <= 31;
                    read_pointer <= 0;
                    tx_done <= '0';
                else
                    k <= k;            
                    l <= l-1; 
                end if;                                
	          read_pointer <= read_pointer + 1;                       
	        end if;                              
	      end  if;                                                                   
	    end  if;                                                                     
	  end  if;                                                                       
	end process;                                                                     


	-- tx_en indica que a transacao e valida quando e igual a 1.

	tx_en <= M_AXIS_TREADY and axis_tvalid;                                   
                                                        
	                                                                                
	-- Streaming output data is read from FIFO                                      
	  process(M_AXIS_ACLK)                                                          
	  variable  sig_one : integer := 1;	                                           
	  begin                                                                         
	    if (rising_edge (M_AXIS_ACLK)) then                                         
	      if(M_AXIS_ARESETN = '0') then                                             
	    	stream_data_out <= std_logic_vector(to_unsigned(sig_one,C_M_AXIS_TDATA_WIDTH));  
	      elsif (tx_en = '1') then -- && M_AXIS_TSTRB(byte_index)                   
	        stream_data_out <= soutput_conv4(k, l) & "00000";
	      end if;                                                                   
	     end if;                                                                    
	   end process;                                                                 

	-- AXIS SLAVE
    S_AXIS_TREADY	<= axis_tready;
	-- FSM
	process(S_AXIS_ACLK)
	begin
	  if (rising_edge (S_AXIS_ACLK)) then
	    if(S_AXIS_ARESETN = '0') then
	      -- Synchronous reset (active low)
	      mst_exec_state_slave      <= IDLE;
	    else
	      case (mst_exec_state_slave) is
	        when IDLE     => 
			  -- Aguarda tvalid
	          if (S_AXIS_TVALID = '1')then
	            mst_exec_state_slave <= WRITE_FIFO;
	          else
	            mst_exec_state_slave <= IDLE;
	          end if;
	      
	        when WRITE_FIFO => 
	          -- Recebe os dados
	          if (writes_done = '1') then --quando finiliza retorna ao estado inicial
	            mst_exec_state_slave <= IDLE;
	          else
	            mst_exec_state_slave <= WRITE_FIFO;
	          end if;
	        
	        when others    => 
	          mst_exec_state_slave <= IDLE;
	        
	      end case;
	    end if;  
	  end if;
	end process;
	-- AXI Streaming Sink 
	-- 
	-- The example design sink is always ready to accept the S_AXIS_TDATA  until
	-- the FIFO is not filled with NUMBER_OF_INPUT_WORDS number of input words.
	axis_tready <= '1' when ((mst_exec_state_slave = WRITE_FIFO) and (write_pointer <= NUMBER_OF_INPUT_WORDS-1)) else '0';
    
    process(S_AXIS_ACLK)
    begin
        if (rising_edge (S_AXIS_ACLK)) then
          S_AXIS_TLAST_DELAY <= S_AXIS_TLAST;  
        end if;
    end process;
    
	process(S_AXIS_ACLK)
	begin
	  if (rising_edge (S_AXIS_ACLK)) then
	    if(S_AXIS_ARESETN = '0') then
	      write_pointer <= 0;
	      writes_done <= '0';
	    else
	      if (write_pointer <= NUMBER_OF_INPUT_WORDS-1) then
	        if (fifo_wren = '1') then
	          write_pointer <= write_pointer + 1;
                if j=0 and i>0 then
                    j <= 29;
                    i <= i-1;    
                elsif j=1 and i=0 then
                    j <= 0;
                    i <= 0;
                    writes_done <= '1';
                elsif j=0 and i=0 then
                    j <= 29;
                    i <= 31;
                    write_pointer <= 0;
                else
                    i <= i;            
                    j <= j-1;  
                    writes_done <= '0';
                end if;
	        end if;
	      end  if;
	    end if;
	  end if;
	end process;

	-- FIFO write enable generation
	fifo_wren <= S_AXIS_TVALID and axis_tready;
	  
	  -- Streaming input data is stored in FIFO
	  process(S_AXIS_ACLK)
	  begin
	    if (rising_edge (S_AXIS_ACLK)) then
	      if (fifo_wren = '1') then
	        s_samples_conv4(i, j) <= S_AXIS_TDATA(31 downto 5);
	      end if;  
	    end  if;
	  end process; 	
	
	-- Add user logic here
	sreset_conv4 <= not M_AXIS_ARESETN;
	
    CONV4: cnn_conv4b port map (    reset_conv4       => sreset_conv4,
                                    clk               => M_AXIS_ACLK,
                                    start_conv4       => S_AXIS_TLAST_DELAY,
                                    ready_conv4       => sready_conv4,
                                    samples_conv4     => s_samples_conv4,        
                                    output_conv4      => soutput_conv4);
	-- User logic ends

end implementation;
