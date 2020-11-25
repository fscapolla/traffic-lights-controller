module testController();
	
	reg clk, reset;
	reg trafficSensorTv;
	reg trafficSensorNN; 
	reg trafficSensorNS;
	
	reg walkRequestTv;
	reg walkRequestNN;
	reg walkRequestNS; 
	
	wire[1:0] NN_lights;
	wire[1:0] NS_lights;
	wire[1:0] Tv_lights;
	wire[5:0] single_lights;
	wire[3:0] currentState;
	wire[1:0] currentTable;
	
	TrafficController test(.clk(clk), .reset(reset), .trafficSensorTv(trafficSensorTv), .trafficSensorNN(trafficSensorNN), .trafficSensorNS(trafficSensorNS), 
							.walkRequestTv(walkRequestTv), .walkRequestNN(walkRequestNN), .walkRequestNS(walkRequestNS),
							.lightNN(NN_lights), .lightNS(NS_lights), .lightTv(Tv_lights), .singleLights(single_lights), .currentState(currentState), .currentTable(currentTable));
	
							
	initial begin
		clk=0;
		forever #50000ns clk = ~ clk;
	end
	
	initial begin
		#1s
		reset=0; 
		trafficSensorTv=0;
		trafficSensorNS=0;
		trafficSensorNN=0;
		walkRequestTv=0;
		walkRequestNS=0;
		walkRequestNN=0;
		#10s
		walkRequestNN=1;
		trafficSensorTv=1;
		#20s
		trafficSensorNN=1;
		#30s
		trafficSensorTv=0;
		#50s
		trafficSensorTv=1;
		trafficSensorNS=1;
		#60s
		trafficSensorTv=0;
		trafficSensorNN=0;
		walkRequestTv=1;
		
		#100s
		$finish;
	end
	
endmodule