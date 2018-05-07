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
                Olha a notícia boa: sua contribuição a <b>{{community.name}}</b> foi recebida.
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
                    <td align="left" style="padding-top: 16px; color: #424242">Valor da contribuição em BRL</td>
                    <td align="right" style="padding-top: 16px; color: #AAAAAA;">{{amount}}</td>
                  </tr>
                  <tr>
                    <td align="left" style="padding-top: 16px; color: #424242">ID do apoio</td>
                    <td align="right" style="padding-top: 16px; color: #AAAAAA;">{{"#" | append: last_donation.donation_id}}</td>
                  </tr>
                  {% if last_donation.payment_method == 'credit_card' %}
                    <tr>
                      <td align="left" style="padding-top: 16px; color: #424242">Cartão de crédito final</td>
                      <td align="right" style="padding-top: 16px; color: #AAAAAA;"> {{"****.****.****" | append: last_donation.card_last_digits}} </td>
                    </tr>
                  {% else %}
                    <tr>
                      <td align="left" style="padding-top: 16px; color: #424242">Boleto</td>
                      <td align="right" style="padding-top: 16px; color: #AAAAAA;">{{last_donation.boleto_url}}</td>
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
</tr>})

    label = 'paid_subscription'
    if nt = NotificationTemplate.find_by_label(label)
      nt.update_attribute(:body_template, sub_template)
      nt.update_attribute(:subject_template, '{{community.name}} ficou tão feliz com sua doação!')
    else
      NotificationTemplate.find_or_create_by(
        label: label,
        subject_template: '{{community.name}} ficou tão feliz com sua doação!' ,
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
                Algo deu errado na sua doação a <b>{{community.name}}</b> este mês -
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
      nt.update_attribute(:subject_template, '{{customer.first_name}} Sua doação não foi recebida :/')
    else
      NotificationTemplate.find_or_create_by(
        label: label,
        subject_template: '{{customer.first_name}} Sua doação não foi recebida :/',
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
                Tentamos reativar seu apoio a <b>{{community.name}}</b> pelos últimos 3 meses.
                Mas como não tivemos resposta, sua doação foi cancelada…
                <br>
                Valeu por sua ajuda até então! :)
              </td>
            </tr>
            <tr>
              <td align="center" style="padding-bottom: 24px; color: #424242; font-size: 13px;">
                E se quiser voltar a apoiar a <b>{{community.name}}</b>, é só editar sua doação:
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

    label = 'canceled_subscription'
    if nt = NotificationTemplate.find_by_label(label)
      nt.update_attribute(:body_template, sub_template)
      nt.update_attribute(:subject_template, '{{customer.first_name}}, está por aí?')
    else
      NotificationTemplate.find_or_create_by(
        label: label,
        subject_template: '{{customer.first_name}}, está por aí?',
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
                apoiando a <b>{{community.name}}</b>.
                Pra acessar o boleto, é só clicar no botão:
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
                E pra apoiar é fácil: Ele pode ser pago pelo Internet Banking ou agência
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
      nt.update_attribute(:subject_template, '{{customer.first_name}}, um boleto que pode fazer a diferença!')
    else
      NotificationTemplate.find_or_create_by(
        label: label,
        subject_template: '{{community.name}}, um boleto que pode fazer a diferença!',
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
    <td style="height:134px;position:relative;">
        <div style="background-image:url({{community.image}});background-size:100%;left:50%;margin-left:-56px;width:112px;height:112px;background-color:#d8d8d8;border:5px solid #ffffff;border-radius:50%; margin: 0 auto;"></div>
    </td>
</tr>
<tr>
    <td>
        <table style="width:420px;margin:80px auto;text-align:center;color:#222;font-size:17px;">
            <tr>
                <td>
Olá {{customer.first_name}}<br/>
Sua doação à {{community.name}} foi recebida e você pode acessar o boleto através do botão abaixo.
<br/>
<br/>
                  <a href="{{boleto_url}}" style="display:block;width:230px;padding:18px 0;margin:0 auto;background-color:#222222;font-size:16px;color:#fff;font-weight:600;text-transform:uppercase;text-decoration:none;">
                     Link p/ boleto
                  </a>
<br/>
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
    label = 'waiting_payment_donation'
    if nt = NotificationTemplate.find_by_label(label)
      nt.update_attribute(:body_template, sub_template)
    else
      NotificationTemplate.find_or_create_by(
        label: label,
        subject_template: 'Boleto de doação para {{community.name}}',
        body_template: sub_template
      )
    end

    puts 'looking for paid_donation template'
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
Olá {{customer.first_name}}<br/>
Sua doação à {{community.name}} foi processada com sucesso! Obrigada por nos apoiar.
<br/>
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
    label = 'paid_donation'
    if nt = NotificationTemplate.find_by_label(label)
      nt.update_attribute(:body_template, sub_template)
    else
      NotificationTemplate.find_or_create_by(
        label: label,
        subject_template: 'Doação para {{community.name}} processada com sucesso!',
        body_template: sub_template
      )
    end

    puts 'looking for refused_donation template'
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
Olá {{customer.first_name}}<br/>
Não foi possível processar seu cartão de crédito referente a doação efetuada à {{community.name}} Tente novamente e certifique-se de que todas as informações inseridas estão corretas.

<br/>
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
    label = 'refused_donation'
    if nt = NotificationTemplate.find_by_label(label)
      nt.update_attribute(:body_template, sub_template)
    else
      NotificationTemplate.find_or_create_by(
        label: label,
        subject_template: 'Tivemos problemas com sua doação para {{community.name}}',
        body_template: sub_template
      )
    end


    puts 'looking for waiting_payment_donation template'
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
Olá {{customer.first_name}}<br/>
Sua doação à {{community.name}} foi recebida e você pode acessar o boleto através do botão abaixo.
<br/>
<br/>
                  <a href="{{boleto_url}}" style="display:block;width:230px;padding:18px 0;margin:0 auto;background-color:#222222;font-size:16px;color:#fff;font-weight:600;text-transform:uppercase;text-decoration:none;">
                     Link p/ boleto
                  </a>
<br/>
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
    label = 'waiting_payment_donation'
    if nt = NotificationTemplate.find_by_label(label)
      nt.update_attribute(:body_template, sub_template)
    else
      NotificationTemplate.find_or_create_by(
        label: label,
        subject_template: 'Boleto de doação para {{community.name}}',
        body_template: sub_template
      )
    end

    puts 'looking for paid_donation template'
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
Olá {{customer.first_name}}<br/>
Sua doação à {{community.name}} foi processada com sucesso! Obrigada por nos apoiar.
<br/>
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
    label = 'paid_donation'
    if nt = NotificationTemplate.find_by_label(label)
      nt.update_attribute(:body_template, sub_template)
    else
      NotificationTemplate.find_or_create_by(
        label: label,
        subject_template: 'Doação para {{community.name}} processada com sucesso!',
        body_template: sub_template
      )
    end

    puts 'looking for refused_donation template'
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
Olá {{customer.first_name}}<br/>
Não foi possível processar seu cartão de crédito referente a doação efetuada à {{community.name}} Tente novamente e certifique-se de que todas as informações inseridas estão corretas.

<br/>
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
    label = 'refused_donation'
    if nt = NotificationTemplate.find_by_label(label)
      nt.update_attribute(:body_template, sub_template)
    else
      NotificationTemplate.find_or_create_by(
        label: label,
        subject_template: 'Tivemos problemas com sua doação para {{community.name}}',
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
  end
end
