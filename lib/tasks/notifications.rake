# coding: utf-8
namespace :notifications do
  desc 'build first recurring notifications'
  task recurring_templates: :environment do

    puts 'looking for new_subscription template'
    sub_template = (%{
<tr>
    <td style="height:134px;position:relative;background-color:#000;background-image:url('https://s3.amazonaws.com/hub-central-dev/uploads/1490248339_header-image.png');background-repeat:no-repeat;background-size:100%;background-position:0 0;">
        <div style="background-image:url({{community.image}});background-size:100%;position:absolute;left:50%;margin-left:-56px;width:112px;height:112px;background-color:#d8d8d8;border:5px solid #ffffff;border-radius:50%;"></div>
    </td>
</tr>
<tr>
    <td>
        <table style="width:420px;margin:0 auto;text-align:center;color:#222;font-size:17px;">
            <tr>
                <td style="padding-top:100px;padding-bottom:30px;font-size:26px;font-weight:700;">
                    <p style="margin:0 0 15px;">Olá, {{customer.first_name}}</p>
                    <p style="margin:0 0 3px;">Sua assinatura para comunidade</p>
                    <p style="margin:0 0 3px;">{{community.name}}</p>
                    <p style="margin:0 0 3px;">foi criado!</p>
                </td>
            </tr>
            <tr>
                <td>
                    A partir de agora, você será cobrado
                    <span style="font-weight:600;">
                        R$ {{amount}} todo mês.
                    </span>
                </td>
            </tr>
            <tr>
                <td style="padding:50px 0;">
                </td>
            </tr>
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
        </table>
    </td>
</tr>})
    label = 'new_subscription'
    if nt = NotificationTemplate.find_by_label(label)
      nt.update_attribute(:body_template, sub_template)
    else
      NotificationTemplate.find_or_create_by(
        label: label,
        subject_template: 'Assinatura criada para Comunidade {{community.name}}',
        body_template: sub_template
      )
    end


    puts 'looking for paid_subscription template'
    sub_template = (%{
<tr>
    <td style="height:134px;position:relative;background-color:#000;background-image:url('https://s3.amazonaws.com/hub-central-dev/uploads/1490248339_header-image.png');background-repeat:no-repeat;background-size:100%;background-position:0 0;">
        <div style="background-image:url({{community.image}});background-size:100%;position:absolute;left:50%;margin-left:-56px;width:112px;height:112px;background-color:#d8d8d8;border:5px solid #ffffff;border-radius:50%;"></div>
    </td>
</tr>
<tr>
    <td>
        <table style="width:420px;margin:0 auto;text-align:center;color:#222;font-size:17px;">
            <tr>
                <td style="padding-top:100px;padding-bottom:30px;font-size:26px;font-weight:700;">
                    <p style="margin:0 0 15px;">Olá, {{customer.first_name}}</p>
                    <p style="margin:0 0 3px;">Seu apoio mensal da comunidade</p>
                    <p style="margin:0 0 3px;">{{community.name}}</p>
                    <p style="margin:0 0 3px;">foi confirmado!</p>
                </td>
            </tr>
            <tr>
                <td>
                    A partir de agora, você será cobrado
                    <span style="font-weight:600;">
                        R$ {{amount}} todo mês.
                        Caso deseje alterar essa opção, faça tal coisa. A partir de agora, você
                        será cobrado {{amount}} todo mês. Caso deseje alterar essa opção,
                        faça tal coisa.
                    </span>
                </td>
            </tr>
            <tr>
                <td style="padding:50px 0;">
                </td>
            </tr>
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
        </table>
    </td>
</tr>})
    label = 'paid_subscription'
    if nt = NotificationTemplate.find_by_label(label)
      nt.update_attribute(:body_template, sub_template)
    else
      NotificationTemplate.find_or_create_by(
        label: label,
        subject_template: 'Assinatura paga para Comunidade {{community.name}}',
        body_template: sub_template
      )
    end

    puts 'looking for unpaid_subscription template'
    sub_template = (%{
<tr>
    <td style="height:134px;position:relative;background-color:#000;background-image:url('https://s3.amazonaws.com/hub-central-dev/uploads/1490248339_header-image.png');background-repeat:no-repeat;background-size:100%;background-position:0 0;">
        <div style="background-image:url({{community.image}});background-size:100%;position:absolute;left:50%;margin-left:-56px;width:112px;height:112px;background-color:#d8d8d8;border:5px solid #ffffff;border-radius:50%;"></div>
    </td>
</tr>
<tr>
    <td>
        <table style="width:420px;margin:0 auto;text-align:center;color:#222;font-size:17px;">
            <tr>
                <td style="padding-top:100px;padding-bottom:30px;font-size:26px;font-weight:700;">
                    <p style="margin:0 0 15px;">Problemas na cobrança da sua assinatura.</p>
                </td>
            </tr>
            <tr>
                <td>
                    Ocorreu um erro ao tentar efetuar o pagamento da assinatura de R$ {{amount}} para comunidade {{comunity.name}}
                </td>
            </tr>
            <tr>
                <td style="padding:50px 0;">
                  <a href="#cta-example" style="display:block;width:230px;padding:18px 0;margin:0 auto;background-color:#222222;font-size:16px;color:#fff;font-weight:600;text-transform:uppercase;text-decoration:none;">
                    EDITAR FORMA DE PAGAMENTO
                  </a>
                </td>
            </tr>
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
        </table>
    </td>
</tr>})
    label = 'unpaid_subscription'
    if nt = NotificationTemplate.find_by_label(label)
      nt.update_attribute(:body_template, sub_template)
    else
      NotificationTemplate.find_or_create_by(
        label: label,
        subject_template: 'Problemas na cobrança da sua assinatura.',
        body_template: sub_template
      )
    end

    puts 'looking for canceled_subscription template'
    sub_template = (%{
<tr>
    <td style="height:134px;position:relative;background-color:#000;background-image:url('https://s3.amazonaws.com/hub-central-dev/uploads/1490248339_header-image.png');background-repeat:no-repeat;background-size:100%;background-position:0 0;">
        <div style="background-image:url({{community.image}});background-size:100%;position:absolute;left:50%;margin-left:-56px;width:112px;height:112px;background-color:#d8d8d8;border:5px solid #ffffff;border-radius:50%;"></div>
    </td>
</tr>
<tr>
    <td>
        <table style="width:420px;margin:0 auto;text-align:center;color:#222;font-size:17px;">
            <tr>
                <td style="padding-top:100px;padding-bottom:30px;font-size:26px;font-weight:700;">
                    <p style="margin:0 0 3px;">Sua assinatura foi cancelada.</p>
                </td>
            </tr>
            <tr>
                <td>
                  Assinatura no valor R$ {{amount}} para comunidade {{community.name}} foi cancelada.
                </td>
            </tr>
            <tr>
                <td style="padding:50px 0;">
                </td>
            </tr>
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
        </table>
    </td>
</tr>})
    label = 'canceled_subscription'
    if nt = NotificationTemplate.find_by_label(label)
      nt.update_attribute(:body_template, sub_template)
    else
      NotificationTemplate.find_or_create_by(
        label: label,
        subject_template: 'Assinatura para Comunidade {{community.name}} foi cancelada',
        body_template: sub_template
      )
    end

  end
end
