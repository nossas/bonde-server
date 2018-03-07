# coding: utf-8
namespace :notifications do
  desc 'build first recurring notifications'
  task recurring_templates: :environment do

    puts 'looking for paid_subscription template'
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
Olá {{customer.first_name}}
<br/><br/>
Sua doação à {{community.name}} foi processada! Obrigada por mais um mês nos apoiando.
<br/><br/>
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
    label = 'paid_subscription'
    if nt = NotificationTemplate.find_by_label(label)
      nt.update_attribute(:body_template, sub_template)
    else
      NotificationTemplate.find_or_create_by(
        label: label,
        subject_template: '{{community.name}} Doação processada!',
        body_template: sub_template
      )
    end

    puts 'looking for unpaid_subscription template'
    sub_template = (%{
<tr>
    <td style="height:134px;position:relative;">
        <div style="background-image:url({{community.image}});background-size:100%;left:50%;margin-left:-56px;width:112px;height:112px;background-color:#d8d8d8;border:5px solid #ffffff;border-radius:50%;margin: 0 auto;"></div>
    </td>
</tr>
<tr>
    <td>
        <table style="width:420px;margin:80px auto;text-align:center;color:#222;font-size:17px;">
            <tr>
                <td>
Olá {{customer.first_name}}, sua doação deste mês não foi processada com sucesso. Vamos resolver? Clique no botão a seguir para editar os dados da sua conta e continuar apoiando {{community.name}}
<br/>
<br/>
                  <a href="{{manage_url}}" style="display:block;width:230px;padding:18px 0;margin:0 auto;background-color:#222222;font-size:16px;color:#fff;font-weight:600;text-transform:uppercase;text-decoration:none;">
                    EDITAR FORMA DE PAGAMENTO
                  </a>
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
    label = 'unpaid_subscription'
    if nt = NotificationTemplate.find_by_label(label)
      nt.update_attribute(:body_template, sub_template)
    else
      NotificationTemplate.find_or_create_by(
        label: label,
        subject_template: 'Ops, deu algo errado com sua doação!',
        body_template: sub_template
      )
    end

    puts 'looking for canceled_subscription template'
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
Olá {{customer.first_name}}, sua doação mensal à {{community.name }} foi cancelada. Agradecemos sua ajuda até então e esperamos que volte a nos apoiar!
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
    label = 'canceled_subscription'
    if nt = NotificationTemplate.find_by_label(label)
      nt.update_attribute(:body_template, sub_template)
    else
      NotificationTemplate.find_or_create_by(
        label: label,
        subject_template: '{{customer.first_name}} perdemos seu apoio?',
        body_template: sub_template
      )
    end

    puts 'looking for slip_subscription template'
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
Olá {{customer.first_name}}, clique no link abaixo para visualizar o boleto e efetuar sua doação mensal a {{community.name}}
<br/>
<br/>
                  <a href="{{last_donation.boleto_url}}" style="display:block;width:230px;padding:18px 0;margin:0 auto;background-color:#222222;font-size:16px;color:#fff;font-weight:600;text-transform:uppercase;text-decoration:none;">
                    ACESSAR BOLETO
                  </a>
<br/>
<br/>
O boleto pode ser pago pelo Internet Banking ou agência de qualquer banco até a data de vencimento. Depois de vencido, só será aceito pelo banco emissor.

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
    label = 'slip_subscription'
    if nt = NotificationTemplate.find_by_label(label)
      nt.update_attribute(:body_template, sub_template)
    else
      NotificationTemplate.find_or_create_by(
        label: label,
        subject_template: '{{community.name}} Emissão do boleto para doação',
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
