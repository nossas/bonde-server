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


  end
end
