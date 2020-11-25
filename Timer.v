module Timer (clk, reset, timeParameter, startTimer, expired);
	//Timer cuenta los tiempos según timeParameter.
	//Inputs: 
	//			clk->clock de 10kHZ.
	//			reset->si reset=1 se resetea el clock.
	//			timeParameter->el tiempo que correspondea contar.
	//			startTimer-> si startTimer=1, comienza a contar
	
	input clk;
	input reset;
	input[6:0] timeParameter;
	input startTimer;
	
	output expired;
	reg expired;
	
	//count contiene el conteo actual
	reg[6:0] count;
	
	//Conteo en ciclos de clock de 10kHZ
	reg[13:0] clkCycleCount;
	
	//Parámetros para conteo
	parameter MAXCOUNT=7'b1111111;
	parameter ZEROCOUNT=7'b0000000;
	parameter ONECOUNT=7'b0000001;
	parameter CLK_COUNT_AFTER_ONE_SECOND= 14'd9999;
	parameter CLK_ZERO_COUNT=14'b0;
	
	always @(posedge clk)
		begin
			expired <= 0; 
			
			//El contador de ciclos va de 0 a 9999 (es decir, cuenta 1 segundo).
			if(clkCycleCount == CLK_COUNT_AFTER_ONE_SECOND || reset==1)
				clkCycleCount <= CLK_ZERO_COUNT;
			else
				clkCycleCount <= clkCycleCount+1;
			
			if(reset) //Si se resetea, automáticamente se pone expired en cero.
				begin
					expired <= 0;
					count <= MAXCOUNT;
			 	end
				 
			else if(startTimer)	 //Si es la primera vez, startTimer==1, luego cargo la tabla de tiempos e inicializo todo.
				begin
					expired <= 0;
					clkCycleCount <= CLK_ZERO_COUNT;
					count <= timeParameter;
				end
			
			else if (clkCycleCount==CLK_COUNT_AFTER_ONE_SECOND) //Si cuento un segundo de clock, reseteo el contador de ciclos y disminuyo en uno la cantidad e segundos que falta contar
				begin
					expired <= (count==ONECOUNT); //Veo si ya terminé de contar los N segundos que correspondían.
					count <= count-1; //Disminuyo en uno el contador
				end
		end
endmodule




//testbench para el Timer


/*module testTimer();	
	reg reset;
	reg[6:0] timeParameter;
	reg startTimer;
	wire expired;
	wire oneHztmp;
	reg clk;
	
	Timer test(clk, reset, timeParameter, startTimer, expired);
	
	/*Tasks para ayudar en la verificación
	task assertCycleCount;
		input[13:0]	clkCycleCount;
		if(test.clkCycleCount !== clkCycleCount)
			begin
				$display("error");
				$display("expected: %d", clkCycleCount);
				$display("got: %d", test.clkCycleCount);
				$stop();
			end
	endtask
	
	task assertExpired;
		input exp;
		if(test.expired !== exp)
			begin
				$display("error: expired");
				$display("expected: %d", exp);
				$display("got: %d", test.expired);
				$stop();
			end
	endtask
	
	//Comienza testeo
	initial begin
		clk=0;
		forever #100000ns clk = ~ clk;
	end
	
	initial begin
		$display("starting test");
		
		reset=0;
		timeParameter = 5;	 
		startTimer = 0;
		#1s
		
		//assetCycleCount(14'd0);
		//assertExpired(0); 
		
		reset=0;
		startTimer=1;
		
		#1s
		//assetCycleCount(14'd0);
		//assertExpired(0); 
		
		startTimer=0;
		
		#1s
		//assetCycleCount(14'd1);
		//assertExpired(0); 
		
		startTimer=0;
		
		#1s
		//assetCycleCount(14'd2);
		//assertExpired(0); 
		
		startTimer=0;
		
		#1s
		//assetCycleCount(14'd9997);
		//assertExpired(0); 
		
		startTimer=0;
		
		#1s
		//assetCycleCount(14'd9998);
		//assertExpired(0); 
		
		startTimer=0;
		
		#1s
		//assetCycleCount(14'd9990);
		//assertExpired(0); 
		
		startTimer=0;
		
		#1s
		//assetCycleCount(14'd0);
		//assertExpired(1); 
		
		startTimer=0;
		
		#1s
		//assetCycleCount(14'd1);
		//assertExpired(0); 
		
		startTimer=0;
		
		#14s
		//assetCycleCount(14'd2);
		//assertExpired(0); 
		
		startTimer=0;
		$finish;
		//$display ("Passed Test");
	end	
	
endmodule*/