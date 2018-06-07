# coding: utf-8
namespace :notifications do
  desc 'build first recurring notifications'
  task recurring_templates: :environment do

    puts 'looking for paid_subscription template'
    sub_template = (%{
<tr>
  <td style="padding-bottom: 16px;">
    <table
      width="100%"
      style="
        border-collapse: collapse;
        border-radius: 5px;
        border-style: hidden;
        background-color: #FFFFFF;
      "
    >
      <tr>
        <td style="padding: 32px 48px;" align="center">
          <table>
            <tr>
              <td align="center" style="padding-bottom: 16px; color: #424242; font-size: 18px;">
                Oi, <span style="color: #EE0099; font-weight: 800;">{{customer.first_name}}</span>!
              </td>
            </tr>
            <tr>
              <td align="center" style="padding-bottom: 32px; color: #424242; font-size: 13px;">
                Olha a notícia boa: sua contribuição a(o) <b>{{community.name}}</b> foi recebida.
                Obrigada por acreditar nesse trabalho, seu apoio faz toda a diferença! :)
              </td>
            </tr>
            <tr>
              <td align="center" style="padding-bottom: 16px;">
                <img src="https://s3.amazonaws.com/hub-central-dev/uploads/1524537871_bonde-donation-icon.png">
              </td>
            </tr>
            <tr>
              <td align="center" style="padding-bottom: 24px; color: #EE0099; font-size: 13px; font-weight: 800;">
                Comprovante de Contribuição
              </td>
            </tr>
            <tr>
              <td align="center" style="padding-bottom: 24px; font-size: 9px; font-weight: 700;">
                <table style="max-width: 335px; border-top: 1px solid #AAAAAA;">
                  <tr>
                    <td align="left" style="padding-top: 16px; color: #424242">Nome do apoiador</td>
                    <td align="right" style="padding-top: 16px; color: #AAAAAA;">{{customer.name}}</td>
                  </tr>
                  <tr>
                    <td align="left" style="padding-top: 16px; color: #424242">CPF/CNPJ do apoiador</td>
                    <td align="right" style="padding-top: 16px; color: #AAAAAA;">{{last_donation.customer_document}}</td>
                  </tr>
                  <tr>
                    <td align="left" style="padding-top: 16px; color: #424242">Data da confirmação</td>
                    <td align="right" style="padding-top: 16px; color: #AAAAAA;">{{created}}</td>
                  </tr>
                  <tr>
                    <td align="left" style="padding-top: 16px; color: #424242">Valor da contribuição</td>
                    <td align="right" style="padding-top: 16px; color: #AAAAAA;">{{amount}}</td>
                  </tr>
                  <tr>
                    <td align="left" style="padding-top: 16px; color: #424242">ID do apoio</td>
                    <td align="right" style="padding-top: 16px; color: #AAAAAA;">{{"#" | append: last_donation.donation_id}}</td>
                  </tr>
                  {% if last_donation.payment_method == 'credit_card' %}
                    <tr>
                      <td align="left" style="padding-top: 16px; color: #424242">Cartão de crédito final</td>
                      <td align="right" style="padding-top: 16px; color: #AAAAAA;"> {{"****.****.****." | append: last_donation.card_last_digits}} </td>
                    </tr>
                  {% endif %}
                </table>
              </td>
            </tr>
            {% if last_donation.payment_method == 'credit_card' %}
            <tr align="center">
              <td align="center" style="padding-bottom: 56px; color: #4A4A4A; font-size: 11px; font-weight: 600;">
                Em sua fatura, aparecerá a descrição "PG *NOSSAS CIDADES"
              </td>
            </tr>
            {% endif %}
            <tr>
              <td align="center" style="padding-bottom: 0; color: #4A4A4A; font-size: 11px;">
                Dúvidas? Só mandar um e-mail pra: <a href="mailto:suporte@bonde.org">suporte@bonde.org</a>
              </td>
            </tr>
          </table>
        </td>
      </tr>
    </table>
  </td>
</tr>})

    label = 'paid_subscription'
    if nt = NotificationTemplate.find_by_label(label)
      nt.update_attribute(:body_template, sub_template)
      nt.update_attribute(:subject_template, '{{community.name}} recebeu sua doação!')
    else
      NotificationTemplate.find_or_create_by(
        label: label,
        subject_template: '{{community.name}} recebeu sua doação!',
        body_template: sub_template
      )
    end

    puts 'looking for unpaid_subscription template'
    sub_template = (%{
<tr>
  <td style="padding-bottom: 16px;">
    <table
      width="100%"
      style="
        border-collapse: collapse;
        border-radius: 5px;
        border-style: hidden;
        background-color: #FFFFFF;
      "
    >
      <tr>
        <td style="padding: 32px 48px;" align="center">
          <table>
            <tr>
              <td align="center" style="padding-bottom: 40px; color: #424242; font-size: 18px;">
                Olá, <span style="color: #EE0099; font-weight: 800;">{{customer.first_name}}</span>!
              </td>
            </tr>
            <tr>
              <td align="center" style="padding-bottom: 40px; color: #424242; font-size: 13px;">
                Algo deu errado na sua doação a(o) <b>{{community.name}}</b> -
                e seu apoio faz muita diferença, então bora resolver juntos? Se você trocou
                de cartão ou quer alterar a data de cobrança, é só clicar no botão a
                seguir para editar essas informações:
              </td>
            </tr>
            <tr>
              <td align="center" style="padding-bottom: 64px;">
                <a
                  href="{{manage_url}}"
                  style="
                    display: inline-block;
                    background-color: #EE0099;
                    color: #FFFFFF;
                    font-size: 11px;
                    font-weight: 700;
                    text-transform: uppercase;
                    border-radius: 100px;
                    text-decoration: none;
                    padding: 16px 32px;
                    text-align: center;
                  "
                >
                  Editar minha doação
                </a>
              </td>
            </tr>
            <tr>
              <td align="center" style="padding-bottom: 0; color: #4A4A4A; font-size: 11px;">
                Dúvidas? Só mandar um e-mail pra: <a href="mailto:suporte@bonde.org">suporte@bonde.org</a>
              </td>
            </tr>
          </table>
        </td>
      </tr>
    </table>
  </td>
</tr>})

    label = 'unpaid_subscription'
    if nt = NotificationTemplate.find_by_label(label)
      nt.update_attribute(:body_template, sub_template)
      nt.update_attribute(:subject_template, '{{community.name}} não recebeu sua doação :/')
    else
      NotificationTemplate.find_or_create_by(
        label: label,
        subject_template: '{{community.name}} não recebeu sua doação :/',
        body_template: sub_template
      )
    end

    puts 'looking for canceled_subscription template'
    sub_template = (%{
<tr>
  <td style="padding-bottom: 16px;">
    <table
      width="100%"
      style="
        border-collapse: collapse;
        border-radius: 5px;
        border-style: hidden;
        background-color: #FFFFFF;
      "
    >
      <tr>
        <td style="padding: 32px 48px;" align="center">
          <table>
            <tr>
              <td align="center" style="padding-bottom: 40px; color: #424242; font-size: 18px;">
                Olá, <span style="color: #EE0099; font-weight: 800;">{{customer.first_name}}</span>!
              </td>
            </tr>
            <tr>
              <td align="center" style="padding-bottom: 48px; color: #424242; font-size: 13px;">
                Seu apoio recorrente a(o) <b>{{community.name}}</b> foi cancelado...
                Agradecemos muito sua ajuda até então, pode acreditar que fez muita diferença!
              </td>
            </tr>
            <tr>
              <td align="center" style="padding-bottom: 24px; color: #424242; font-size: 13px;">
                E se quiser voltar a apoiar <b>{{community.name}}</b>, é só entrar no site e criar uma nova doação :)
              </td>
            </tr>
            <tr>
              <td align="center" style="padding-bottom: 0; color: #4A4A4A; font-size: 11px;">
                Dúvidas? Só mandar um e-mail pra: <a href="mailto:suporte@bonde.org">suporte@bonde.org</a>
              </td>
            </tr>
          </table>
        </td>
      </tr>
    </table>
  </td>
</tr>})

    label = 'canceled_subscription'
    if nt = NotificationTemplate.find_by_label(label)
      nt.update_attribute(:body_template, sub_template)
      nt.update_attribute(:subject_template, 'Olá {{customer.first_name}}, sua doação foi cancelada :(')
    else
      NotificationTemplate.find_or_create_by(
        label: label,
        subject_template: 'Olá {{customer.first_name}}, sua doação foi cancelada :(',
        body_template: sub_template
      )
      end

    puts 'looking for slip_subscription template'
    sub_template = (%{
<tr>
  <td style="padding-bottom: 16px;">
    <table
      width="100%"
      style="
        border-collapse: collapse;
        border-radius: 5px;
        border-style: hidden;
        background-color: #FFFFFF;
      "
    >
      <tr>
        <td style="padding: 32px 48px;" align="center">
          <table>
            <tr>
              <td align="center" style="padding-bottom: 40px; color: #424242; font-size: 18px;">
                Olá, <span style="color: #EE0099; font-weight: 800;">{{customer.first_name}}</span>!
              </td>
            </tr>
            <tr>
              <td align="center" style="padding-bottom: 40px; color: #424242; font-size: 13px;">
                Como vai?
                <br>
                Emitimos o boleto pra você poder seguir
                apoiando <b>{{community.name}}</b>.
                Para acessar o boleto, é só clicar no botão:
              </td>
            </tr>
            <tr>
              <td align="center" style="padding-bottom: 32px;">
                <a
                  href="{{last_donation.boleto_url}}"
                  style="
                    display: inline-block;
                    background-color: #EE0099;
                    color: #FFFFFF;
                    font-size: 11px;
                    font-weight: 700;
                    text-transform: uppercase;
                    border-radius: 100px;
                    text-decoration: none;
                    padding: 16px 32px;
                    text-align: center;
                  "
                >
                  Acessar boleto
                </a>
              </td>
            </tr>
            <tr>
              <td align="center" style="padding-bottom: 64px; color: #4A4A4A; font-size: 13px;">
                E pra apoiar é fácil: você pode pagar pelo Internet Banking ou agência
                de qualquer banco até a data de vencimento. Depois de vencido, só
                será aceito pelo banco emissor. Se o botão não funcionar, é só
                clicar neste link:
                <br>
                       <a href="{{last_donation.boleto_url}}">{{last_donation.boleto_url}}</a>
              </td>
            </tr>
            <tr>
              <td align="center" style="padding-bottom: 0; color: #4A4A4A; font-size: 11px;">
                Dúvidas? Só mandar um e-mail pra: <a href="mailto:suporte@bonde.org">suporte@bonde.org</a>
              </td>
            </tr>
          </table>
        </td>
      </tr>
    </table>
  </td>
</tr>})

    label = 'slip_subscription'
    if nt = NotificationTemplate.find_by_label(label)
      nt.update_attribute(:body_template, sub_template)
      nt.update_attribute(:subject_template, '{{customer.first_name}}, um boleto que pode fazer a diferença para {{community.name}}!')
    else
      NotificationTemplate.find_or_create_by(
        label: label,
        subject_template: '{{customer.first_name}}, um boleto que ode fazer a diferença para {{community.name}}',
        body_template: sub_template
      )
    end

    puts 'looking for invalid_canceled_gateway_subscription template'
    sub_template = (%{
<tr>
    <td style="height:134px;position:relative;">
        <div style="background-image:url({{community.image}});background-size:100%;left:50%;margin-left:-56px;width:112px;height:112px;background-color:#d8d8d8;border:5px solid #ffffff;border-radius:50%; margin: 0 auto;"></div>
    </td>
</tr>
<tr>
    <td>
        <table style="width:420px;margin:80px auto;text-align:center;color:#222;font-size:17px;">
            <tr>
                <td>
Olá {{customer.first_name}}, tudo bem? <br/><br/>
Ontem você recebeu um e-mail do Pagar.me informando o cancelamento da sua doação a {{community.name}}. Estamos fazendo uma atualização no nosso sistema de pagamento e esse e-mail não deveria ter sido enviado.
<br/><br/>
Sua doação continua válida e você continuará sendo debitado na data correta. Não será necessária nenhuma ação sua para continuar contribuindo. Desculpe-nos o transtorno. Qualquer dúvida, estamos à disposição
<br/>
                </td>
            </tr>
{% if community.fb_link %}
            <tr>
                <td style="padding-bottom:30px;">
                    <p>
                        Siga de perto o trabalho da {{community.name}}:
                    </p>
                    <div>
                        <a href="{{community.fb_link}}"><img src="https://s3.amazonaws.com/hub-central-dev/uploads/1490248328_icon-fb.png" width="36" height="36" hspace="5" /></a>
                        <a href="{{community.twitter_link}}"><img src="https://s3.amazonaws.com/hub-central-dev/uploads/1490248320_icon-ig.png" width="36" height="36" hspace="5" /></a>
                    </div>
                </td>
            </tr>
{% endif %}
        </table>
    </td>
</tr>})
    label = 'invalid_canceled_gateway_subscription'
    if nt = NotificationTemplate.find_by_label(label)
      nt.update_attribute(:body_template, sub_template)
    else
      NotificationTemplate.find_or_create_by(
        label: label,
        subject_template: 'Sua doação a {{community.name}} continua ativa!',
        body_template: sub_template
      )
    end


    puts 'looking for waiting_payment_donation template'
    sub_template = (%{
<tr>
  <td style="padding-bottom: 16px;">
    <table
      width="100%"
      style="
        border-collapse: collapse;
        border-radius: 5px;
        border-style: hidden;
        background-color: #FFFFFF;
      "
    >
      <tr>
        <td style="padding: 32px 48px;" align="center">
          <table>
            <tr>
              <td align="center" style="padding-bottom: 40px; color: #424242; font-size: 18px;">
                Olá, <span style="color: #EE0099; font-weight: 800;">{{customer.first_name}}</span>!
              </td>
            </tr>
            <tr>
              <td align="center" style="padding-bottom: 40px; color: #424242; font-size: 13px;">
                Como vai?
                <br>
                Emitimos o boleto pra você poder seguir
                apoiando <b>{{community.name}}</b>.
                Para acessar o boleto, é só clicar no botão:
              </td>
            </tr>
            <tr>
              <td align="center" style="padding-bottom: 32px;">
                <a
                  href="{{boleto_url}}"
                  style="
                    display: inline-block;
                    background-color: #EE0099;
                    color: #FFFFFF;
                    font-size: 11px;
                    font-weight: 700;
                    text-transform: uppercase;
                    border-radius: 100px;
                    text-decoration: none;
                    padding: 16px 32px;
                    text-align: center;
                  "
                >
                  Acessar boleto
                </a>
              </td>
            </tr>
            <tr>
              <td align="center" style="padding-bottom: 64px; color: #4A4A4A; font-size: 13px;">
                E pra apoiar é fácil: você pode pagar pelo Internet Banking ou agência
                de qualquer banco até a data de vencimento. Depois de vencido, só
                será aceito pelo banco emissor. Se o botão não funcionar, é só
                clicar neste link:
                <br>
                       <a href="{{boleto_url}}">{{boleto_url}}</a>
              </td>
            </tr>
            <tr>
              <td align="center" style="padding-bottom: 0; color: #4A4A4A; font-size: 11px;">
                Dúvidas? Só mandar um e-mail pra: <a href="mailto:suporte@bonde.org">suporte@bonde.org</a>
              </td>
            </tr>
          </table>
        </td>
      </tr>
    </table>
  </td>
</tr>})
    label = 'waiting_payment_donation'
    if nt = NotificationTemplate.find_by_label(label)
      nt.update_attribute(:body_template, sub_template)
      nt.update_attribute(:subject_template, '{{customer.first_name}}, um boleto que pode fazer a diferença para {{community.name}}!')
    else
      NotificationTemplate.find_or_create_by(
        label: label,
        subject_template: '{{customer.first_name}}, um boleto que pode fazer a diferença para {{community.name}}!',
        body_template: sub_template
      )
    end

    puts 'looking for paid_donation template'
    sub_template = (%{
<tr>
  <td style="padding-bottom: 16px;">
    <table
      width="100%"
      style="
        border-collapse: collapse;
        border-radius: 5px;
        border-style: hidden;
        background-color: #FFFFFF;
      "
    >
      <tr>
        <td style="padding: 32px 48px;" align="center">
          <table>
            <tr>
              <td align="center" style="padding-bottom: 16px; color: #424242; font-size: 18px;">
                Oi, <span style="color: #EE0099; font-weight: 800;">{{customer.first_name}}</span>!
              </td>
            </tr>
            <tr>
              <td align="center" style="padding-bottom: 32px; color: #424242; font-size: 13px;">
                Olha a notícia boa: sua contribuição a(o) <b>{{community.name}}</b> foi recebida.
                Obrigada por acreditar nesse trabalho, seu apoio faz toda a diferença! :)
              </td>
            </tr>
            <tr>
              <td align="center" style="padding-bottom: 16px;">
                <img src="https://s3.amazonaws.com/hub-central-dev/uploads/1524537871_bonde-donation-icon.png">
              </td>
            </tr>
            <tr>
              <td align="center" style="padding-bottom: 24px; color: #EE0099; font-size: 13px; font-weight: 800;">
                Comprovante de Contribuição
              </td>
            </tr>
            <tr>
              <td align="center" style="padding-bottom: 24px; font-size: 9px; font-weight: 700;">
                <table style="max-width: 335px; border-top: 1px solid #AAAAAA;">
                  <tr>
                    <td align="left" style="padding-top: 16px; color: #424242">Nome do apoiador</td>
                    <td align="right" style="padding-top: 16px; color: #AAAAAA;">{{customer.name}}</td>
                  </tr>
                  <tr>
                    <td align="left" style="padding-top: 16px; color: #424242">CPF/CNPJ do apoiador</td>
                    <td align="right" style="padding-top: 16px; color: #AAAAAA;">{{customer_document}}</td>
                  </tr>
                  <tr>
                    <td align="left" style="padding-top: 16px; color: #424242">Data da confirmação</td>
                    <td align="right" style="padding-top: 16px; color: #AAAAAA;">{{created}}</td>
                  </tr>
                  <tr>
                    <td align="left" style="padding-top: 16px; color: #424242">Valor da contribuição</td>
                    <td align="right" style="padding-top: 16px; color: #AAAAAA;">{{amount}}</td>
                  </tr>
                  <tr>
                    <td align="left" style="padding-top: 16px; color: #424242">ID do apoio</td>
                    <td align="right" style="padding-top: 16px; color: #AAAAAA;">{{"#" | append: donation_id}}</td>
                  </tr>
                  {% if payment_method == 'credit_card' %}
                    <tr>
                      <td align="left" style="padding-top: 16px; color: #424242">Cartão de crédito final</td>
                      <td align="right" style="padding-top: 16px; color: #AAAAAA;"> {{"****.****.****." | append: card_last_digits}} </td>
                    </tr>
                  {% endif %}
                </table>
              </td>
            </tr>
            {% if payment_method == 'credit_card' %}
            <tr align="center">
              <td align="center" style="padding-bottom: 56px; color: #4A4A4A; font-size: 11px; font-weight: 600;">
                Em sua fatura, aparecerá a descrição "PG *NOSSAS CIDADES"
              </td>
            </tr>
            {% endif %}
            <tr>
              <td align="center" style="padding-bottom: 0; color: #4A4A4A; font-size: 11px;">
                Dúvidas? Só mandar um e-mail pra: <a href="mailto:suporte@bonde.org">suporte@bonde.org</a>
              </td>
            </tr>
          </table>
        </td>
      </tr>
    </table>
  </td>
</tr>})
    label = 'paid_donation'
    if nt = NotificationTemplate.find_by_label(label)
      nt.update_attribute(:body_template, sub_template)
      nt.update_attribute(:subject_template, '{{community.name}} recebeu sua doação!')
    else
      NotificationTemplate.find_or_create_by(
        label: label,
        subject_template: '{{community.name}} recebeu sua doação',
        body_template: sub_template
      )
    end

    puts 'looking for waiting_payment_donation template'
    sub_template = (%{
<tr>
  <td style="padding-bottom: 16px;">
    <table
      width="100%"
      style="
        border-collapse: collapse;
        border-radius: 5px;
        border-style: hidden;
        background-color: #FFFFFF;
      "
    >
      <tr>
        <td style="padding: 32px 48px;" align="center">
          <table>
            <tr>
              <td align="center" style="padding-bottom: 40px; color: #424242; font-size: 18px;">
                Olá, <span style="color: #EE0099; font-weight: 800;">{{customer.first_name}}</span>!
              </td>
            </tr>
            <tr>
              <td align="center" style="padding-bottom: 40px; color: #424242; font-size: 13px;">
                Como vai?
                <br>
                Emitimos o boleto pra você poder seguir
                apoiando a <b>{{community.name}}</b>.
                Para acessar o boleto, é só clicar no botão:
              </td>
            </tr>
            <tr>
              <td align="center" style="padding-bottom: 32px;">
                <a
                  href="{{boleto_url}}"
                  style="
                    display: inline-block;
                    background-color: #EE0099;
                    color: #FFFFFF;
                    font-size: 11px;
                    font-weight: 700;
                    text-transform: uppercase;
                    border-radius: 100px;
                    text-decoration: none;
                    padding: 16px 32px;
                    text-align: center;
                  "
                >
                  Acessar boleto
                </a>
              </td>
            </tr>
            <tr>
              <td align="center" style="padding-bottom: 64px; color: #4A4A4A; font-size: 13px;">
                E pra apoiar é fácil: você pode pagar pelo  Internet Banking ou agência
                de qualquer banco até a data de vencimento. Depois de vencido, só
                será aceito pelo banco emissor. Se o botão não funcionar, é só
                clicar neste link:
                <br>
                      <a href="{{boleto_url}}">{{boleto_url}}</a>
              </td>
            </tr>
            <tr>
              <td align="center" style="padding-bottom: 0; color: #4A4A4A; font-size: 11px;">
                Dúvidas? Só mandar um e-mail pra: <a href="mailto:suporte@bonde.org">suporte@bonde.org</a>
              </td>
            </tr>
          </table>
        </td>
      </tr>
    </table>
  </td>
</tr>})
    label = 'waiting_payment_donation'
    if nt = NotificationTemplate.find_by_label(label)
      nt.update_attribute(:body_template, sub_template)
      nt.update_attribute(:subject_template, '{{customer.first_name}}, um boleto que pode fazer a diferença para {{community.name}}!')
    else
      NotificationTemplate.find_or_create_by(
        label: label,
        subject_template: '{{customer.first_name}}, um boleto que pode fazer a diferença para {{community.name}}!',
        body_template: sub_template
      )
    end

    puts 'looking for paid_donation template'
    sub_template = (%{
<tr>
  <td style="padding-bottom: 16px;">
    <table
      width="100%"
      style="
        border-collapse: collapse;
        border-radius: 5px;
        border-style: hidden;
        background-color: #FFFFFF;
      "
    >
      <tr>
        <td style="padding: 32px 48px;" align="center">
          <table>
            <tr>
              <td align="center" style="padding-bottom: 16px; color: #424242; font-size: 18px;">
                Oi, <span style="color: #EE0099; font-weight: 800;">{{customer.first_name}}</span>!
              </td>
            </tr>
            <tr>
              <td align="center" style="padding-bottom: 32px; color: #424242; font-size: 13px;">
                Olha a notícia boa: sua contribuição a(o) <b>{{community.name}}</b> foi recebida.
                Obrigada por acreditar nesse trabalho, seu apoio faz toda a diferença! :)
              </td>
            </tr>
            <tr>
              <td align="center" style="padding-bottom: 16px;">
                <img src="https://s3.amazonaws.com/hub-central-dev/uploads/1524537871_bonde-donation-icon.png">
              </td>
            </tr>
            <tr>
              <td align="center" style="padding-bottom: 24px; color: #EE0099; font-size: 13px; font-weight: 800;">
                Comprovante de Contribuição
              </td>
            </tr>
            <tr>
              <td align="center" style="padding-bottom: 24px; font-size: 9px; font-weight: 700;">
                <table style="max-width: 335px; border-top: 1px solid #AAAAAA;">
                  <tr>
                    <td align="left" style="padding-top: 16px; color: #424242">Nome do apoiador</td>
                    <td align="right" style="padding-top: 16px; color: #AAAAAA;">{{customer.name}}</td>
                  </tr>
                  <tr>
                    <td align="left" style="padding-top: 16px; color: #424242">CPF/CNPJ do apoiador</td>
                    <td align="right" style="padding-top: 16px; color: #AAAAAA;">{{customer_document}}</td>
                  </tr>
                  <tr>
                    <td align="left" style="padding-top: 16px; color: #424242">Data da confirmação</td>
                    <td align="right" style="padding-top: 16px; color: #AAAAAA;">{{created}}</td>
                  </tr>
                  <tr>
                    <td align="left" style="padding-top: 16px; color: #424242">Valor da contribuição</td>
                    <td align="right" style="padding-top: 16px; color: #AAAAAA;">{{amount}}</td>
                  </tr>
                  <tr>
                    <td align="left" style="padding-top: 16px; color: #424242">ID do apoio</td>
                    <td align="right" style="padding-top: 16px; color: #AAAAAA;">{{"#" | append: donation_id}}</td>
                  </tr>
                  {% if payment_method == 'credit_card' %}
                    <tr>
                      <td align="left" style="padding-top: 16px; color: #424242">Cartão de crédito final</td>
                      <td align="right" style="padding-top: 16px; color: #AAAAAA;"> {{"****.****.****." | append: card_last_digits}} </td>
                    </tr>
                  {% else %}
                    <tr>
                      <td align="left" style="padding-top: 16px; color: #424242">Boleto</td>
                      <td align="right" style="padding-top: 16px; color: #AAAAAA;">{{boleto_url}}</td>
                    </tr>
                  {% endif %}
                </table>
              </td>
            </tr>
            <tr align="center">
              <td align="center" style="padding-bottom: 56px; color: #4A4A4A; font-size: 11px; font-weight: 600;">
                Em sua fatura, aparecerá a descrição "PG *NOSSAS CIDADES"
              </td>
            </tr>
            <tr>
              <td align="center" style="padding-bottom: 0; color: #4A4A4A; font-size: 11px;">
                Dúvidas? Só mandar um e-mail pra: <a href="mailto:suporte@bonde.org">suporte@bonde.org</a>
              </td>
            </tr>
          </table>
        </td>
      </tr>
    </table>
  </td>
</tr>
})
    label = 'paid_donation'
    if nt = NotificationTemplate.find_by_label(label)
      nt.update_attribute(:body_template, sub_template)
      nt.update_attribute(:subject_template, '{{community.name}} recebeu sua doação!')
    else
      NotificationTemplate.find_or_create_by(
        label: label,
        subject_template: '{{community.name}} recebeu sua doação!',
        body_template: sub_template
      )
    end

    puts 'looking for refused_donation template'
    sub_template = (%{
<tr>
  <td style="padding-bottom: 16px;">
    <table
      width="100%"
      style="
        border-collapse: collapse;
        border-radius: 5px;
        border-style: hidden;
        background-color: #FFFFFF;
      "
    >
      <tr>
        <td style="padding: 32px 48px;" align="center">
          <table>
            <tr>
              <td align="center" style="padding-bottom: 40px; color: #424242; font-size: 18px;">
                Olá, <span style="color: #EE0099; font-weight: 800;">{{customer.first_name}}</span>!
              </td>
            </tr>
            <tr>
              <td align="center" style="padding-bottom: 40px; color: #424242; font-size: 13px;">
                Algo deu errado na sua doação a(o) <b>{{community.name}}</b>  -
                e seu apoio faz muita diferença, então bora resolver juntos?
                Basta tentar novamente em nosso site e verificar se todas as informações inseridas estão corretas :)
              </td>
            </tr>
            <tr>
              <td align="center" style="padding-bottom: 0; color: #4A4A4A; font-size: 11px;">
                Dúvidas? Só mandar um e-mail pra: <a href="mailto:suporte@bonde.org">suporte@bonde.org</a>
              </td>
            </tr>
          </table>
        </td>
      </tr>
    </table>
  </td>
</tr>})
    label = 'refused_donation'
    if nt = NotificationTemplate.find_by_label(label)
      nt.update_attribute(:body_template, sub_template)
      nt.update_attribute(:subject_template, '{{community.name}} não recebeu sua doação :/')
    else
      NotificationTemplate.find_or_create_by(
        label: label,
        subject_template: '{{community.name}} nào recebeu sua doação :/',
        body_template: sub_template
      )
    end
  end

  desc 'accounts notifications'
  task accounts_templates: :environment do
    puts 'looking for reset_password_instructions template'
    sub_template = (%{
<tr>
    <td style="height:134px;position:relative;">
        <div style="background-image:url();background-size:100%;left:50%;margin-left:-56px;width:112px;height:112px;background-color:#d8d8d8;border:5px solid #ffffff;border-radius:50%; margin: 0 auto;"></div>
    </td>
</tr>
<tr>
    <td>
        <table style="width:420px;margin:80px auto;text-align:center;color:#222;font-size:17px;">
            <tr>
                <td>
Olá {{user.first_name}}
<br/><br/>
Você requisitou uam troca de senha para o bonde, clique no link abaixo para trocar sua senha:
<br/><br/>

                  <a href="http://app.bonde.org/?reset_password_token={{user.reset_password_token}}" style="display:block;width:230px;padding:18px 0;margin:0 auto;background-color:#222222;font-size:16px;color:#fff;font-weight:600;text-transform:uppercase;text-decoration:none;">
                    TROCAR SENHA
                  </a>
                </td>
            </tr>
        </table>
    </td>
</tr>})
    label = 'reset_password_instructions'
    subject = 'Instruções para alteração de senha'
    if nt = NotificationTemplate.find_by_label(label)
      nt.update_attributes(
        body_template: sub_template,
        subject_template: subject
      )
    else
      NotificationTemplate.find_or_create_by(
        label: label,
        subject_template: subject,
        body_template: sub_template
      )
    end


    puts 'looking for welcome_user template'
    sub_template = (%{
<tr>
    <td style="height:134px;position:relative;">
        <div style="background-image:url();background-size:100%;left:50%;margin-left:-56px;width:112px;height:112px;background-color:#d8d8d8;border:5px solid #ffffff;border-radius:50%; margin: 0 auto;"></div>
    </td>
</tr>
<tr>
    <td>
        <table style="width:420px;margin:80px auto;text-align:center;color:#222;font-size:17px;">
            <tr>
                <td>
Olá {{user.first_name}}
<br/><br/>
Você está recebendo este email por que acaba de embarcar no BONDE :)
<br/><br/>
Se tiver dúvidas nessa chegada, pode dar uma olhada em nosso tutorial no <a href="https://trilho.bonde.org">trilho.bonde.org</a> ou nas respostas de nossas perguntas frequentes em <a href="https://faq.bonde.org">faq.bonde.org</a> :)
<br/><br/>
Um abraço,
<br/>
Equipe do BONDE.
<br/><br/>

                </td>
            </tr>
        </table>
    </td>
</tr>})
    label = 'welcome_user'
    subject = 'Você acaba de embarcar no BONDE!'
    if nt = NotificationTemplate.find_by_label(label)
      nt.update_attributes(
        body_template: notification_layout(sub_template),
        subject_template: subject
      )
    else
      NotificationTemplate.find_or_create_by(
        label: label,
        subject_template: subject,
        body_template: notification_layout(sub_template)
      )
    end
  end
end

def notification_layout(body)
  %Q{
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
 <head>
  <meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
  <title>BONDE</title>
  <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
  <link href="https://fonts.googleapis.com/css?family=Nunito:300,400,600,700,800" rel="stylesheet">
  <style type="text/css">
    a, a:link, a:visited, a:hover, a:active { color: #EE0099; }
  </style>
</head>
<body style="margin: 0; padding: 16px; background-color: #EEEEEE; text-align: center;">
  <table
    align="center"
    cellpadding="0"
    cellspacing="0"
    style="font-family: 'Nunito', sans-serif; max-width: 600px;"
  >
    <!-- HEADER -->
    <tr>
      <td align="center" style="padding: 16px;">
        <img src="https://s3.amazonaws.com/hub-central-dev/uploads/1524537731_bonde-logo.png" style="vertical-align: middle;">
        {%- if community.image  %}
          <div style="width: 1px; height: 26px; background-color: #AAAAAA; margin: 0 20px; display: inline-block; vertical-align: middle;"></div>
          <img src="{{community.image}}" width="20%" style="vertical-align: middle;">
        {% endif %}
      </td>
    </tr>
    <!-- HEADER -->

    <!-- MAIN -->
    #{body}
    <!-- MAIN -->

    <!-- FOOTER -->
    <tr>
        <td>
            <table width="100%">
                <tr>
                    <td align="left" style="color: #4A4A4A; font-size: 12px; padding-left: 16px;">
                        Feito pra causar. Feito com <b>BONDE</b>.
                    </td>
                    <td align="right" style="padding-right: 16px;">
                        <img src="https://s3.amazonaws.com/hub-central-dev/uploads/1524537742_bonde-logo-icon.png">
                    </td>
                </tr>
            </table>
        </td>
    </tr>
    <tr>
        <td align="center" style="color: #9B9B9B; font-weight: 300; font-size: 9px; padding: 16px 40px;">
            {%  if community.name  %}
                O BONDE é a plataforma que {{ community.name }} usa para criar e gerenciar as páginas de
                mobilizações, por isso você recebe essas notificações vindas da gente ;)
            {% else %}
                O BONDE é a plataforma usada para criar e gerenciar as páginas de
                mobilizações, por isso você recebe essas notificações vindas da gente ;)
            {% endif %}
        </td>
    </tr>
    <!-- FOOTER -->
  </table>
</body>
</html>
}
end
