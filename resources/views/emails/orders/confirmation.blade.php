<!DOCTYPE html>
<html lang="ru">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Подтверждение заказа</title>
</head>
<body style="margin:0;padding:0;font-family:-apple-system,BlinkMacSystemFont,'Segoe UI',Roboto,sans-serif;background:#f8fafc;color:#0f172a;">
    <table role="presentation" width="100%" cellpadding="0" cellspacing="0" style="background:#f8fafc;padding:40px 20px;">
        <tr>
            <td align="center">
                <table role="presentation" width="100%" cellpadding="0" cellspacing="0" style="max-width:600px;background:#fff;border-radius:12px;overflow:hidden;box-shadow:0 1px 3px rgba(0,0,0,0.1);">
                    <!-- Header -->
                    <tr>
                        <td style="background:#059669;padding:32px 32px 24px;text-align:center;">
                            <h1 style="margin:0;font-size:24px;color:#fff;">Гидровик</h1>
                            <p style="margin:8px 0 0;font-size:14px;color:#d1fae5;">Промышленное гидравлическое оборудование</p>
                        </td>
                    </tr>

                    <!-- Body -->
                    <tr>
                        <td style="padding:32px;">
                            <h2 style="margin:0 0 8px;font-size:20px;">Заказ {{ $order->order_number }} оформлен</h2>
                            <p style="margin:0 0 24px;font-size:14px;color:#64748b;">Спасибо за ваш заказ! Мы свяжемся с вами для подтверждения и согласования условий оплаты и доставки.</p>

                            <!-- Order details -->
                            <table width="100%" cellpadding="0" cellspacing="0" style="background:#f8fafc;border-radius:8px;padding:20px;margin-bottom:24px;">
                                <tr>
                                    <td style="font-size:14px;color:#64748b;">Номер заказа</td>
                                    <td style="font-size:14px;font-weight:600;text-align:right;">{{ $order->order_number }}</td>
                                </tr>
                                <tr style="border-top:1px solid #e2e8f0;">
                                    <td style="padding-top:12px;font-size:14px;color:#64748b;">Дата</td>
                                    <td style="padding-top:12px;font-size:14px;font-weight:600;text-align:right;">{{ $order->created_at->format('d.m.Y H:i') }}</td>
                                </tr>
                                <tr style="border-top:1px solid #e2e8f0;">
                                    <td style="padding-top:12px;font-size:14px;color:#64748b;">Способ получения</td>
                                    <td style="padding-top:12px;font-size:14px;font-weight:600;text-align:right;">{{ $order->delivery_method === 'delivery' ? 'Доставка' : 'Самовывоз' }}</td>
                                </tr>
                                <tr style="border-top:1px solid #e2e8f0;">
                                    <td style="padding-top:12px;font-size:14px;color:#64748b;">Статус</td>
                                    <td style="padding-top:12px;font-size:14px;font-weight:600;text-align:right;color:#059669;">Новый</td>
                                </tr>
                            </table>

                            <!-- Items -->
                            <h3 style="margin:0 0 12px;font-size:16px;">Товары</h3>
                            <table width="100%" cellpadding="0" cellspacing="0" style="margin-bottom:24px;">
                                @foreach($order->items as $item)
                                <tr style="border-bottom:1px solid #f1f5f9;">
                                    <td style="padding:12px 0;font-size:14px;">
                                        <strong>{{ $item->product_name }}</strong>
                                        <span style="color:#94a3b8;"> × {{ $item->quantity }}</span>
                                    </td>
                                    <td style="padding:12px 0;font-size:14px;font-weight:600;text-align:right;">{{ number_format((float) $item->subtotal, 2, '.', ' ') }} ₽</td>
                                </tr>
                                @endforeach
                                <tr>
                                    <td colspan="2" style="padding:16px 0 0;border-top:2px solid #e2e8f0;">
                                        <table width="100%">
                                            <tr>
                                                <td style="font-size:16px;font-weight:700;">Итого:</td>
                                                <td style="font-size:16px;font-weight:700;text-align:right;">{{ number_format((float) $order->total_amount, 2, '.', ' ') }} ₽</td>
                                            </tr>
                                        </table>
                                    </td>
                                </tr>
                            </table>

                            <!-- Contact info -->
                            <h3 style="margin:0 0 12px;font-size:16px;">Контактные данные</h3>
                            <table width="100%" cellpadding="0" cellspacing="0" style="background:#f8fafc;border-radius:8px;padding:16px;margin-bottom:24px;">
                                <tr>
                                    <td style="font-size:14px;color:#64748b;">Имя</td>
                                    <td style="font-size:14px;font-weight:600;">{{ $order->customer_name }}</td>
                                </tr>
                                <tr style="border-top:1px solid #e2e8f0;">
                                    <td style="padding-top:8px;font-size:14px;color:#64748b;">Телефон</td>
                                    <td style="padding-top:8px;font-size:14px;font-weight:600;">{{ $order->customer_phone }}</td>
                                </tr>
                                <tr style="border-top:1px solid #e2e8f0;">
                                    <td style="padding-top:8px;font-size:14px;color:#64748b;">Email</td>
                                    <td style="padding-top:8px;font-size:14px;font-weight:600;">{{ $order->customer_email }}</td>
                                </tr>
                                @if($order->customer_organization)
                                <tr style="border-top:1px solid #e2e8f0;">
                                    <td style="padding-top:8px;font-size:14px;color:#64748b;">Организация</td>
                                    <td style="padding-top:8px;font-size:14px;font-weight:600;">{{ $order->customer_organization }}</td>
                                </tr>
                                @endif
                                @if($order->delivery_address)
                                <tr style="border-top:1px solid #e2e8f0;">
                                    <td style="padding-top:8px;font-size:14px;color:#64748b;">Адрес доставки</td>
                                    <td style="padding-top:8px;font-size:14px;font-weight:600;">{{ $order->delivery_address }}</td>
                                </tr>
                                @endif
                                @if($order->comment)
                                <tr style="border-top:1px solid #e2e8f0;">
                                    <td style="padding-top:8px;font-size:14px;color:#64748b;">Комментарий</td>
                                    <td style="padding-top:8px;font-size:14px;">{{ $order->comment }}</td>
                                </tr>
                                @endif
                            </table>

                            <p style="margin:0;font-size:13px;color:#94a3b8;">Мы свяжемся с вами в ближайшее время для подтверждения заказа и согласования условий оплаты и доставки.</p>
                        </td>
                    </tr>

                    <!-- Footer -->
                    <tr>
                        <td style="background:#f8fafc;padding:24px 32px;text-align:center;border-top:1px solid #e2e8f0;">
                            <p style="margin:0;font-size:12px;color:#94a3b8;">© {{ date('Y') }} Гидровик. Все права защищены.</p>
                        </td>
                    </tr>
                </table>
            </td>
        </tr>
    </table>
</body>
</html>
