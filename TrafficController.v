module TrafficController (clk, reset, trafficSensorTv, trafficSensorNN, trafficSensorNS, walkRequestTv, walkRequestNN, walkRequestNS,
	lightNN, lightNS, lightTv, singleLights, currentState, currentTable);
	
	
	input clk;
	input reset;
	input trafficSensorTv; //Sensores de tráfico de Thevenin
	input trafficSensorNN; //Sensores de tráfico de Norton al Norte
	input trafficSensorNS; //Sensores de tráfico de Norton al Sur
	input walkRequestTv; //Requests de cruce de peatones de Thevenin
	input walkRequestNN; //Requests de cruce de peatones de Norton al Norte
	input walkRequestNS; //Requests de cruce de peatones de Norton al Sur  
	
	output[1:0] lightNN; //semáforo Norton al Norte
	output[1:0] lightNS; //semáforo Norton al Sur
	output[1:0] lightTv; //semáforo Thevenin
	output[5:0] singleLights; //6 bits que indican luces laterales y de peatones
	output[3:0] currentState; //Estado actual (para debug)
	output[1:0] currentTable; //Tabla actual (para debug)
	
	wire resetWalkTv; //Resetear requests de peaton de Thevenin
	wire resetWalkNN; //Resetear requests de peaton de Norton al Norte
	wire resetWalkNS; //Resetear requests de peaton de Norton al Sur
	
	wire pendingWalkTv;
	wire pendingWalkNN;
	wire pendingWalkNS;
	
	wire startTimer;
	wire expired;
	//wire[1:0] NN_lights;
	//wire[1:0] NS_lights;
	//wire[1:0] Tv_lights;
	//wire[5:0] single_lights;
	wire[1:0] lightNN;
	wire[1:0] lightNS;
	wire[1:0] lightTv;
	wire[5:0] singleLights;
	wire[3:0] currentState;
	wire[1:0] currentTable;
	wire[6:0] timeParameter;
	
	walkRegister wr(.clk(clk), .pushSensorTv(walkRequestTV), .pushSensorNN(walkRequestNN), .pushSensorNS(walkRequestNS), 
					.resetTv(resetWalkTv), .resetNN(resetWalkNN), .resetNS(resetWalkNS), 
					.walkFlagTv(pendingWalkTv), .walkFlagNN(pendingWalkNN), .walkFlagNS(pendingWalkNS));
					
	
	trafficFSM fsm(.clk(clk), .reset(reset), .trafficSensorTv(trafficSensorTv), .trafficSensorNN(trafficSensorNN), .trafficSensorNS(trafficSensorNS), 
					.pendingWalkTv(pendingWalkTv), .pendingWalkNN(pendingWalkNN), .pendingWalkNS(pendingWalkNS),
					.expired(expired), .startTimer(startTimer), .timeParameter(timeParameter), 
					.resetWalkTv(resetWalkTv), .resetWalkNN(resetWalkNN), .resetWalkNS(resetWalkNS), 
					.lightNN(lightNN), .lightNS(lightNS), .lightTv(lightTv), .singleLights(singleLights), .currentState(currentState), .currentTable(currentTable));
	
	Timer timer (.clk(clk), .reset(reset), .timeParameter(timeParameter), .startTimer(startTimer), .expired(expired));
	
endmodule