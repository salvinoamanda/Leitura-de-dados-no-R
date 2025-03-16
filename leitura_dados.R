#-------------------------------- Leitura dos Dados ----------------------------

# Carregando pacotes
library (devtools)  # Facilidade em desenvolvimento e instalação de pacotes
library (read.dbc)  # Leitura de arquivos no formato DBC
library (dplyr)     # Manipulação e transformação de Dados
library (lubridate) # Manipulação e conversão de data e hora 
library (readxl)    # Leitura de arquivos Excel (.xls e .xlsx)
library (stringr)   # Manipulação de strings
library(foreign)    # Importa e exporta arquivos de diversos formatos estatísticos

# Limpar ambiente
rm (list = ls ())

# Coleta de lixo em caso de memória não utilizada
gc ()

# Seleciona o diretório de trabalho
setwd ("C:/caminho/para/sua/pasta")  # <-- Altere para o caminho em que deseja
getwd ()                             #     trabalhar

#-------------------------------------------------------------------------------

# Faz a leitura dos arquivos com tratamento de erros, identificando caso algum
# dado esteja corrompido ou com algum outro problema
ler_arquivo <- function (arq)
{
  # Tenta ler o elemento
  tryCatch (
    {
      read.dbc :: read.dbc (arq)
    },
    
    # Em caso de erro
    error = function (e)
    {
      cat ("Erro ao ler o arquivo: ", arq, "\n", "Mensagem de erro:",
           e$message, "\n")
      
      # Retorna NULL em caso de erro
      return (NULL)
    }
  )
}

# Função para ler os dados por partes ou total
selecionar_parte <- function (inicio, fim, dados_pasta, arq, selecao)
{
  for (i in inicio : fim)
  {
    dados <- ler_arquivo (arq[i])
    cat ("arquivo: ", arq[i], "\n")
    
    if (is.null (dados))
    {
      cat ("Falha encontrada! ", arq[i], "\n")
    }
    else
    {
      dados_pasta[[i]] <- dados %>% select (all_of (selecao))
    }
    
    # Coleta de lixo
    gc()
  }
  
  return (dados_pasta)
}

#-------------------------------------------------------------------------------

# Lista todas as subpastas
subpastas <- list.dirs (full.names = TRUE, recursive = FALSE)
print (subpastas)

# Define a subpasta de determinando estado em dl (dados para ler)
dl <- subpastas[1]

# Verifica todos os arquivos com extensão ".dbc" (caso for outra extensão, altere)
arquivos <- list.files (path = dl, pattern = "\\.dbc$", full.names = TRUE,
                        ignore.case = TRUE)

# Inicializa dados_pasta como uma lista vazia
dados_pasta <- list()

#---------------------------------- Blocos -------------------------------------

# Início e fim do arquivo para ler
inicio = 1
fim = length (arquivos)

# Especifica as colunas desejadas
dados_selecionados <- c ("Selecione", "os", "campos", "que", "deseja")  # <-- IMPORTANTE: altere para
                                                                        #     os campos desejados

# Realiza a leitura do arquivo em partes
dados_pasta <- selecionar_parte (inicio, fim, dados_pasta, arquivos, dados_selecionados)

# Remove elementos NULL da lista
dados_pasta <- dados_pasta[!sapply (dados_pasta, is.null)]

# Coletar lixo para liberar memória
gc ()

#------------------------------------ DBF --------------------------------------
# Salvar dados_pasta
write.dbf (do.call (rbind, dados_pasta), "dados_pasta.dbf")

# Salvar dados_outros_anos
write.dbf (do.call (rbind, dados_outros_anos), "dados_outros_anos.dbf")

#------------------------------------ CSV --------------------------------------

# Salvar dados_pasta
write.csv (do.call (rbind, dados_pasta), "dados_pasta.csv", row.names = FALSE)

# Salvar dados_outros_anos
write.csv(do.call (rbind, dados_outros_anos), "dados_outros_anos.csv", row.names = FALSE)
