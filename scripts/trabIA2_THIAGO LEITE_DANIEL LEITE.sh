#!/bin/bash
#
# Trabalho de IA 2
# Alunos = Daniel Leite e Thiago Leite

filename=/home/oracle/IA2/casoDeTeste130.txt
cromossomos=100
maxgeracoes=100   # define um criterio de parada
intervalo_mutacao=2 	 # define o intervalo de mutacao
debug=0			 # debug 0=false, 1=algum log 2=muito log
ret=0 # usado para retorno em functions

Rows=$cromossomos

Columns=$(cat $filename | head -n 1)

echo "Cromossomo = $Rows"
echo "colunas = $Columns"

declare -a a_soma
declare -a a_pesos
declare -a g_curr
declare -a g_next
declare -a a_aptidao # mantem o resultado do calculo de aptidao, tem o mesmo numero de colunas que a variavel $Rows
declare -a alpha     # char alpha [Rows] [Columns];
                    
g_next_id=0       # sempre esta posicionado no proximo row que posso utilizar para popular a proxima geracao [g_next], ou seja, e um ponteiro
possivel="yes"    # informa se e possivel chegar numa divisao exata


echo "######### carrega pesos do arquivo##########################"
## carrega pesos de cada blocos no array
a_pesos=( $(more +2 $filename) )


## imprimir pesos que foram carregados
print_pesos ()
{
	if [ $debug -eq 1 ]; then
                echo "########### imprime pesos ############################"
        fi

	echo ${a_pesos[*]} | xargs -n $Columns

	if [ $debug -eq 1 ]; then
                echo "########### fim imprime pesos ############################"
        fi
}

load_random ()
{

	if [ $debug -eq 1 ]; then
                echo "########### load random geracao  ####################"
        fi
	
	let "LIMIT = $Rows * $Columns - 1"


	for ((a=0; a<=LIMIT; a++))
        do                                               
               g_curr[$a]="-1"               
	       g_next[$a]="-1"
        done


        for ((r=0; r<Rows; r++))
	do		
		for c in 0 1 2 3 4 5 6 7
		do	
			achou=0
        		while [ $achou -eq 0 ]
			do				
				let "col=$RANDOM%$Columns"
				let "index=$r * $Columns + $col"					

				if [ "${g_curr[$index]}" -eq "-1" ]; then
					achou=1
					g_curr[$index]=$c		
				fi	
							        	
				if [ $debug -eq 1 ]; then
					echo "	-row = $r"
					echo "	-c = $c"
					echo "	-col=$col"
					echo "	-index=$index"
					echo "	-achou=$achou"					
				fi
			done
		done
	done	

	for ((a=0; a<=LIMIT; a++))
	do	
		val=$RANDOM
		let "val %= 8"
		
		if [ "${g_curr[$a]}" -eq "-1" ]; then

			if [ $debug -eq 1 ]; then
				echo "	-configura valor"
				echo "  -g_curr[a]= ${g_curr[$a]}"
			fi

			g_curr[$a]=$val
		fi

		if [ $debug -eq 1 ]; then
			echo "	-g_curr[a]= ${g_curr[$a]}"			
		fi
	done

	if [ $debug -eq 1 ]; then
                echo "########### fim load random geracao  ############################"
        fi
	
}

calcula_aptidao ()
{
	if [ $debug -eq 1 ]; then
		echo "########### Calcula aptidao ############################"
	fi


	declare -a param_array
	

	param_array=( `echo "$1"` )

	local row=0
	local index
		
	for ((r=0; r<Rows; r++))
	do		
		for((c=0; c<=7; c++))
		do
		   let "index= $r * 8 + $c" 		   


		   a_soma[$index]=0
		done
	done

	while [ "$row" -lt "$Rows" ]
	do
		
		for ((i=0; i<=7; i++))
		do
			local column=0

			#echo "antes cliente=$i"
			while [ "$column" -lt "$Columns" ]		
			do
				let "index= $row * $Columns + $column"	
				
				if [ $debug -eq 1 ]; then
					echo "-> andamento distribuicao"
					echo "	-index distribuicao $index"
					echo "	-valor ${param_array[index]}" 
					echo "	-cliente $i"
					echo "	-pesos ${a_pesos[column]}"
					echo "	-row $row de $Rows"
					echo "	-column $column de $Column"
				fi

				if [ "${param_array[index]}" -eq "$i" ]; then
 				  	let "index= $i + $row * 8"		  							
					let "a_soma[$index]+=${a_pesos[column]}"
				fi 
				
				if [ $debug -eq 1 ]; then				
					echo "-> imprimir pesos"
					print_pesos
				
					echo "-> imprimir somas"
					parameter=`echo ${a_soma[@]}`
					print_soma "$parameter"				
	
					echo "-> imprimir geracao corrente"
					parameter=`echo ${param_array[@]}`
					print_alpha "$parameter"
					echo
					echo
				fi 

				let "column += 1"
			done		
		done
		let "row += 1"
	done
               
	if [ $debug -eq 1 ]; then
		echo "############### fim calculo aptidao #####################"
	fi
       
}


print_alpha ()
{
	if [ $debug -eq 1 ]; then
            echo "######### print alpha #################"
        fi
	
	declare -a param_array
	param_array=( `echo "$1"` )

	local row=0
	local index
	
	while [ "$row" -lt "$Rows" ]   #  Print out in "row major" order:
	do                             #+ columns vary,
                               #+ while row (outer loop) remains the same.
	  local column=0

	  echo -n "       "            #  Lines up "square" array with rotated one.
  
	  while [ "$column" -lt "$Columns" ]
	  do
	    let "index = $row * $Columns + $column"
	    echo -n "${param_array[index]} "  # param_array[$row][$column]
	    let "column += 1"
	  done

	  let "row += 1"
	  echo
	done  


	 if [ $debug -eq 1 ]; then
            echo "######### fim print alpha #################"
        fi
}

print_soma ()
{
	if [ $debug -eq 1 ]; then
            echo "######### print soma #################"
        fi	

	declare -a arr
	arr=( `echo "$1"` )

	local index	 

	for ((r=0; r<Rows; r++))
        do                
                for((c=0; c<=7; c++))
                do
		   let "index= $r * 8 + $c" 		   		    
			
		   if [ $debug -eq 1 ]; then
                	echo -n "${arr[index]} "
		   fi
                done		 
		echo ""
        done

        if [ $debug -eq 1 ]; then
            echo "######### fim print soma #################"
        fi
}

soma_dos_pesos_entrada ()
{
	if [ $debug -eq 1 ]; then
            echo "######### soma pesos #################"
    	fi



	declare -a arr
        arr=( `echo "$1"` )

        local soma=0
        for ((c=0; c<Columns; c++))
        do                
	         
		let "soma+=${arr[c]}"                                            
        done

        if [ $debug -eq 1 ]; then
	    echo "	- soma=$soma"
            echo "######### fim soma pesos #################"
        fi

	ret=$soma
}

calcula_elitismo ()
{

    if [ $debug -eq 1 ]; then
	    echo "######### calculando elitismo #################"
    fi

    declare -a curr
    curr=( `echo "$1"` )
 

    declare -a soma
    soma=( `echo "$2"` )

    local index
    local media
    local id_elite=0
    local desvio_elite=-1
    local desvio

    #copia o id da row com  
    for ((r=0; r<Rows; r++))
    do
	 media="0"

         if [ $debug -eq 1 ]; then
		 echo "-> calcula a media do cromossomo $r"		
	 fi

	 
         for((c=0; c<=7; c++))
         do	     	     	     
             let "index= $r * 8 + $c"
	     let "media= $media + ${soma[$index]}"             
		
             if [ $debug -eq 1 ]; then
  		     echo "	-soma soma[index]= ${soma[$index]}"
		     echo "	-index= $index"
		     echo "	-media= $media"
	     fi
         done
         if [ $debug -eq 1 ]; then
		 echo "		-media final $media"	 
	 fi

	 let "media=$media / 8"
         
         if [ $debug -eq 1 ]; then
		 echo "		-cromossomo $r media $media"
		 echo "-> Verificando os desvios"
         fi
	 
	
	 # verifica desvio
	 desvio=0
	 for((c=0; c<=7; c++))
         do
             let "index= $r * 8 + $c"
	

             ## soma os desvios pegando sempre o valor absoluto	        
	    # if [ "$media" -gt "${soma[$index]}" ]; then 
	     #    let "desvio=$desvio + $media - ${soma[$index]}"
	     #else
	       let "val=${soma[$index]} - $media" 
	        desvio=`echo $desvio + $val^2| bc`
	     #fi
	 done
	 
	 if [ $debug -eq 1 ]; then
		 echo "		-cromossomo $r desvio $desvio"
	 fi

	 # quem tiver o primeiro menor desvio vence
	 if [ $desvio_elite -eq -1 ] || [ $desvio_elite -gt $desvio ]; then
		id_elite=$r
		desvio_elite=$desvio

   	        if [ $debug -eq 1 ]; then
			echo "	-id_elite=$id_elite"
			echo "	-desvio elite=$desvio_elite"
		fi
	 fi        
	
	 res=`echo "sqrt($desvio / $Columns)"| bc`
	 a_aptidao[$r]=$res
     done

    if [ $debug -eq 1 ]; then
 	   echo "	- final id_elite=$id_elite"
           echo "	- final desvio_elite=$desvio_elite"
    fi
    
    echo "   - Cromossomo $id_elite selecionado para elistismo"


    # copia id_elite para proxima geracao 
    let "c_ini_curr=$Columns * $id_elite"
    let "c_fim_curr=$c_ini_curr + $Columns"
    let "c_ini_next=$g_next_id * $Columns"
   
    if [ $debug -eq 1 ]; then
	    echo "-> copia o id de elite para proxima geracao"
	    echo "	- g_next_id=$g_next_id"
    fi

    while [ $c_ini_curr -lt $c_fim_curr ]
    do		
	g_next[$c_ini_next]=${curr[$c_ini_curr]}

	if [ $debug -eq 1 ]; then
		echo "	- c_ini_curr=$c_ini_curr"
		echo "	- c_fim_curr=$c_fim_curr"
		echo "	- c_ini_next=$c_ini_next"
		echo "	- g_next[c_ini_next]=${g_next[$c_ini_next]}"
		echo "	- curr[c_ini_curr]=${curr[$c_ini_curr]}"
	fi
	
	let "c_ini_curr+=1"
	let "c_ini_next+=1"
    done
   
    let "g_next_id+=1"       

    if [ $debug -eq 1 ]; then
	    echo "      -g_next_id=$g_next_id"
            echo "######### fim calculando elitismo #################"
    fi

}

calcula_mutacao ()
{
    
    if [ $debug -eq 1 ]; then
	echo "############ procedimento mutacao ##########################"
    fi

    local random_col
    local random_row
    local posicao1
    local posicao2
    local cliente
    
    let "random_col=( $RANDOM%$Columns)" 
    let "random_row=( $RANDOM%$Rows )"
    
    #calcula posicao para mutacao
    let "posicao1=$random_row * $Columns + $random_col" 

    if [ $debug -eq 1 ]; then
	    echo "-> parametros mutacao"
	    echo "	-random_col=$random_col" 
	    echo " 	-random_row=$random_row"
	    echo "	-posicao1=$posicao1"
    fi
    
    posicao2=$posicao1
    while [ $posicao1 -eq $posicao2 ] 
    do
	let "random_col=($RANDOM%$Columns)" 
    
        #calcula posicao para mutacao
        let "posicao2=$random_row * $Columns + $random_col" 
    done
    
    if [ $debug -eq 1 ]; then
            echo "      -posicao2=$posicao2"
	    echo "	- antes troca g_next[posicao1]=${g_next[$posicao1]}"
	    echo "	- antes troca g_next[posicao2]=${g_next[$posicao2]}"
    fi

    #troca de posicao os clientes dentro do cromossomo na proxima geracao
    aux=${g_next[$posicao1]}
    g_next[$posicao2]=${g_next[$posicao2]}
    g_next[$posicao1]=$aux       

    echo "   - Cromossomo $random_row selecionado para mutacao"
    echo "   - posicoes $posicao1 e $posicao2 selecionadas para troca"

    if [ $debug -eq 1 ]; then
	echo "      - depois troca g_next[posicao1]=${g_next[$posicao1]}"
        echo "      - depois troca g_next[posicao2]=${g_next[$posicao2]}"


	echo "  - geracao corrente"
        parameter=`echo ${g_curr[@]}`
        print_alpha "$parameter"

        echo "      - geracao proxima"
        parameter=`echo ${g_next[@]}`
        print_alpha "$parameter"

        echo "############ fim procedimento mutacao ##########################"
    fi

}

torneio ()
{
	if [ $debug -eq 1 ]; then
		echo "############ procedimento torneio ##########################"
	fi

	local id_1        
	local id_2
	local vencedor
	
	
	let "id_1=$RANDOM%Rows"

	if [ $debug -eq 1 ]; then
		echo "-> gerando valores randomicos para o torneio"
		echo "	- id_1 gerado = $id_1"
	fi

	id_2=$id_1
	while [ $id_2 -eq $id_1 ] 
	do
		let "id_2=$RANDOM%$Rows"
		
		if [ $debug -eq 1 ]; then
			echo "  - id_2 gerado = $id_2"
		fi
	done

	
	if [ ${a_aptidao[$id_2]} -lt ${a_aptidao[$id_1]} ]; then
		vencedor=$id_2
	else 
		vencedor=$id_1
	fi
		
	if [ $debug -eq 1 ]; then
		echo "-> escolhidos torneio"
	        echo "	- cromossomo1 row id_1=$id_1"
		echo "	- aptidao[$id_1]=${a_aptidao[$id_1]}"
	        echo "	- cromossomo2 row id_2=$id_2"
        	echo "	- aptidao[$id_2]=${a_aptidao[$id_2]}"
		echo "	- vencedor row id_=$vencedor"
		echo " "
		echo "########### final torneio #################################"
	fi

	echo "  Cromossomos selecionados para o torneio $id_1 e $id_2 com vencedor $vencedor"


	return $vencedor
}

divisao_ok ()
{

	if [ $debug -eq 1 ]; then
		echo "########## divisao_ok ##########################"
		echo "-> avaliar cada cromossomo se esta bem dividido"
	fi

	local index=0
	local div_ok=0

	while [ $index -lt $Rows ]	
	do
		if [ ${a_aptidao[$index]} -eq "0" ]; then					
			div_ok=1

			if [ $debug -eq 1 ]; then
				echo "---> encontrado cromossomo $index com desvio padrao zero <----"
				echo "		- div_ok=$div_ok"
			fi
			
			break
		fi 
		let "index+=1"				


		if [ $debug -eq 1 ]; then
			echo "	- cromossomo $index nok! desvio=${a_aptidao[$index]}"
		fi

	done

	if [ $debug -eq 1 ]; then
		echo "######### fim divisao ok #######################"
	fi

	return $div_ok
}

copia_geracao ()
{
	if [ $debug -eq 1 ]; then
		echo "############ copia geracao ##################"	
	fi

	g_next_id=0		
	g_curr=${g_next[@]}
	g_next=""

	let "LIMIT = $Rows * $Columns - 1"
        for ((a=0; a<=LIMIT; a++))
        do
               g_next[$a]="-1"
        done
		
	if [ $debug -eq 1 ]; then
		echo "-> copia g_next para g_curr"
		echo "	- g_next_id=$g_next_id"

		echo "	- geracao corrente"
        	parameter=`echo ${g_curr[@]}`
	        print_alpha "$parameter"

	        echo "geracao proxima"
		parameter=`echo ${g_next[@]}`
	        print_alpha "$parameter"

	
		echo "########### fim copia geracao ###############"	
	fi
}

calcula_corte ()
{   
    if [ $debug -eq 1 ]; then
    	echo "############ calculando corte ############"
    fi
      	        
    local num_tot #numero de posicoes para selecionar
    local id_mae
    local id_pai
    
    #busca os cromossomos para torneio
    torneio
    id_pai=$?

    torneio
    id_mae=$?


    let "num_tot=$RANDOM%$Columns"

    echo "   - posicao selecionada para corte N=$num_tot"


    if [ $debug -eq 1 ]; then
	    echo "-> faz torneio e chega no pai e mae"
	    echo "	- cromossomo id_pai=$id_pai"
	    echo "	- cromossomo id_mae=$id_mae"
	    echo "	- N a posicao do corte=$num_tot"
    fi
 
    
    local index_ini_next
    local index_fim_next
    local index_ini_curr_pai
    local index_fim_curr_pai
    local index_ini_curr_mae
    local index_fim_curr_mae

    let "index_ini_next=$g_next_id * $Columns"
    let "index_fim_next=$index_ini_next + $num_tot"
    let "index_ini_curr_pai=$id_pai * $Columns"
    let "index_fim_curr_pai=$index_ini_curr_pai + $num_tot"
    let "index_ini_curr_mae=$id_mae * $Columns + $num_tot"
    let "index_fim_curr_mae=$index_ini_curr_mae + $Columns"


    if [ $debug -eq 1 ]; then
	    echo "-> parametro para filho 1 - parte 1"
	    echo "	-index_ini_next=$index_ini_next"
	    echo "	-index_fim_next=$index_fim_next"
	    echo "	-index_ini_curr_pai=$index_ini_curr_pai"
	    echo "	-index_fim_curr_pai=$index_fim_curr_pai"
	    echo "	-index_ini_curr_mae=$index_ini_curr_mae"
	    echo "	-index_fim_curr_mae=$index_fim_curr_mae"
    fi

    #Filho 1
    while [ $index_ini_next -lt $index_fim_next ]
    do		
        g_next[$index_ini_next]=${g_curr[$index_ini_curr_pai]}

        let "index_ini_next+=1"
	let "index_ini_curr_pai+=1"
    done

    let "index_fim_next=$index_ini_next + $Columns - $num_tot"    

    if [ $debug -eq 1 ]; then
    	    echo "-> parametro para filho 1 - parte 2"
	    echo "      -index_ini_next=$index_ini_next"
	    echo "      -index_fim_next=$index_fim_next"
	    echo "      -index_ini_curr_pai=$index_ini_curr_pai"
	    echo "      -index_fim_curr_pai=$index_fim_curr_pai"
	    echo "      -index_ini_curr_mae=$index_ini_curr_mae"
	    echo "      -index_fim_curr_mae=$index_fim_curr_mae"
    fi


    while [ $index_ini_next -lt $index_fim_next ]
    do		
        g_next[$index_ini_next]=${g_curr[$index_ini_curr_mae]}

        let "index_ini_next+=1"
	let "index_ini_curr_mae+=1"
    done

    let "g_next_id+=1"
    let "index_ini_next=$g_next_id * $Columns"
    let "index_fim_next=$index_ini_next + $num_tot"
    let "index_ini_curr_mae=$id_mae * $Columns"
    let "index_fim_curr_mae=$index_ini_curr_mae + $num_tot"

    if [ $debug -eq 1 ]; then
    	    echo "-> parametro para filho 2 - parte 1"
	    echo "	-g_next_id=$g_next_id"
	    echo "      -index_ini_next=$index_ini_next"
	    echo "      -index_fim_next=$index_fim_next"
	    echo "      -index_ini_curr_pai=$index_ini_curr_pai"
	    echo "      -index_fim_curr_pai=$index_fim_curr_pai"
	    echo "      -index_ini_curr_mae=$index_ini_curr_mae"
	    echo "      -index_fim_curr_mae=$index_fim_curr_mae"
    fi

    if [ $g_next_id -lt $Rows  ]; then
	    #Filho 2
	    while [ $index_ini_next -lt $index_fim_next ]
	    do
        	g_next[$index_ini_next]=${g_curr[$index_ini_curr_mae]}

	        let "index_ini_next+=1"
	        let "index_ini_curr_mae+=1"
	    done

	    let "index_fim_next=$index_ini_next + $Columns - $num_tot"

	    if [ $debug -eq 1 ]; then
		    echo "-> parametro para filho 2 - parte 2"
		    echo "      -g_next_id=$g_next_id"
		    echo "      -index_ini_next=$index_ini_next"
		    echo "      -index_fim_next=$index_fim_next"
		    echo "      -index_ini_curr_pai=$index_ini_curr_pai"
		    echo "      -index_fim_curr_pai=$index_fim_curr_pai"
		    echo "      -index_ini_curr_mae=$index_ini_curr_mae"
		    echo "      -index_fim_curr_mae=$index_fim_curr_mae"
	    fi


	    while [ $index_ini_next -lt $index_fim_next ]
	    do
        	g_next[$index_ini_next]=${g_curr[$index_ini_curr_pai]}
	
	        let "index_ini_next+=1"
	        let "index_ini_curr_pai+=1"
	    done

	    let "g_next_id+=1"

	    if [ $debug -eq 1 ]; then
    		    echo "-> resultado "
		    echo "      -g_next_id=$g_next_id"
   		    
		    echo "  - geracao corrente"
        	    parameter=`echo ${g_curr[@]}`
	            print_alpha "$parameter"
	
        	    echo "	- geracao proxima"
	            parameter=`echo ${g_next[@]}`
        	    print_alpha "$parameter"
		    	    
		    echo "############ fim calculando corte ############"

	    fi	    

    else
	echo "  - nao e necessario utilizar o filho 2"
    fi
}


if [ $debug -eq 1 ]; then
	echo "-> verifica se e possivel a distribuicao"
fi

# determina se e possivel chegar no melhor valor
if [ $Columns -lt 8 ]; then
	possivel="no"
	
	if [ $debug -eq 1 ]; then
		echo "	-menos de 8 colunas nao tem como distribuir corretamente, somente possivel aproximado"
	fi
else 
	soma=0

	parameter=`echo ${a_pesos[@]}`
	echo ${a_pesos[@]}
	soma_dos_pesos_entrada "$parameter"
	soma=$ret
		
        let "valor=$soma%8"
		

	if [ $valor -gt 0 ]; then 
		possivel="no" 
	fi
       	
fi

if [ $debug -eq 1 ]; then 	 
	echo "	-soma dos pesos=$soma"
	echo "	-soma dos pesos mod 8=$valor"
	echo "	-possivel calcula=$possivel"		
fi

echo "########### Imprimir parametros ###############"
echo "	- Cromossomos = $Rows"
echo "	- Colunas = $Columns"
echo "	- Arquivo utilizado = $filename"
echo "	- max geracoes = $maxgeracoes"
echo "	- debug = $debug"
echo "	- intervalo mutacao = $intervalo_mutacao"
echo " 	- utilizados pesos: "
print_pesos
echo "########## Inicio do processamento ###########"


echo " carrega geracao inicial randomicamente"
## Carrega valores randomicos para primeira geracao
parameter=`echo ${g_curr[@]}`
load_random "$parameter"

echo "-> imprimir dados carregado randomincamente"
## imprimir geracao
parameter=`echo ${g_curr[@]}`
print_alpha "$parameter"

divisao=0
for ((g=0; g<=maxgeracoes; g++))
do

	echo "faz calculo da aptidao"
	parameter=`echo ${g_curr[@]}`
	calcula_aptidao "$parameter"

	echo "calcula elitismo"	
	parameter1=`echo ${g_curr[@]}`
	parameter2=`echo ${a_soma[@]}`
	calcula_elitismo "$parameter1" "$parameter2"	
	
	if [ $debug -eq 1 ]; then	
		echo "geracao curr"
		parameter=`echo ${g_curr[@]}`
		print_alpha "$parameter"

		echo "geracao next"
		parameter=`echo ${g_next[@]}`
		print_alpha "$parameter"
	fi
	
	while [ $g_next_id -lt $Rows ]
	do
		echo "calcula corte"
		calcula_corte 
	done


	## deve ser ao final, depois que o lopping calcular toda a proxima geracao
	## verifica se a gracao atual deve sofre a mutacao
	echo "verificar mutacao"
	let "val=$g%$intervalo_mutacao"

	if [ $val -eq 0 ]; then
		echo "calcula mutacao"
        	parameter=`echo ${g_curr[@]}`
	        calcula_mutacao "$parameter"
	fi

	echo "copia geracao"	
	copia_geracao	
	
	echo "possivel=$possivel"
	if [ $possivel ==  'yes' ]; then	
		echo "verifica se divisao ok"
		divisao_ok

		if [ $? -eq "1" ]; then 
			echo "esta bem distribuido os valores"
			break 
		fi
	fi

	echo "dados da geracao corrente = $g"
        parameter=`echo ${g_curr[@]}`
        print_alpha "$parameter"

	echo "desvios"
	for ((r=0; r<Rows; r++))
	do
		echo " - desvio cromossomo $r=${a_aptidao[$r]}"
	done
done

echo "########### final processamento ###################"

exit 0
