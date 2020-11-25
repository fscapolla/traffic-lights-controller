module trafficFSM(clk, reset, trafficSensorTv, trafficSensorNN, trafficSensorNS, pendingWalkTv, pendingWalkNN, pendingWalkNS,
	expired, startTimer, timeParameter, resetWalkTv, resetWalkNN, resetWalkNS, lightNN, lightNS, lightTv, singleLights, currentState, currentTable);
	
	//Inputs y outputs
	input clk;
	input reset;
	input trafficSensorTv; //Sensores de tr?fico de Thevenin
	input trafficSensorNN; //Sensores de tr?fico de Norton al Norte
	input trafficSensorNS; //Sensores de tr?fico de Norton al Sur
	input pendingWalkTv; //Requests de cruce de peatones de Thevenin
	input pendingWalkNN; //Requests de cruce de peatones de Norton al Norte
	input pendingWalkNS; //Requests de cruce de peatones de Norton al Sur
	input expired;
	
	output startTimer;
	output[6:0] timeParameter;
	output resetWalkTv; //Resetear requests de peaton de Thevenin
	output resetWalkNN; //Resetear requests de peaton de Norton al Norte
	output resetWalkNS; //Resetear requests de peaton de Norton al Sur
	output[1:0] lightNN; //sem?foro Norton al Norte
	output[1:0] lightNS; //sem?foro Norton al Sur
	output[1:0] lightTv; //sem?foro Thevenin
	output[5:0] singleLights; //6 bits que indican luces laterales y de peatones
	output[3:0] currentState; //Estado actual (para debug)
	output[1:0] currentTable; //Tabla actual (para debug)
	
	reg startTimer;
	reg[6:0] timeParameter;
	reg resetWalkTv;
	reg resetWalkNN;
	reg resetWalkNS;
	reg[1:0] lightNN;
	reg[1:0] lightNS;
	reg[1:0] lightTv;
	reg[5:0] singleLights;
	reg[3:0] currentState=0;
	reg[1:0] currentTable=0;
	
	// Time Parameters
	//parameter [6:0]A[11] = {17, 3, 1, 55, 3, 1, 27, 3, 1, 24, 3}; //Normal
	//parameter [6:0]B[11] = {17, 3, 1, 110, 3, 1, 14, 3, 1, 12, 3}; //Th?venin
	//parameter [6:0]C[11] = {17, 3, 1, 27, 3, 1, 14, 3, 1, 48, 3}; //Norton al Norte
	//parameter [6:0]D[11] = {17, 3, 1, 27, 3, 1, 54, 3, 1, 12, 3}; //Norton al Sur
	
	//Constantes y registros
	//reg[6:0] currentTimeTable[11]={17, 3, 1, 55, 3, 1, 27, 3, 1, 24, 3};
	//reg[6:0] nextTimeTable[11]=	{17, 3, 1, 55, 3, 1, 27, 3, 1, 24, 3};
	//reg[3:0] currentState=0;
	parameter[3:0] numberOfStates=10;	  
	
	//C?digo para los estados
	parameter[3:0] RR1=0;
	parameter[3:0] RR2=1;
	parameter[3:0] TVA1=2;
	parameter[3:0] TV=3;
	parameter[3:0] TVA2=4;
	parameter[3:0] NSA1=5;
	parameter[3:0] NSV=6;
	parameter[3:0] NSA2=7;
	parameter[3:0] NNA1=8;
	parameter[3:0] NNV=9;
	parameter[3:0] NNA2=10;

	//Código para las tablas
	parameter[1:0] A=0;
	parameter[1:0] B=1;
	parameter[1:0] C=2;
	parameter[1:0] D=3;
	
	//Par?metros para saltos internos.
	parameter[3:0] startThevenin=2;
	parameter[3:0] startNortonSur=5;
	parameter[3:0] startNortonNorte=8;	
	
	//C?digo para el sem?foro.
	parameter[1:0] RED=2'b00;
	parameter[1:0] YELLOW=2'b01;
	parameter[1:0] GREEN=2'b10;
	
	//C?digo para las luces individuales
	parameter RED_I=0;
	parameter GREEN_I=1;
	
	//Par?metros para sensores y pulsadores
	parameter sNS=0;
	parameter sNN=1;
	parameter sTV=2;
	
	//Salidas
	//C?digos para los 6 bits de salida (giro izq Norton+giro der Norton+giro izq Tv + PeatonT1 + PeatonT2 + PeatonNorton) en cada estado.
	//parameter [5:0]Giro_Peaton_Salidas[11]={6'b011100, 6'b001110, 6'b000110, 6'b000110, 6'b000110,  6'b000001, 6'b000001, 6'b000001, 6'b000001, 6'b110001, 6'b010101};
	//C?digo para los sem?foros (NN, NS, Tv) en cada estado
	//parameter [1:0]Semaforo_Salidas[11][3]= {{RED, RED, RED}, {RED, RED, RED}, {RED, RED, YELLOW}, {RED, RED, GREEN}, {RED, RED, YELLOW},  {RED, YELLOW, RED}, 
	//{RED, GREEN, RED}, {RED, YELLOW, RED},{YELLOW, RED, RED},{GREEN, RED, RED},{YELLOW, RED, RED}};
	
	always @ (posedge clk)
    begin
        if(trafficSensorTv && !trafficSensorNN && !trafficSensorNS) //si hay tr?fico s?lo en Thevenin
		    begin
				case(currentTable)
					A,
					C,
					D:
					begin
						case(currentState)
							RR1,
							RR2,
							TVA2,
							NSA2,
							TVA1,
							NNA2:
							begin
								currentTable <= B; //En estos casos puedo pasar directo al amarillo de Thevenin
								currentState <= TVA1;
								timeParameter <= 1;
								startTimer <= 1;
							end
									
							TV:
							begin
								currentTable <= B; //Aqu? ya estoy en el verde o amarillo de Thevenin, as? que o paso al verde o me quedo ac?.
								currentState <= TV;
								timeParameter <= 55;
								startTimer <= 1;
							end
									
							NSA1,
							NNA1,
							NSV,
							NNV:
							begin
								currentState <= currentState+1;  //Aqu? no puedo pasar al amarillo directo, as? que paso al pr?ximo y pongo 1 seg de count para volver r?pido a esta selecci?n y pasar al amarillo
								timeParameter <= 1;
								startTimer <= 1;
							end
						endcase
					end
					B: //Si ya estoy en la tabla B no haga nada porque todavía no expiró el tiempo
					currentTable <= B;
				endcase
			end

			else if (!trafficSensorTv && trafficSensorNN && !trafficSensorNS) //Si hay tráfico sólo en NN
			begin
				case(currentTable)
					A,
					B,
					D:
					begin
						case(currentState)
							RR1,
							RR2,
							TVA2,
							NSA2,
							NNA1,
							NNA2:
							begin
								currentTable <= C; //En estos casos puedo pasar directo al amarillo de NN
								currentState <= NNA1;
								timeParameter <= 1;
								startTimer <= 1;
							end
									
							NNV:
							begin
								currentTable <= C; //Aqu? ya estoy en el verde de NN, as? que me qued? ac?.
								currentState <= NNV;
								timeParameter <= 48;
								startTimer <= 1;
							end
									
							NSA1,
							TVA1,
							TV,
							NSV:
							begin
								currentState <= currentState+1; //Aqu? no puedo pasar al amarillo directo, as? que paso al pr?ximo y pongo 1 seg de count para volver r?pido a esta selecci?n y pasar al amarillo
								timeParameter <= 1;
								startTimer <= 1;
							end
						endcase
					end
					C:
					currentTable <= C;
				endcase
			end

			else if (!trafficSensorTv && !trafficSensorNN && trafficSensorNS) //Si sólo hay tráfico en NS
			begin
				case(currentTable)
					A,
					B,
					C:
					begin
						case(currentState)
							RR1,
							RR2,
							TVA2,
							NSA2,
							NSA1,
							NNA2:
							begin
								currentTable <= D; //En estos casos puedo pasar directo al amarillo de NS
								currentState <= NSA1;
								timeParameter <= 1;
								startTimer <= 1;
							end
									
							NSV:
							begin
								currentTable <= D; //Aqu? ya estoy en el verde de NS, as? que me qued? ac?.
								currentState <= NSV;
								timeParameter <= 54;
								startTimer <= 1;
							end
									
							TVA1,
							NNA1,
							TV,
							NNV:
							begin
								currentState <= currentState+1; //Aqu? no puedo pasar al amarillo directo, as? que paso al pr?ximo y pongo 1 seg de count para volver r?pido a esta selecci?n y pasar al amarillo
								timeParameter <= 1;
								startTimer <= 1;
							end
						endcase							
					end
					D:
					currentTable <= D;
				endcase					
			end

			else
			begin
				currentTable <= A; //En cualquier otro caso uso la tabla A
			end
    end
 
    always @ (posedge clk)
		begin
			startTimer=0;
			resetWalkTv=0; //Se ponen estas dos en cero para no llamar a m?dulo de timer o walkregister innecesariamente.
			resetWalkNN=0;
			resetWalkNS=0;
			
			if(reset) //Reseteo al primer estado de la tabla en la que estoy (creo que no es necesario usarlo)
				begin
					startTimer <= 1;
					currentTable <= A;
					timeParameter <= 17;
					currentState <= RR1;
				end


			else if (~expired) //Si expired=0, ~expired=1 y significa que seguimos dentro de un estado en el que todav?a no termin? el tiempo
				begin 
					//Actualizo salidas
					case(currentState)
						RR1:
						begin
							lightNN <= RED;
							lightNS <= RED;
							lightTv <= RED;
							singleLights <= 6'b011100;
						end
							
						RR2:
						begin
							lightNN <= RED;
							lightNS <= RED;
							lightTv <= RED;
							singleLights <= 6'b001110;
						end
						
						TVA1:
						begin
							lightNN <= RED;
							lightNS <= RED;
							lightTv <= YELLOW;
							singleLights <= 6'b000110;
						end
						
						TVA2:
						begin
							lightNN <= RED;
							lightNS <= RED;
							lightTv <= YELLOW;
							singleLights <= 6'b000110;
						end
						
						TV:
						begin
							lightNN <= RED;
							lightNS <= RED;
							lightTv <= GREEN;
							singleLights <= 6'b000110;
						end
						
						NSA1:
						begin
							lightNN <= RED;
							lightNS <= YELLOW;
							lightTv <= RED;
							singleLights <= 6'b000001;
						end
						
						NSA2:
						begin
							lightNN <= RED;
							lightNS <= YELLOW;
							lightTv <= RED;
							singleLights <= 6'b000001;
						end
						
						NSV:
						begin
							lightNN <= RED;
							lightNS <= GREEN;
							lightTv <= RED;
							singleLights <= 6'b000001;
						end
						
						NNA1:
						begin
							lightNN <= YELLOW;
							lightNS <= RED;
							lightTv <= RED;
							singleLights <= 6'b000001;
						end
						
						NNA2:
						begin
							lightNN <= YELLOW;
							lightNS <= RED;
							lightTv <= RED;
							singleLights <= 6'b010001;
						end
						
						NNV:
						begin
							lightNN <= GREEN;
							lightNS <= RED;
							lightTv <= RED;
							singleLights <= 6'b110001;
						end
					endcase
				end
			
			else
				begin
					startTimer <= 1; //En estos casos cambio de estado porque se acabó el contador.
					
					case(currentState) //Todos menos TVA1, NSA1, y NNA1 son independientes de tabla de tiempos
								RR1:
								begin
									currentState <= RR2;
									timeParameter <= 3;
								end
								
								RR2:
								begin
									if(pendingWalkNN == 1)
										begin
											currentState <= NNA1;
											timeParameter <= 1;
											resetWalkNN <= 1;
										end
									else
										begin
											currentState <= TVA1;
											timeParameter <= 1;
										end
								end
								
								TV:
								begin
									currentState <= TVA2;
									timeParameter <= 3;
								end
								
								TVA2:
								begin
									currentState <= NSA1;
									timeParameter <= 1;
								end
								
								NSV:
								begin
									currentState <= NSA2;
									timeParameter <= 3;
								end
								
								NSA2:
								begin
									if(pendingWalkTv == 1)
										begin
											currentState <= TVA1;
											timeParameter <= 1;
											resetWalkTv <= 1;
										end
									else
										begin
											currentState <= NNA1;
											timeParameter <= 1;
										end	
								end
								
								NNV:
								begin
									currentState <= NNA2;
									timeParameter <= 3;
								end
								
								NNA2:
								begin
									if(pendingWalkNN == 1)
										begin
											currentState <= NSA1;
											timeParameter <= 1;
											resetWalkNN <= 1;
										end
									else
										begin
											currentState <= RR1;
											timeParameter <= 17;
										end
								end

								TVA1:
								begin
									currentState <= TV;
									case (currentTable)
										A: timeParameter <= 55;
										B: timeParameter <= 110;
										C: timeParameter <= 27;
										D: timeParameter <= 27;
									endcase
								end

								NSA1:
								begin
									currentState <= NSV;
									case (currentTable)
										A: timeParameter <= 27;
										B: timeParameter <= 14;
										C: timeParameter <= 14;
										D: timeParameter <= 54;
									endcase
								end

								NNA1:
								begin
									currentState <= NNV;
									case (currentTable)
										A: timeParameter <= 24;
										B: timeParameter <= 12;
										C: timeParameter <= 48;
										D: timeParameter <= 12;
									endcase
								end

					endcase

				end
		end

endmodule