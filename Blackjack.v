module Blackjack(Clock, Reset, Hit, Pas, Player_H, Player_P, Dealer_H, Dealer_P, Winner, Tied, Loser, o_Memory_Adress, Sum, o_Face, o_Ace, i_Face, i_Ace, Shuffler, Finish, Ok);

input Clock, Reset, Hit, Pas, i_Face, i_Ace, Finish, Ok;

output reg [5:0] o_Memory_Adress;
output reg Player_H, Player_P, Dealer_H, Dealer_P, Winner, Tied, Loser, o_Face, o_Ace, Sum, Shuffler;

reg[5:0] Hand_D, Hand_P;
reg[1:0] var_Bj_Dealer, var_Dealer_Play, var_Shuffle, var_Time, var_Turn_2, var_P_2_Cards;
reg[3:0] EstadoAtual, EstadoFuturo;
reg[5:0] var_Memory_Adress;

    parameter 
        Begin       =   4'b0000,
        Shuffle     =   4'b0001,
        Card_Player =   4'b0010,
        Card_Dealer =   4'b0011,
        Blackjack   =   4'b0100,
        Player_Turn =   4'b0101,
        Dealer_Turn =   4'b0110,
        Take_Card   =   4'b0111,
        Measure     =   4'b1000,
        Win         =   4'b1001,
        Tie         =   4'b1010,
        Lose        =   4'b1011;
		  
    initial
        begin
            //Maquina se inicia em Begin
            EstadoFuturo = Begin;

            //Variaveis internas
            Hand_P = 5'b00000;
            Hand_D = 5'b00000;
				var_Memory_Adress = 5'b00000;
            var_P_2_Cards = 1'b0;
            var_Turn_2 = 1'b0; 
            var_Time = 1'b0;
            var_Shuffle = 1'b0;
            var_Dealer_Play = 1'b0;
            var_Bj_Dealer = 1'b0;
        end

    //Bloco para o Decodificador de Proximo Estado (DPE)
    always @ (Hit or Pas or EstadoAtual)
        begin
				
            case(EstadoAtual)
                Begin: 
							begin
                        EstadoFuturo = Shuffle;
							end

                Shuffle: 
                        if(Finish == 1'b1)
                             begin
                                EstadoFuturo = Card_Player;
										  var_Memory_Adress  = var_Memory_Adress + 1;
                            end
                        else
                            begin
                                EstadoFuturo = Shuffle;
                            end

                Card_Player:
								if(Ok == 1)
									begin
                             if(var_P_2_Cards == 1'b0)
                                begin
                                    EstadoFuturo = Card_Dealer;    
                                    var_P_2_Cards = 1'b1;
												var_Memory_Adress  = var_Memory_Adress + 1;
                                end
                            else
                                begin
                                    EstadoFuturo = Card_Dealer;
												var_Memory_Adress  = var_Memory_Adress + 1;
                                end    
									end
								else
									EstadoFuturo = Card_Player;

                Card_Dealer:
							if(Ok == 1)
								begin
                            if(var_P_2_Cards == 1'b0)
											begin
												EstadoFuturo = Card_Player;
												var_Memory_Adress  = var_Memory_Adress + 1;
											end
												
                            else
                                begin
                                    if(Hand_D == 5'b10101) // Avalia se o dealer fez Blackjack
                                        begin
                                            var_Bj_Dealer = 1'b1;
                                        end

                                    if(Hand_P < 5'b10101)
                                        begin
                                            EstadoFuturo = Player_Turn;
                                        end
                                    else
                                        begin
                                            EstadoFuturo = Blackjack;
                                        end
                                end
								end
							else
								EstadoFuturo = Card_Dealer;

                Blackjack:
                            if(Hand_P == Hand_D)
                                EstadoFuturo = Tie;
                            else
                                EstadoFuturo = Win;

                Player_Turn: case({Hit, Pas})
                                2'b00:
                                    EstadoFuturo = Player_Turn; 
                                
                                2'b11:
												begin
													EstadoFuturo = Take_Card;
													var_Memory_Adress  = var_Memory_Adress + 1;
												end

                                2'b10:
                                    begin
													EstadoFuturo = Take_Card;
													var_Memory_Adress  = var_Memory_Adress + 1;
												end

                                2'b01:  
											begin
                                    if(var_Turn_2 == 1'b0)
                                        begin
                                            EstadoFuturo = Dealer_Turn;
                                            var_Dealer_Play = 1'b1;
                                        end
                                    else
                                        EstadoFuturo = Measure;
											end
                endcase

                Dealer_Turn: 
                        if(Hand_D < 10000)
										begin
                                EstadoFuturo = Take_Card;
										  var_Memory_Adress  = var_Memory_Adress + 1;
										  end
                        else
                            begin
                                EstadoFuturo = Player_Turn;
                                var_Turn_2 = 1'b1;
                                var_Dealer_Play = 1'b0;
                            end

                Take_Card:
						if(Ok == 1)
							begin
							  if((Hand_D > 5'b10101) && (var_Dealer_Play == 1'b1))
									begin
										 EstadoFuturo = Win;
									end
							  
							  else if((Hand_P > 5'b10101) && (var_Dealer_Play == 1'b0))
									begin
										 EstadoFuturo = Lose;
									end
								
							  else if(var_Time == 1'b0)
									begin
										 EstadoFuturo = Take_Card;
									end
									
							  else
									begin
										 if(var_Dealer_Play == 1'b1)
											begin
												EstadoFuturo = Dealer_Turn;
											end
											  
										 else
											begin
												EstadoFuturo = Player_Turn;
											end
									end
								end
						else
							EstadoFuturo = Take_Card;

                Measure: 
							if((Hand_P == Hand_D) && (var_Bj_Dealer == 1'b0))
								begin
									EstadoFuturo = Tie;
								end

							else if((Hand_D > Hand_P) || (var_Bj_Dealer == 1'b1))
								begin
									EstadoFuturo = Lose;
								end
								
							else if(Hand_P > Hand_D)
								begin
									EstadoFuturo = Win;
								end

                Tie: 
							if(var_Time == 1'b0)
								begin
									EstadoFuturo = Tie;
								end

                Lose: 
							if(var_Time == 1'b0)
								begin
									EstadoFuturo = Lose;
								end

                Win: 
							if(var_Time == 1'b0)
								begin
									EstadoFuturo = Win;
								end
		endcase
	 end
	
	//Bloco para o elemento de memoria
	always @ (posedge Clock or negedge Reset)
			begin
            if(!Reset)
					begin
						EstadoAtual <= EstadoFuturo;
					end
            else   
					begin
						EstadoAtual <= Begin;
					end
	end
	
  
	//Bloco para o Decodificador de Saida (DS)
	always @ (Hit or Pas or EstadoAtual)
        begin
			Sum = 0;
			Shuffler = 0;
			Player_H = 0;
			Player_P = 0;
			Dealer_H = 0;
			Dealer_P = 0;
			Winner = 0;
			Tied = 0;
			Loser = 0;
			
            case(EstadoAtual)
						
						Shuffle:
							Shuffler = 1;
						
						Card_Player:
							Sum = 1;
						
						Card_Dealer:
							Sum = 1;
						
						Take_Card:
							Sum = 1;
							
						Blackjack:
                            if(Hand_P == Hand_D)
											begin
												Tied = 1'b1;
											end
                            else
                                begin
                                    Winner = 1'b1;
											end

						Player_Turn: case({Hit, Pas})
                                2'b11:
												begin
													Player_H = 1'b1;
													Sum = 1'b1;
												end

                                2'b10:
                                    begin
													Player_H = 1'b1;
													Sum = 1'b1;
												end
					
                                2'b01:
                                    if(var_Turn_2 == 1'b0)
													begin
														Player_P = 1'b1;
													end
                                    else
													begin
														Player_P = 1'b1;
													end
						endcase

						Dealer_Turn: 
                        if(Hand_D < 10000)
									begin
										Dealer_H = 1'b1;
										Sum = 1'b1;
									end
                        else
									begin
										Dealer_P = 1'b1;
									end

						Measure: 
                    if((Hand_P == Hand_D) && (var_Bj_Dealer == 1'b0))
								begin
									Tied = 1'b1;
									end
									
                    else if((Hand_D > Hand_P) || (var_Bj_Dealer == 1'b1))
								begin
									Loser = 1'b1;
								end

                    else if(Hand_P > Hand_D)
								begin
									Winner = 1'b1;
								end

						Tie: 
                    if(var_Time == 1'b0)
								begin
									Tied = 1'b1;
								end

						Lose: 
                    if(var_Time == 1'b0)
								begin
									Loser = 1'b1;
								end

						Win: 
                    if(var_Time == 1'b0)
								begin
									Winner = 1'b1;
								end
        endcase
	end 
endmodule