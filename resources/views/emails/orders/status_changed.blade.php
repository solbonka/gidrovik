<!DOCTYPE html>
<html lang="ru">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Статус заказа изменён</title>
</head>
<body style="margin:0;padding:0;font-family:-apple-system,BlinkMacSystemFont,'Segoe UI',Roboto,sans-serif;background:#f8fafc;color:#0f172a;">
    <table role="presentation" width="100%" cellpadding="0" cellspacing="0" style="background:#f8fafc;padding:40px 20px;">
        <tr>
            <td align="center">
                <table role="presentation" width="100%" cellpadding="0" cellspacing="0" style="max-width:600px;background:#fff;border-radius:12px;overflow:hidden;box-shadow:0 1px 3px rgba(0,0,0,0.1);">
                    <tr>
                        <td style="background:#059669;padding:24px 32px;">
                            <h2 style="margin:0;font-size:18px;color:#fff;">Статус заказа изменён</h2>
                        </td>
                    </tr>
                    <tr>
                        <td style="padding:24px 32px;">
                            <p style="margin:0 0 16px;font-size:14px;">Статус вашего заказа <strong>{{ $order->order_number }}</strong> изменён на <strong>{{ $newStatusLabel }}</strong>.</p>

                            @if($note)
                            <p style="margin:0 0 16px;font-size:14px;background:#f8fafc;border-radius:8px;padding:12px 16px;">{{ $note }}</p>
                            @endif

                            <p style="margin:0;font-size:13px;color:#94a3b8;">Спасибо, что выбираете Гидровик!</p>
                        </td>
                    </tr>
                </table>
            </td>
        </tr>
    </table>
</body>
</html>
