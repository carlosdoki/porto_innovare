# porto_innovare
Criacao da tabela de eventos para os dados do Innovare

Criar a tabela com o comando

``curl -X POST "http://<servidor de eventos>/events/schema/innovare" -H"X-Events-API-AccountName:<global_account>" -H"X-Events-API-Key:<API_KEY>" -H"Content-type: application/vnd.appd.events+json;v=2" -d '{"schema" : { "codigo" : "integer", "empresa" : "integer" , "descricao" : "string", "sucessos" : "integer", "erros" : "integer" , "tipoIntegracao" : "integer"  } }'``


Cadastrar no CRONTAB 

``crontab -e``

``*/1 * * * * /app/appdynamics/innovare/innovare.sh``