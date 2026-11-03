<!DOCTYPE html>
<html lang="ru">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Новый заказ</title>
</head>
<body style="margin:0;padding:0;font-family:-apple-system,BlinkMacSystemFont,'Segoe UI',Roboto,sans-serif;background:#f8fafc;color:#0f172a;">
    <table role="presentation" width="100%" cellpadding="0" cellspacing="0" style="background:#f8fafc;padding:40px 20px;">
        <tr>
            <td align="center">
                <table role="presentation" width="100%" cellpadding="0" cellspacing="0" style="max-width:600px;background:#fff;border-radius:12px;overflow:hidden;box-shadow:0 1px 3px rgba(0,0,0,0.1);">
                    <tr>
                        <td style="background:#059669;padding:24px 32px;">
                            <h2 style="margin:0;font-size:18px;color:#fff;">Новый заказ в интернет-магазине</h2>
                        </td>
                    </tr>
                    <tr>
                        <td style="padding:24px 32px;">
                            <p style="margin:0 0 16px;font-size:14px;">Поступил новый заказ:</p>

                            <table width="100%" cellpadding="0" cellspacing="0" style="background:#f8fafc;border-radius:8px;padding:16px;margin-bottom:16px;">
                                <tr>
                                    <td style="font-size:13px;color:#64748b;">Номер</td>
                                    <td style="font-size:13px;font-weight:600;text-align:right;">{{ $order->order_number }}</td>
                                </tr>
                                <tr style="border-top:1px solid #e2e8f0;">
                                    <td style="padding-top:8px;font-size:13px;color:#64748b;">Сумма</td>
                                    <td style="padding-top:8px;font-size:13px;font-weight:600;text-align:right;">{{ number_format((float) $order->total_amount, 2, '.', ' ') }} ₽</td>
                                </tr>
                                <tr style="border-top:1px solid #e2e8f0;">
                                    <td style="padding-top:8px;font-size:13px;color:#64748b;">Покупатель</td>
                                    <td style="padding-top:8px;font-size:13px;font-weight:600;text-align:right;">{{ $order->customer_name }}</td>
                                </tr>
                                <tr style="border-top:1px solid #e2e8f0;">
                                    <td style="padding-top:8px;font-size:13px;color:#64748b;">Телефон</td>
                                    <td style="padding-top:8px;font-size:13px;text-align:right;">{{ $order->customer_phone }}</td>
                                </tr>
                                <tr style="border-top:1px solid #e2e8f0;">
                                    <td style="padding-top:8px;font-size:13px;color:#64748b;">Email</td>
                                    <td style="padding-top:8px;font-size:13px;text-align:right;">{{ $order->customer_email }}</td>
                                </tr>
                                <tr style="border-top:1px solid #e2e8f0;">
                                    <td style="padding-top:8px;font-size:13px;color:#64748b;">Способ</td>
                                    <td style="padding-top:8px;font-size:13px;text-align:right;">{{ $order->delivery_method === 'delivery' ? 'Доставка' : 'Самовывоз' }}</td>
                                </tr>
                            </table>

                            <p style="margin:0;font-size:13px;color:#94a3b8;">Обработайте заказ в админ-панели.</p>
                        </td>
                    </tr>
                </table>
            </td>
        </tr>
    </table>
</body>
</html>
