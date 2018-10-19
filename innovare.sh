#!/bin/bash
cd /app/appdynamics/innovare
data=`date +%d/%m/%Y`
url="http://was7multi/calculomultiproduto/monitoramento.liv?codigoEmpresas=14|17|18&codigoProdutos=1|2|3|4|5|6|7|8|9|10|11|12|13|14|15|16|17|18|19|20|21|22|23|24|25|26|27|28|29|30|31|32|33|34|35|36|37|38|39|40|41|42|43|44|45|46|47|48|49|50|51|52|53|54|55|56|57|58|59|60|61|62|63|64|65|66|67|68|69|70|71|72|73|74|75|76|77|78|79|80|81|82|83|84|85|86|87|88|89|90|91|92|93|94|95|96|97|98|99|100|101|102|103|104|105|106|107|108|109|110|111|112|113|114|115|116|117|118|119|120|121|122|123|124|125|126|127|128|129|130|131|132|133|134|135|136|137|138|139|140|141|142|143|144|145|146|147|148|149|150|151|152|153|154|155|156|157|158|159|160|161|162|163|164|165|166|167|168|169|170|171|172|173|174|175|176|177|178|179|180|181|182|183|184|185|186|187|188|189|190|191|192|193|194|195|196|197|198|199|200&dataInicio=$data&dataFim=$data&tipoIntegracao=2&methodMonitoramento=obterDisponibilidade"

url2="http://was7multi/calculomultiproduto/monitoramento.liv?codigoEmpresas=14|17|18&codigoProdutos=1|2|3|4|5|6|7|8|9|10|11|12|13|14|15|16|17|18|19|20|21|22|23|24|25|26|27|28|29|30|31|32|33|34|35|36|37|38|39|40|41|42|43|44|45|46|47|48|49|50|51|52|53|54|55|56|57|58|59|60|61|62|63|64|65|66|67|68|69|70|71|72|73|74|75|76|77|78|79|80|81|82|83|84|85|86|87|88|89|90|91|92|93|94|95|96|97|98|99|100|101|102|103|104|105|106|107|108|109|110|111|112|113|114|115|116|117|118|119|120|121|122|123|124|125|126|127|128|129|130|131|132|133|134|135|136|137|138|139|140|141|142|143|144|145|146|147|148|149|150|151|152|153|154|155|156|157|158|159|160|161|162|163|164|165|166|167|168|169|170|171|172|173|174|175|176|177|178|179|180|181|182|183|184|185|186|187|188|189|190|191|192|193|194|195|196|197|198|199|200&dataInicio=$data&dataFim=$data&tipoIntegracao=5&methodMonitoramento=obterDisponibilidade"

tabela="innovare"
log="log.txt"
DEBUG=0

echo "`date +%d-%m-%y_%H:%M:%S` - INFO - INICIO ======= " >> $log
echo "`date +%d-%m-%y_%H:%M:%S` - INFO - URL" >> $log

if [ ${DEBUG} == 1 ]
then
    echo "`date +%d-%m-%y_%H:%M:%S` - DEBUG - url=$url" >> $log
fi
retorno=$(curl -s -o saida.xml -w '%{http_code}' -H "Content-Type: text/xml;charset=ISO-8859-1" $url)

case $retorno in
    200)
        ;;
    *)
        echo "ERROR: Unable to execute query HTTP code="${retorno}
        echo "`date +%d-%m-%y_%H:%M:%S` - ERROR - Unable to execute query HTTP code=${retorno}" >> $log
        exit 1
        ;;
esac

read -r -a codigo <<< `cat saida.xml | grep -oP '(?<=<codigo>).*?(?=</codigo>)'`
read -r -a empresa <<< `cat saida.xml | grep -oP '(?<=<empresa>).*?(?=</empresa>)'`
cat saida.xml | grep -oP '(?<=<descricao>).*?(?=</descricao>)' | sed 's/&#237;/i/g' | sed 's/&#227;/a/g' | sed 's/&#231;/c/g' | sed 's/&#245;/o/g' | sed 's/&#233;/e/g' | sed 's/&#225;/a/g' | sed 's/&#243;/o/g' | sed 's/&#250;/u/g' | sed 's/&#226;/a/g' > descricao.txt
read -r -a sucessos <<< `cat saida.xml | grep -oP '(?<=<sucessos>).*?(?=</sucessos>)'`
read -r -a erros <<< `cat saida.xml | grep -oP '(?<=<erros>).*?(?=</erros>)'`

total=0
dados="[{"
x=1
for ((i=0;i<${#codigo[@]};i++))
do
  if [ ! $x == 1 ];
  then
    dados=$dados",{"
  fi

  dados=$dados\""codigo"\"":"${codigo[$i]}","
  dados=$dados\""tipoIntegracao"\"":2,"
  dados=$dados\""empresa"\"":"${empresa[$i]}","
  desc=`sed -n ${x}p descricao.txt`
  dados=$dados\""descricao"\"":\""$desc"\","
  dados=$dados\""sucessos"\"":"${sucessos[$i]}","
  dados=$dados\""erros"\"":"${erros[$i]}"}"
  total=$(( $total + ${sucessos[$i]}  + ${erros[$i]} ))
  x=$(( $x + 1))
done
dados=$dados"]"

if [ ${DEBUG} == 1 ]
then
    echo "`date +%d-%m-%y_%H:%M:%S` - DEBUG - dados=$dados" >> $log
fi
echo $dados > dado.json
retorno=`curl -s -o /dev/null -w '%{http_code}' -H"X-Events-API-AccountName:customer1_8523277e-e17d-4e16-b78b-e0e2da12f0ee" -H"X-Events-API-Key:8f12e3c4-6209-43e5-b358-f2165e736f5c" -H"Content-type: application/vnd.appd.events+json;v=2" -X POST "http://172.27.216.98:9080/events/publish/innovare"  -d "@dado.json" `

case $retorno in
   200)
       ;;
   *)
       echo "ERROR: Unable to create event HTTP code=$retorno"
       echo "`date +%d-%m-%y_%H:%M:%S` - ERROR - Unable to publish event HTTP code=${retorno}" >> $log
       echo "`date +%d-%m-%y_%H:%M:%S` - FIM" >> $log
       exit 1
       ;;
esac

dados="[{"
dados=$dados\""codigo"\"":0,"
dados=$dados\""tipoIntegracao"\"":2,"
dados=$dados\""empresa"\"":0,"
dados=$dados\""descricao"\"":\"Total\","
dados=$dados\""sucessos"\"":"$total","
dados=$dados\""erros"\"":0}"
dados=$dados"]"

if [ ${DEBUG} == 1 ]
then
    echo "`date +%d-%m-%y_%H:%M:%S` - DEBUG - dados=$dados" >> $log
fi

echo $dados > dado.json
retorno=`curl -s -o /dev/null -w '%{http_code}' -H"X-Events-API-AccountName:customer1_8523277e-e17d-4e16-b78b-e0e2da12f0ee" -H"X-Events-API-Key:8f12e3c4-6209-43e5-b358-f2165e736f5c" -H"Content-type: application/vnd.appd.events+json;v=2" -X POST "http://172.27.216.98:9080/events/publish/innovare"  -d "@dado.json" `

case $retorno in
   200)
       ;;
   *)
       echo "ERROR: Unable to create event HTTP code=$retorno"
       echo "`date +%d-%m-%y_%H:%M:%S` - ERROR - Unable to publish event HTTP code=${retorno}" >> $log
       echo "`date +%d-%m-%y_%H:%M:%S` - FIM" >> $log
       exit 1
       ;;
esac

echo "`date +%d-%m-%y_%H:%M:%S` - INFO - URL2" >> $log
if [ ${DEBUG} == 1 ]
then
    echo "`date +%d-%m-%y_%H:%M:%S` - DEBUG - url2=$url2" >> $log
fi
retorno=$(curl -s -o saida.xml -w '%{http_code}' -H "Content-Type: text/xml;charset=ISO-8859-1" $url2)

case $retorno in
    200)
        ;;
    *)
        echo "ERROR: Unable to execute query HTTP code="${retorno}
        echo "`date +%d-%m-%y_%H:%M:%S` - ERROR - Unable to execute query HTTP code=${retorno}" >> $log
        exit 1
        ;;
esac

read -r -a codigo <<< `cat saida.xml | grep -oP '(?<=<codigo>).*?(?=</codigo>)'`
read -r -a empresa <<< `cat saida.xml | grep -oP '(?<=<empresa>).*?(?=</empresa>)'`
cat saida.xml | grep -oP '(?<=<descricao>).*?(?=</descricao>)' | sed 's/&#237;/i/g' | sed 's/&#227;/a/g' | sed 's/&#231;/c/g' | sed 's/&#245;/o/g' | sed 's/&#233;/e/g' | sed 's/&#225;/a/g' | sed 's/&#243;/o/g' | sed 's/&#250;/u/g' | sed 's/&#226;/a/g' > descricao.txt
read -r -a sucessos <<< `cat saida.xml | grep -oP '(?<=<sucessos>).*?(?=</sucessos>)'`
read -r -a erros <<< `cat saida.xml | grep -oP '(?<=<erros>).*?(?=</erros>)'`

dados="[{"
x=1
total=0
for ((i=0;i<${#codigo[@]};i++))
do
  if [ ! $x == 1 ];
  then
    dados=$dados",{"
  fi
  dados=$dados\""codigo"\"":"${codigo[$i]}","
  dados=$dados\""tipoIntegracao"\"":5,"
  dados=$dados\""empresa"\"":"${empresa[$i]}","
  desc=`sed -n ${x}p descricao.txt`
  dados=$dados\""descricao"\"":\""$desc"\","
  dados=$dados\""sucessos"\"":"${sucessos[$i]}","
  dados=$dados\""erros"\"":"${erros[$i]}"}"
  total=$(( $total + ${sucessos[$i]}  + ${erros[$i]} ))
  x=$(( $x + 1))
done
dados=$dados"]"
echo $dados > dado.json
retorno=`curl -s -o /dev/null -w '%{http_code}' -H"X-Events-API-AccountName:customer1_8523277e-e17d-4e16-b78b-e0e2da12f0ee" -H"X-Events-API-Key:8f12e3c4-6209-43e5-b358-f2165e736f5c" -H"Content-type: application/vnd.appd.events+json;v=2" -X POST "http://172.27.216.98:9080/events/publish/innovare"  -d "@dado.json" `

case $retorno in
   200)
       ;;
   *)
       echo "ERROR: Unable to create event HTTP code=$retorno"
       echo "`date +%d-%m-%y_%H:%M:%S` - ERROR - Unable to publish event HTTP code=${retorno}" >> $log
       echo "`date +%d-%m-%y_%H:%M:%S` - FIM" >> $log
       exit 1
       ;;
esac

dados="[{"
dados=$dados\""codigo"\"":0,"
dados=$dados\""tipoIntegracao"\"":5,"
dados=$dados\""empresa"\"":0,"
dados=$dados\""descricao"\"":\"Total\","
dados=$dados\""sucessos"\"":"$total","
dados=$dados\""erros"\"":0}"
dados=$dados"]"

if [ ${DEBUG} == 1 ]
then
    echo "`date +%d-%m-%y_%H:%M:%S` - DEBUG - dados=$dados" >> $log
fi

echo $dados > dado.json
retorno=`curl -s -o /dev/null -w '%{http_code}' -H"X-Events-API-AccountName:customer1_8523277e-e17d-4e16-b78b-e0e2da12f0ee" -H"X-Events-API-Key:8f12e3c4-6209-43e5-b358-f2165e736f5c" -H"Content-type: application/vnd.appd.events+json;v=2" -X POST "http://172.27.216.98:9080/events/publish/innovare"  -d "@dado.json" `

case $retorno in
   200)
       ;;
   *)
       echo "ERROR: Unable to create event HTTP code=$retorno"
       echo "`date +%d-%m-%y_%H:%M:%S` - ERROR - Unable to publish event HTTP code=${retorno}" >> $log
       echo "`date +%d-%m-%y_%H:%M:%S` - FIM" >> $log
       exit 1
       ;;
esac


echo "`date +%d-%m-%y_%H:%M:%S` - INFO - FIM ==========" >> $log