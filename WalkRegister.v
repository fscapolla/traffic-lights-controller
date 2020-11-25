/*
Detecta el pulsador, y genera una salida en 1 que informa a la máquina de estados principal
que se presionó el pulsador. Continúa enviando la señal hasta que recibe la señal de reset de la
máquina de estados, que indica que ya se resolvió el pasaje de peatones y puede volver a cero. Hasta que 
no llega la señal de reset no detecta más pulsadores. Se necesitaría un módulo de estos por cada pulsador.

Inputs: clk, pushSensor, reset
Outputs: walkFlag (vale 1 si detecta un pulsador, cero en otros casos).
*/

module walkRegister(clk, pushSensorTv, pushSensorNN, pushSensorNS, resetTv, resetNN, resetNS, walkFlagTv, walkFlagNN, walkFlagNS);
	input clk;
	input pushSensorTv;
	input pushSensorNN;
	input pushSensorNS;
	input resetTv;
	input resetNN;
	input resetNS;
	output walkFlagTv;
	output walkFlagNN;
	output walkFlagNS;
	reg walkFlagTv;
	reg walkFlagNN;
	reg walkFlagNS;
	
	always @ (posedge clk)
		begin
			walkFlagTv <= resetTv ? 0 : walkFlagTv ? walkFlagTv : pushSensorTv;
			walkFlagNN <= resetNN ? 0 : walkFlagNN ? walkFlagNN : pushSensorNN;
			walkFlagNS <= resetNS ? 0 : walkFlagNS ? walkFlagNS : pushSensorNS;
		end
endmodule


/*module walkRegister(clk, pushSensor, reset, walkFlag);
	input clk;
	input[2:0] pushSensor;
	input[2:0] reset;
	output[2:0] walkFlag;
	reg[2:0] walkFlag;
	
	always @ (posedge clk)
		begin
			walkFlag[0] <= reset[0] ? 0 : walkFlag[0] ? walkFlag[0] : pushSensor[0]; //Thevenin
			walkFlag[1] <= reset[1] ? 0 : walkFlag[1] ? walkFlag[1] : pushSensor[1]; //NortonNorte
			walkFlag[2] <= reset[2] ? 0 : walkFlag[2] ? walkFlag[2] : pushSensor[2]; //NortonSur
		end
endmodule*/


/*module testWalkRegister2();
	reg clk;
	reg pushSensor;
	reg reset;
	wire walkFlag;
	
	walkRegister test(clk, pushSensor, reset, walkFlag);
	
	//clock de 100 ns
	initial begin
		clk=0;
		forever #50ns clk = ~clk;
	end
	
	initial begin
		reset=1;
		pushSensor=0;
	
		#100ns reset=0;
		pushSensor=1;
		
		#100ns reset=1;
		
		#100ns reset=0;
		
		#100ns pushSensor=0;
		
		#100ns pushSensor=1;
		
		#100ns pushSensor=1;
		
		$finish;
		
	end

endmodule*/