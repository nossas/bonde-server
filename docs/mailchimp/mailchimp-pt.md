# Mailchimp
## Criando uma conta
1. Abra a URL https://login.mailchimp.com/signup no seu navegador
2. Insira as informações:
    a. email: Email real, será usado para sua comunicação com mailchimp. Será validado pelo site.
    b. username: usado para seu login, use um fácil de ser lembrado.
    c. seernha: Será verificada a força da sua senha
3. Cheque seu email por mensagem "Activate Your MailChimp Account", e ative através do link "Activate Account".
4. Complete suas informações.

## Localizando a chave da api (api key)
1. No canto superior esquerdo, lolilize seu username. Clique, e um menu surgirá. Clique na opção 'account'.
2. Clique em 'Extras', e selecione 'API keys'
3. Em 'Your API keys', selecione 'Create a Key'
4. Agora é só copiar o campo 'API key'. (No nosso sistema, corresponde ao campo 'mailchimp_api_key'

## Criando uma lista de emails
1. Pressione 'Lists' no menu. Clique 'Create List'.
2. Preencha as informaçes relacionadas a lista, e grave os dados.
3. Entre na opção 'Settings'. Depois clique em 'List Fields and merge option'
4. Preencha os seguintes campos:
    1. Field label: 'Cidade' (ou qualquer outra coisa que queira), Required: Não selecionado, Visible: Pode escolher, se não souber, deixe selecionado, TAG: 'CITY' (Essa deve ser exatamente assim, sem as aspas)

### Encontrando o identificador da lista (list ID)
1. Se já estiver na informação da lista, pule para o passo 3.
2. Selecione 'List' no menu. Selecione a lista de sua escolha.
3. No segundo menu (relativo a lista), selecione 'Settings' e depois 'Lists and Defaults'
4. ListID se encontra na coluna da direita, abaixo do título 'LIST ID'
